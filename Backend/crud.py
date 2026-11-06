from sqlalchemy.orm import Session
from models import User, Artwork, Author, ContentManager
from passlib.hash import bcrypt
import models
from sqlalchemy.orm import joinedload

def create_user(db: Session, name: str, email: str, password: str, language: str):
    hashed_pw = bcrypt.hash(password)
    user = User(
        name=name,
        email=email,
        password=hashed_pw,
        language=language
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_artwork_by_id(db: Session, artwork_id: int):
    return db.query(models.Artwork).filter(models.Artwork.id == artwork_id).first()

def get_all_artworks(db: Session):

    return db.query(models.Artwork).options(

        joinedload(models.Artwork.author)

    ).all()

def get_all_authors(db: Session):
    return db.query(Author).all()

# ---------- Модераторы ----------

def get_manager_by_email(db: Session, email: str):
    return db.query(ContentManager).filter(ContentManager.email == email).first()


def get_all_managers(db: Session):
    return db.query(ContentManager).all()

def create_artwork(db: Session, artwork_data):
    new_artwork = Artwork(
        title=artwork_data.title,
        title_en=artwork_data.title_en,
        author_id=artwork_data.author_id,
        year=artwork_data.year,
        material=artwork_data.material,
        material_en=artwork_data.material_en,
        size=artwork_data.size,
        size_en=artwork_data.size_en,
        description=artwork_data.description,
        description_en=artwork_data.description_en,
        creation_history=artwork_data.creation_history,
        creation_history_en=artwork_data.creation_history_en,
        image=artwork_data.image
    )
    db.add(new_artwork)
    db.commit()
    db.refresh(new_artwork)
    return new_artwork