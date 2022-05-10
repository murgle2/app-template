from fastapi import APIRouter, status, HTTPException, Depends
from sqlalchemy.orm import Session

from app import schema, crud, model
from app.router import dep
from app.util import (
    send_new_account_email
)

router = APIRouter(
    prefix="/user"
)


@router.get("", response_model=schema.UserResponse)
def get_user_current(
    db: Session = Depends(dep.get_db),
    current_user: model.User = Depends(dep.get_current_active_user),
):
    return current_user


@router.get("/{user_id}", response_model=schema.UserResponse, status_code=status.HTTP_200_OK)
def get_user_by_id(user_id: int, db: Session = Depends(dep.get_db)):
    db_user = crud.user.get_user(user_id, db)
    return db_user


@router.patch("/darkTheme/{uses_dark_theme}", response_model=schema.Msg, status_code=status.HTTP_200_OK)
def update_user_theme(
    uses_dark_theme: bool,
    db: Session = Depends(dep.get_db),
    current_user: model.User = Depends(dep.get_current_active_user)
):
    crud.user.update_user_theme(current_user, uses_dark_theme, db)
    return {"msg": "Theme updated"}


@router.post("", response_model=schema.UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(user: schema.UserCreate, db: Session = Depends(dep.get_db)):
    db_user = crud.user.get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    send_new_account_email(user.email)
    return crud.user.create_user(user, db)
