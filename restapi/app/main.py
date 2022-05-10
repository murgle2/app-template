from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.router import path
from app.router.api import login
from app.db.database import engine
from app.db import base
from app.db.database import SessionLocal
from app.scripts import populate_db
from app.core.config import settings


if settings.ENV == "dev":
    base.Base.metadata.drop_all(bind=engine)
    base.Base.metadata.create_all(bind=engine)
    with SessionLocal() as session:
        populate_db.generate_all(session)
else:
    base.Base.metadata.create_all(bind=engine)
    with SessionLocal() as session:
        populate_db.generate_categories(session)

app = FastAPI()

app.include_router(path.api_router)
app.include_router(login.router)


@app.get("/api")
async def root():
    return {"message": "Hello World"}

origins = [
    "http://localhost:8000",
    "<DOMAIN NAME>"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
