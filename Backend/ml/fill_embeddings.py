from sqlalchemy.orm import Session
from database import SessionLocal
from models import Artwork
from ml.clip_model import get_image_embedding

def fill_embeddings():
    db: Session = SessionLocal()

    artworks = db.query(Artwork).all()

    for artwork in artworks:
        if artwork.embedding:
            continue

        print(f"Обрабатываю: {artwork.title}")

        try:
            embedding = get_image_embedding(artwork.image)
            artwork.embedding = embedding.tolist()
        except Exception as e:
            print(f"Ошибка: {e}")

    db.commit()
    db.close()


if __name__ == "__main__":
    fill_embeddings()