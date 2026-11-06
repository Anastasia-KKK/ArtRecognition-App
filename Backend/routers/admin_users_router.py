from fastapi import APIRouter, Depends, HTTPException, Form
from sqlalchemy.orm import Session
from sqlalchemy import text
from dependencies import get_db
from security import get_password_hash
from models import User, ContentManager, Administrator

router = APIRouter(tags=["Admin Users"])

@router.get("/users")
def get_all_users(db: Session = Depends(get_db)):
    query = text("""
        SELECT id, name, email, 'Пользователь' AS role
        FROM users
        UNION ALL
        SELECT id, full_name AS name, email, 'Модератор' AS role
        FROM content_managers
        UNION ALL
        SELECT id, full_name AS name, email, 'Администратор' AS role
        FROM admins
    """)
    result = db.execute(query).fetchall()

    users = [dict(row._mapping) for row in result]

    return users


@router.delete("/users/{role}/{user_id}")
def delete_user(role: str, user_id: int, db: Session = Depends(get_db)):
    if role == "Пользователь":
        table = "users"
    elif role == "Модератор":
        table = "content_managers"
    else:
        raise HTTPException(status_code=400, detail="Удаление администратора запрещено")

    db.execute(text(f"DELETE FROM {table} WHERE id = :user_id"), {"user_id": user_id})
    db.commit()
    return {"ok": True, "message": f"{role} удалён"}


@router.post("/add-user")
def add_user(
    name: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    role: str = Form(...),
    db: Session = Depends(get_db)
):
    if db.query(User).filter(User.email == email).first() or \
       db.query(ContentManager).filter(ContentManager.email == email).first() or \
       db.query(Administrator).filter(Administrator.email == email).first():
        raise HTTPException(status_code=400, detail="Пользователь с таким email уже существует")

    hashed_password = get_password_hash(password)

    if role.lower() == "пользователь":
        db.add(User(name=name, email=email, password=hashed_password, language="ru"))
    elif role.lower() == "модератор":
        db.add(ContentManager(full_name=name, email=email, password=hashed_password, access_level="standard"))
    elif role.lower() == "администратор":
        db.add(Administrator(full_name=name, email=email, password=hashed_password, access_level="full"))
    else:
        raise HTTPException(status_code=400, detail="Некорректная роль")

    db.commit()
    return {"message": f"{role} успешно добавлен!"}