from sqlalchemy import Column, Integer, String, Boolean, Enum
from sqlalchemy.sql.schema import Table, ForeignKey
import enum

from app.db.base_class import Base


class Role(enum.IntEnum):
    BASE = 0  # Allows notifications
    VERIFIED = 1  # Can make suggestion
    ADMIN = 2  # .. and can edit or delete existing posts


class Social(enum.IntEnum):
    GOOGLE = 0
    APPLE = 1


class User(Base):
    email = Column(String(80), unique=True, index=True, nullable=False)
    is_active = Column(Boolean, default=True)
    role = Column(Enum(Role), default=Role.BASE)
    points = Column(Integer, default=0)
    hashed_password = Column(String, nullable=False)
    social_login = Column(Enum(Social))
    uses_dark_theme = Column(Boolean, default=False)
