from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from models import Favorite, Artwork, Author
from schemas import FavoriteCreate, FavoriteOut, FavoriteArtworkOut
from dependencies import get_db

router = APIRouter(tags=["Favorites"])

@router.post("/", response_model=FavoriteOut)
def add_favorite(fav: FavoriteCreate, db: Session = Depends(get_db)):
    existing = db.query(Favorite).filter_by(user_id=fav.user_id, artwork_id=fav.artwork_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="Already in favorites")
    db_fav = Favorite(**fav.dict())
    db.add(db_fav)
    db.commit()
    db.refresh(db_fav)
    return db_fav

@router.delete("/", response_model=dict)
def remove_favorite(fav: FavoriteCreate, db: Session = Depends(get_db)):
    favorite = db.query(Favorite).filter_by(user_id=fav.user_id, artwork_id=fav.artwork_id).first()
    if not favorite:
        raise HTTPException(status_code=404, detail="Not found")
    db.delete(favorite)
    db.commit()
    return {"ok": True}

@router.get("/", response_model=List[FavoriteArtworkOut])
def get_favorites(user_id: int, db: Session = Depends(get_db)):
    favorites = (
        db.query(Artwork)
        .join(Favorite, Favorite.artwork_id == Artwork.id)
        .outerjoin(Author, Artwork.author_id == Author.id)
        .filter(Favorite.user_id == user_id)
        .all()
    )

    result = []
    for art in favorites:
        result.append({
            "id": art.id,
            "title": art.title,
            "image": art.image,
            "author_name": art.author.name if art.author else None
        })

    return result

@router.get("/check")
def is_favorite(user_id: int, artwork_id: int, db: Session = Depends(get_db)):
    exists = db.query(Favorite).filter_by(user_id=user_id, artwork_id=artwork_id).first()
    return {"is_favorite": exists is not None}