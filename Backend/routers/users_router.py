from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from dependencies import get_db
from security import verify_password, get_password_hash
from models import User
from schemas import UserResponse
from pydantic import BaseModel

router = APIRouter(tags=["Users"])


@router.post("/change-password")
def change_password(data: dict, db: Session = Depends(get_db)):
    user_id = data.get("user_id")
    current_password = data.get("current_password")
    new_password = data.get("new_password")

    if not user_id or not current_password or not new_password:
        raise HTTPException(status_code=400, detail="Не все поля заполнены")

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not verify_password(current_password, user.password):
        raise HTTPException(status_code=400, detail="Неверный текущий пароль")

    user.password = get_password_hash(new_password)
    db.commit()
    return {"message": "Пароль успешно изменён"}


class UserUpdate(BaseModel):
    name: str
    email: str
    language: str | None = None
    photo: bytes | None = None

@router.put("/{user_id}", response_model=UserResponse)
def update_user(user_id: int, user_data: UserUpdate, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.name = user_data.name
    user.email = user_data.email
    if user_data.language:
        user.language = user_data.language
    if user_data.photo:
        user.photo = user_data.photo

    db.commit()
    db.refresh(user)
    return user