import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, Optional

import emails
from emails.template import JinjaTemplate
from jose import jwt
from google.oauth2 import id_token
from google.auth.transport import requests
from siwa import IdentityToken, KeyCache

from app.core.config import settings


def send_email(
    email_to: str,
    subject_template: str = "",
    html_template: str = "",
    environment: Dict[str, Any] = {},
):
    message = emails.Message(
        subject=JinjaTemplate(subject_template),
        html=JinjaTemplate(html_template),
        mail_from=(settings.EMAILS_FROM_NAME, settings.EMAILS_FROM_EMAIL),
    )
    smtp_options = {"host": settings.SMTP_HOST, "port": settings.SMTP_PORT}
    if settings.SMTP_TLS:
        smtp_options["tls"] = True
    if settings.SMTP_USER:
        smtp_options["user"] = settings.SMTP_USER
    if settings.SMTP_PASSWORD:
        smtp_options["password"] = settings.SMTP_PASSWORD
    response = message.send(to=email_to, render=environment, smtp=smtp_options)
    logging.info(f"send email result: {response}")


def send_reset_password_email(email: str, token: str):
    project_name = settings.PROJECT_NAME
    subject = f"{project_name} - Password recovery for {email}"
    with open(Path(settings.EMAIL_TEMPLATES_DIR + "reset_password.html")) as f:
        template_str = f.read()
    server_host = settings.SERVER_HOST
    link = f"{server_host}/?resetToken={token}"
    send_email(
        email_to=email,
        subject_template=subject,
        html_template=template_str,
        environment={
            "project_name": settings.PROJECT_NAME,
            "email": email,
            "valid_hours": settings.ACCOUNT_UPDATE_TOKEN_EXPIRE_HOURS,
            "link": link,
        },
    )


def send_verify_account_email(email: str, token: str):
    project_name = settings.PROJECT_NAME
    subject = f"{project_name} - Email verification for {email}"
    with open(Path(settings.EMAIL_TEMPLATES_DIR + "verify_email.html")) as f:
        template_str = f.read()
    server_host = settings.SERVER_HOST
    link = f"{server_host}/?verifyToken={token}"
    send_email(
        email_to=email,
        subject_template=subject,
        html_template=template_str,
        environment={
            "project_name": settings.PROJECT_NAME,
            "email": email,
            "valid_hours": settings.ACCOUNT_UPDATE_TOKEN_EXPIRE_HOURS,
            "link": link,
        },
    )


def send_new_account_email(email: str):
    project_name = settings.PROJECT_NAME
    subject = f"Welcome to {project_name}"
    with open(Path(settings.EMAIL_TEMPLATES_DIR + "new_account.html")) as f:
        template_str = f.read()
    send_email(
        email_to=email,
        subject_template=subject,
        html_template=template_str,
        environment={
            "project_name": settings.PROJECT_NAME,
        },
    )


def generate_account_update_token(email: str) -> str:
    delta = timedelta(hours=settings.ACCOUNT_UPDATE_TOKEN_EXPIRE_HOURS)
    now = datetime.utcnow()
    expires = now + delta
    exp = expires.timestamp()
    encoded_jwt = jwt.encode(
        {"exp": exp, "nbf": now, "email": email}, settings.SECRET_KEY, algorithm="HS256",
    )
    return encoded_jwt


def verify_account_update_token(token: str) -> Optional[str]:
    try:
        decoded_token = jwt.decode(
            token, settings.SECRET_KEY, algorithms=["HS256"])
        return decoded_token["email"]
    except jwt.JWTError:
        return None


def verify_google_token(token: str) -> Optional[str]:
    try:
        decoded_token = id_token.verify_oauth2_token(
            token, requests.Request(),
            settings.CLIENT_ID)
        return decoded_token["email"]
    except jwt.JWTError:
        return None


def verify_apple_token(token: str) -> Optional[str]:
    cache = KeyCache()
    try:
        decoded_token = IdentityToken.parse(data=token)
        if not decoded_token.is_validly_signed(audience="live.xpo.service", key_cache=cache):
            raise jwt.JWTError
        return decoded_token.payload.email
    except jwt.JWTError:
        return None
