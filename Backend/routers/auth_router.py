from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from passlib.hash import bcrypt
from dependencies import get_db
from schemas import UserResponse
from pydantic import BaseModel
import crud
import models

router = APIRouter(tags=["Auth"])


class UserCreate(BaseModel):
    name: str
    email: str
    password: str
    language: str


class UserLogin(BaseModel):
    email: str
    password: str


@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    return crud.create_user(db, **user.dict())


@router.post("/login")
async def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, user.email)

    if not db_user or not bcrypt.verify(user.password, db_user.password):
        raise HTTPException(
            status_code=401,
            detail="Неверный email или пароль"
        )

    return {
        "id": db_user.id,
        "name": db_user.name,
        "email": db_user.email,
        "language": db_user.language,
        "photo": db_user.photo,
    }


@router.get("/me", response_model=UserResponse)
def get_user_profile(
    user_id: int = Query(...),
    db: Session = Depends(get_db)
):
    user = db.query(models.User).filter(
        models.User.id == user_id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return user