from pydantic import BaseModel
from typing import Optional

class FavoriteCreate(BaseModel):
    user_id: int
    artwork_id: int

class AuthorOut(BaseModel):
    id: int
    name: str
    model_config = {
        "from_attributes": True
    }

class ArtworkOut(BaseModel):
    id: int
    title: str
    title_en: str | None = None
    year: str | None = None
    material: str | None = None
    material_en: str | None = None
    size: str | None = None
    size_en: str | None = None
    description: str | None = None
    description_en: str | None = None
    creation_history: str | None = None
    creation_history_en: str | None = None
    image: str | None = None
    author: AuthorOut | None = None
    model_config = {
        "from_attributes": True
    }

class FavoriteOut(BaseModel):
    id: int
    user_id: int
    artwork_id: int

class FavoriteArtworkOut(BaseModel):
    id: int
    title: str
    image: str | None
    author_name: str | None

    model_config = {
        "from_attributes": True
    }

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    language: str
    photo: bytes | None  

    class Config:
        orm_mode = True

class AuthorBase(BaseModel):
    id: int
    name: str
    portrait_url: str

    model_config = {
        "from_attributes": True  
    }


# ===== Модераторы =====
class ManagerBase(BaseModel):
    full_name: str
    email: str
    access_level: Optional[str] = None

    class Config:
        orm_mode = True


class ManagerCreate(BaseModel):
    full_name: str
    email: str
    password: str
    access_level: Optional[str] = None