from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

if settings.ENV == "dev":
    db_url = f"postgresql://{settings.DB_USER}:{settings.DB_PW}@{settings.DB_HOST}/{settings.DB_NAME}"
else:
    db_url = f"postgresql://{settings.DB_USER}:{settings.DB_PW}@/{settings.DB_NAME}?host={settings.UNIX_PATH}"

engine = create_engine(db_url, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
