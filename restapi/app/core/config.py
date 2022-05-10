import secrets

from pydantic import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str
    SERVER_HOST: str
    SECRET_KEY: str = secrets.token_urlsafe(32)
    CLIENT_ID: str
    # 60 minutes * 24 hours * 8 days = 8 days
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8
    ENV: str
    DB_USER: str
    DB_PW: str
    DB_NAME: str

    DB_HOST: str
    UNIX_PATH: str

    EMAIL_TEMPLATES_DIR: str
    ACCOUNT_UPDATE_TOKEN_EXPIRE_HOURS: int = 2
    SMTP_TLS: bool = True
    SMTP_PORT: int
    SMTP_HOST: str
    SMTP_USER: str
    SMTP_PASSWORD: str
    EMAILS_FROM_EMAIL: str
    EMAILS_FROM_NAME: str

    class Config:
        env_file = ".env"


settings = Settings()
