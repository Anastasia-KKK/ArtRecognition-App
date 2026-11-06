from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from passlib.hash import bcrypt
from dependencies import get_db
import crud
from pydantic import BaseModel

router = APIRouter(tags=["Managers"])

class ManagerLogin(BaseModel):
    email: str
    password: str

@router.post("/login")
def manager_login(data: ManagerLogin, db: Session = Depends(get_db)):
    manager = crud.get_manager_by_email(db, data.email)
    if not manager or not bcrypt.verify(data.password, manager.password):
        raise HTTPException(status_code=401, detail="Неверный email или пароль")

    return {
        "id": manager.id,
        "full_name": manager.full_name,
        "email": manager.email,
        "access_level": manager.access_level,
    }

@router.get("/")
def list_managers(db: Session = Depends(get_db)):
    return crud.get_all_managers(db)