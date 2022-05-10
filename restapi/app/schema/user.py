from typing import Optional
from pydantic import BaseModel, EmailStr, Field
from app.model import Role, Social


class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    is_active: Optional[bool] = True


class UserCreate(UserBase):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=32)
    social_login: Social = None
    role: Role = None


class UserUpdateTheme(UserBase):
    uses_dark_theme: bool


class UserInDB(UserBase):
    id: Optional[int] = None

    class Config:
        orm_mode = True


class UserResponse(UserInDB):
    role: Role
    uses_dark_theme: bool
