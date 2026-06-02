from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import database

# Create tables and inject the initial admin user on startup
database.init_db()

app = FastAPI(title="BrightPath Backend API")

# Allow Flutter apps to communicate with this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/health")
def health_check():
    return {"status": "Backend is live on the Beelink cluster!"}

@app.get("/api/users")
def get_users(db: Session = Depends(get_db)):
    users = db.query(database.User).all()
    return {"users": users}
