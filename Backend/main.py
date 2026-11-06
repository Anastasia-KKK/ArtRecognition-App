from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from routers import (
    auth_router,
    users_router,
    artworks_router,
    authors_router,
    favorites_router,
    managers_router,
    admin_router,
    admin_users_router,
    admin_auth_router,
    recognition,
)

app = FastAPI(title="Art Recognition API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(auth_router.router, prefix="/auth")
app.include_router(users_router.router, prefix="/users")
app.include_router(artworks_router.router, prefix="/artworks")
app.include_router(authors_router.router, prefix="/authors")
app.include_router(favorites_router.router, prefix="/favorites")
app.include_router(managers_router.router, prefix="/managers")
app.include_router(admin_router.router, prefix="/admin")
app.include_router(admin_users_router.router, prefix="/admin")
app.include_router(admin_auth_router.router, prefix="/admin")
app.include_router(recognition.router)