from datetime import timedelta
import secrets

from fastapi import APIRouter, Body, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app import crud, schema
from app.router import dep
from app.core import security
from app.core.config import settings
from app.util import (
    generate_account_update_token,
    send_reset_password_email,
    verify_account_update_token,
    send_verify_account_email,
    verify_google_token,
    send_new_account_email,
    verify_apple_token
)
from app.model.user import Role, Social

router = APIRouter()


@router.post("/login/access-token", response_model=schema.Token)
def login_access_token(
    db: Session = Depends(dep.get_db), form_data: OAuth2PasswordRequestForm = Depends()
):
    user = crud.user.authenticate(
        db, email=form_data.username, password=form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=400, detail="Incorrect email or password")
    access_token_expires = timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": security.create_access_token(
            user.id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }


@router.post("/password-recovery/{email}", response_model=schema.Msg)
def recover_password(email: str, db: Session = Depends(dep.get_db)):
    user = crud.user.get_user_by_email(db, email=email)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this email does not exist in the system",
        )
    password_reset_token = generate_account_update_token(email=email)
    send_reset_password_email(
        email=email, token=password_reset_token
    )
    return {"msg": "Password recovery email sent\nYou may need to check spam folder"}


@router.post("/reset-password", response_model=schema.Msg)
def reset_password(
    new_password: str = Body(..., min_length=8, max_length=32),
    token: str = Body("token"),
    db: Session = Depends(dep.get_db),
):
    email = verify_account_update_token(token)
    if not email:
        raise HTTPException(status_code=400, detail="Invalid token")
    user = crud.user.get_user_by_email(db, email=email)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this email does not exist in the system",
        )
    elif not crud.user.is_active(user):
        raise HTTPException(status_code=400, detail="Inactive user")
    hashed_password = security.get_password_hash(new_password)
    user.hashed_password = hashed_password
    db.commit()
    return {"msg": "Password updated successfully"}


@router.post("/request-verify/{email}", response_model=schema.Msg)
def request_verify(email: str, db: Session = Depends(dep.get_db)):
    user = crud.user.get_user_by_email(db, email=email)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this email does not exist in the system",
        )
    password_reset_token = generate_account_update_token(email=email)
    send_verify_account_email(
        email=email, token=password_reset_token
    )
    return {"msg": "Verification email sent\n\nYou may need to check spam folder"}


@router.post("/verify-email", response_model=schema.Msg)
def verify_email(
    token: str = Body(...),
    db: Session = Depends(dep.get_db),
):
    email = verify_account_update_token(token)
    if not email:
        raise HTTPException(status_code=400, detail="Invalid token")
    user = crud.user.get_user_by_email(db, email=email)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="The user with this email does not exist in the system",
        )
    elif not crud.user.is_active(user):
        raise HTTPException(status_code=400, detail="Inactive user")
    user.role = Role.VERIFIED
    # db.add(user)
    db.commit()
    return {"msg": "Email verified successfully"}


@router.post("/google", response_model=schema.Token)
def google(
    token: str = Body(...),
    db: Session = Depends(dep.get_db)
):
    email = verify_google_token(token)
    if not email:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = crud.user.get_user_by_email(db, email=email)
    if not user:
        send_new_account_email(email)
        user = crud.user.create_user(
            schema.UserCreate(
                email=email,
                password=secrets.token_urlsafe(16),
                social_login=Social.GOOGLE,
                role=Role.VERIFIED),
            db)
    elif user.social_login != Social.GOOGLE and user.role == Role.BASE:
        raise HTTPException(
            status_code=400,
            detail="Email already registered. To use Google for this account, " +
            "please sign in with your password and verify the email address"
        )
    access_token_expires = timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": security.create_access_token(
            user.id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }


@router.post("/apple", response_model=schema.Token)
def apple(
    token: str = Body(...),
    db: Session = Depends(dep.get_db)
):
    email = verify_apple_token(token)
    if not email:
        raise HTTPException(status_code=401, detail="Invalid token")
    user = crud.user.get_user_by_email(db, email=email)
    if not user:
        send_new_account_email(email)
        user = crud.user.create_user(
            schema.UserCreate(
                email=email,
                password=secrets.token_urlsafe(16),
                social_login=Social.APPLE,
                role=Role.VERIFIED),
            db)
    elif user.social_login != Social.APPLE and user.role == Role.BASE:
        raise HTTPException(
            status_code=400,
            detail="Email already registered. To use Apple for this account, " +
            "please sign in with your password and verify the email address"
        )
    access_token_expires = timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    return {
        "access_token": security.create_access_token(
            user.id, expires_delta=access_token_expires
        ),
        "token_type": "bearer",
    }
