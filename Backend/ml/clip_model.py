from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import torch
import torch.nn.functional as F
from PIL import ImageEnhance

from sqlalchemy.orm import Session
from models import Artwork

model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

def get_image_embedding(image_path: str):
    image = Image.open(image_path).convert("RGB")
    w, h = image.size
    image = image.crop((w*0.1, h*0.1, w*0.9, h*0.9))

    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(1.2)

    inputs = processor(images=image, return_tensors="pt")

    with torch.no_grad():
        vision_outputs = model.vision_model(pixel_values=inputs["pixel_values"])
        image_features = vision_outputs.pooler_output 

    image_features = image_features / image_features.norm(p=2, dim=-1, keepdim=True)

    return image_features

def cosine_similarity(vec1, vec2):
    return F.cosine_similarity(vec1, vec2).item()

def find_most_similar_db(image_path: str, db: Session):
    query_embedding = get_image_embedding(image_path)

    artworks = db.query(Artwork).all()

    best_match = None
    best_score = -1

    for artwork in artworks:
        if not artwork.embedding:
            continue

        db_embedding = torch.tensor(artwork.embedding)

        score = cosine_similarity(query_embedding, db_embedding)

        if score > best_score:
            best_score = score
            best_match = artwork

    return best_match, best_score

