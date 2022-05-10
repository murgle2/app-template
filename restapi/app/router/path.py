from fastapi import APIRouter

from app.router.api import user

api_router = APIRouter(
    prefix="/api"
)

# include tags?
api_router.include_router(user.router)
