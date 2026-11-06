from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from dependencies import get_db
from security import verify_password
from models import Administrator

router = APIRouter(tags=["Admin Auth"])

@router.post("/login")
def admin_login(
    email: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    admin = db.query(Administrator).filter(Administrator.email == email).first()

    if not admin:
        raise HTTPException(status_code=401, detail="Пользователь не является администратором")

    if not verify_password(password, admin.password):
        raise HTTPException(status_code=401, detail="Неверный пароль")

    return {
        "status": "ok",
        "role": "admin",
        "name": admin.full_name
    }