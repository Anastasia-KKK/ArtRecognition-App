from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from dependencies import get_db
from schemas import AuthorBase
from crud import get_all_authors
from models import Author

router = APIRouter(tags=["Authors"])

@router.get("/", response_model=list[AuthorBase])
def read_authors(db: Session = Depends(get_db)):
    return get_all_authors(db)

@router.post("/")
def create_author(data: dict, db: Session = Depends(get_db)):
    try:
        new_author = Author(**data)
        db.add(new_author)
        db.commit()
        db.refresh(new_author)
        return {"message": "Автор успешно добавлен", "id": new_author.id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/{author_id}")
def get_author(author_id: int, db: Session = Depends(get_db)):
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="Author not found")
    return author

@router.put("/{author_id}")
def update_author(author_id: int, data: dict, db: Session = Depends(get_db)):
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="Author not found")

    for key, value in data.items():
        if hasattr(author, key):
            setattr(author, key, value)

    db.commit()
    db.refresh(author)
    return {"message": "Author updated successfully", "id": author.id}

@router.delete("/{author_id}")
def delete_author(author_id: int, db: Session = Depends(get_db)):
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="Author not found")

    db.delete(author)
    db.commit()
    return {"message": "Author deleted successfully"}