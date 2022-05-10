"""
This script populates the db with data.
"""

import random
from fastapi import Depends
from app import model
from app.router import dep
from sqlalchemy.orm import Session

from app.model.user import Role


# Create user with password "password"
db_user = model.User(email="murgle@email.com",
                     role=Role.ADMIN,
                     hashed_password="$2b$12$o8oddT2vs/y683Opq9zx4ONVoo5RfYWX1dMh1AJkK5g3bgTTCx1D6")


def generate_all(db: Session = Depends(dep.get_db)):
    db.add(db_user)
    db.commit()
