from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from dependencies import get_db
import crud
import models
from pydantic import BaseModel
from typing import Optional
from schemas import ArtworkOut
from typing import List


router = APIRouter(tags=["Artworks"])

class ArtworkCreate(BaseModel):
    title: str
    title_en: Optional[str] = None
    author_id: Optional[int] = None
    year: Optional[str] = None
    material: Optional[str] = None
    material_en: Optional[str] = None
    size: Optional[str] = None
    size_en: Optional[str] = None
    description: Optional[str] = None
    description_en: Optional[str] = None
    creation_history: Optional[str] = None
    creation_history_en: Optional[str] = None
    image: Optional[str] = None


@router.get("/", response_model=List[ArtworkOut])
def list_artworks(db: Session = Depends(get_db)):
    return crud.get_all_artworks(db)


@router.get("/{artwork_id}", response_model=ArtworkOut)
def get_artwork(artwork_id: int, db: Session = Depends(get_db)):
    artwork = crud.get_artwork_by_id(db, artwork_id)
    if not artwork:
        raise HTTPException(status_code=404, detail="Artwork not found")
    return artwork


@router.post("/")
def create_artwork(artwork: ArtworkCreate, db: Session = Depends(get_db)):
    try:
        new_artwork = crud.create_artwork(db, artwork)
        return {"message": "Картина успешно добавлена", "id": new_artwork.id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{artwork_id}")
def update_artwork(artwork_id: int, data: dict, db: Session = Depends(get_db)):
    artwork = db.query(models.Artwork).filter(models.Artwork.id == artwork_id).first()
    if not artwork:
        raise HTTPException(status_code=404, detail="Artwork not found")

    for key, value in data.items():
        if hasattr(artwork, key):
            setattr(artwork, key, value)

    db.commit()
    db.refresh(artwork)
    return {"message": "Artwork updated successfully", "id": artwork.id}


@router.delete("/{artwork_id}")
def delete_artwork(artwork_id: int, db: Session = Depends(get_db)):
    artwork = db.query(models.Artwork).filter(models.Artwork.id == artwork_id).first()
    if not artwork:
        raise HTTPException(status_code=404, detail="Artwork not found")

    db.delete(artwork)
    db.commit()
    return {"message": "Artwork deleted successfully"}