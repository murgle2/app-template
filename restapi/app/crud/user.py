from typing import List, Optional
from sqlalchemy.orm import Session
from app import model, schema, crud
from app.core.security import verify_password, get_password_hash


class User():
    def get_user(self, db: Session, user_id: int):
        return db.query(model.User).filter(model.User.id == user_id).first()

    def get_user_by_email(self, db: Session, email: str) -> model.User:
        return db.query(model.User).filter(model.User.email == email).first()

    def create_user(self, user: schema.UserCreate, db: Session):
        db_user = model.User(email=user.email,
                             hashed_password=get_password_hash(user.password),
                             social_login=user.social_login,
                             role=user.role)
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user

    def update_user_theme(self, user: model.User, uses_dark_theme: bool, db: Session):
        user.uses_dark_theme = uses_dark_theme
        db.commit()

    def authenticate(self, db: Session, *, email: str, password: str) -> Optional[model.User]:
        user = self.get_user_by_email(db, email=email)
        if not user:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user


user = User()
