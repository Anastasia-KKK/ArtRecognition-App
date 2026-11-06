from sqlalchemy import *
from database import *
from sqlalchemy.orm import relationship
from sqlalchemy import ForeignKey
from sqlalchemy.dialects.postgresql import JSON

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    photo = Column(LargeBinary, nullable=True)
    language = Column(String(10), nullable=True)

class Artwork(Base):
    __tablename__ = "artworks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    title_en = Column(String)
    author_id = Column(Integer, ForeignKey("authors.id"))
    year = Column(String)
    material = Column(String)
    material_en = Column(String)
    size = Column(String)
    size_en = Column(String)
    description = Column(Text)
    description_en = Column(Text)
    creation_history = Column(Text)
    creation_history_en = Column(Text)
    image = Column(String)  
    author = relationship("Author")
    embedding = Column(JSON, nullable=True)

class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    artwork_id = Column(Integer, ForeignKey("artworks.id"), nullable=False)

    artwork = relationship("Artwork")
    user = relationship("User")

class Author(Base):
    __tablename__ = "authors"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255))
    years_of_life = Column(String(100))
    biography = Column(ARRAY(Text))
    interesting_facts = Column(ARRAY(Text))
    name_en = Column(String(255))
    biography_en = Column(ARRAY(Text))
    interesting_facts_en = Column(ARRAY(Text))
    portrait_url = Column(Text)

class ContentManager(Base):
    __tablename__ = "content_managers"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password = Column(Text, nullable=False)
    access_level = Column(String(100), nullable=True)

class Administrator(Base):
    __tablename__ = "admins" 

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False)
    password = Column(Text, nullable=False)
    access_level = Column(String(100), nullable=True)