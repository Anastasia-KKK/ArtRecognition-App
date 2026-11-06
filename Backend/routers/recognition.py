from fastapi import APIRouter, UploadFile, File
import shutil
import os
from sqlalchemy.orm import Session
from database import SessionLocal
from ml.clip_model import find_most_similar_db


router = APIRouter()

UPLOAD_DIR = "uploads"
THRESHOLD = 0.40

os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/recognize")
async def recognize_image(file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_DIR, file.filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    db: Session = SessionLocal()

    match, score = find_most_similar_db(file_path, db)
    print("SCORE:", score)

    if match is None or score < THRESHOLD:
        return {
        "id": None,
        "message": "Картина не распознана",
        "score": score
        }

    return {
    "id": match.id,
    "title": match.title,
    "score": score
    }   

