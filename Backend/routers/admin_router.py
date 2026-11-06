from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from dependencies import get_db
from sqlalchemy import text

router = APIRouter(tags=["Admin Analytics"])
router = APIRouter(tags=["Admin Dashboard"])


@router.get("/analytics")
def get_content_analytics(db: Session = Depends(get_db)):
    artworks_per_author = db.execute(text("""
        SELECT au.name, COUNT(ar.id) AS artworks_count
        FROM authors au
        JOIN artworks ar ON au.id = ar.author_id
        GROUP BY au.name
        ORDER BY artworks_count DESC;
    """)).fetchall()

    popular_artworks = db.execute(text("""
        SELECT a.title, au.name AS author, COUNT(f.id) AS count
        FROM artworks a
        JOIN authors au ON a.author_id = au.id
        JOIN favorites f ON a.id = f.artwork_id
        GROUP BY a.title, au.name
        ORDER BY count DESC
        LIMIT 10;
    """)).fetchall()

    popular_authors = db.execute(text("""
        SELECT au.name, COUNT(f.id) AS count
        FROM authors au
        JOIN artworks a ON au.id = a.author_id
        JOIN favorites f ON a.id = f.artwork_id
        GROUP BY au.name
        ORDER BY count DESC
        LIMIT 10;
    """)).fetchall()

    return {
        "artworks_per_author": [dict(row._mapping) for row in artworks_per_author],
        "popular_artworks": [dict(row._mapping) for row in popular_artworks],
        "popular_authors": [dict(row._mapping) for row in popular_authors],
    }

@router.get("/recent-artworks")
def get_recent_artworks(db: Session = Depends(get_db)):
    result = db.execute(text("""
        SELECT a.id, a.title, a.year, a.image, au.name AS author
        FROM artworks a
        LEFT JOIN authors au ON a.author_id = au.id
        ORDER BY a.id DESC
        LIMIT 5;
    """)).fetchall()

    artworks = [dict(row._mapping) for row in result]
    return artworks

@router.get("/stats")
def get_general_stats(db: Session = Depends(get_db)):
    users_count = db.execute(text("SELECT COUNT(*) FROM users")).scalar()

    artworks_count = db.execute(text("SELECT COUNT(*) FROM artworks")).scalar()

    favorites_count = db.execute(text("SELECT COUNT(*) FROM favorites")).scalar()

    return {
        "users": users_count or 0,
        "artworks": artworks_count or 0,
        "favorites": favorites_count or 0
    }