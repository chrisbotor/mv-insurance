from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel
import database

# Initialize the database on startup
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

# --- SCHEMAS (What the API expects to receive) ---
class UserCreate(BaseModel):
    username: str
    password: str
    role: str

class UserUpdate(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    role: Optional[str] = None

# --- DATABASE DEPENDENCY ---
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- SYSTEM ROUTES ---
@app.get("/", include_in_schema=False)
def read_root():
    return RedirectResponse(url="/docs")

@app.get("/health")
def health_check():
    return {"status": "Backend is live on the Beelink cluster!"}

# ==========================================
#         USER MANAGEMENT (CRUD)
# ==========================================

# 1. READ ALL USERS
@app.get("/api/users")
def get_users(db: Session = Depends(get_db)):
    users = db.query(database.User).all()
    # We return the list, but strictly exclude the hashed passwords for security
    return {"users": [{"id": u.id, "username": u.username, "role": u.role} for u in users]}

# 2. ADD A NEW USER
@app.post("/api/users", status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    existing_user = db.query(database.User).filter(database.User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username is already taken")
    
    # Hash the password automatically
    hashed_pw = database.get_password_hash(user.password)
    new_user = database.User(username=user.username, hashed_password=hashed_pw, role=user.role)
    
    db.add(new_user)
    db.commit()
    return {"message": "User created successfully", "username": new_user.username}

# 3. EDIT AN EXISTING USER
@app.put("/api/users/{user_id}")
def update_user(user_id: int, user_update: UserUpdate, db: Session = Depends(get_db)):
    db_user = db.query(database.User).filter(database.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user_update.username:
        conflict = db.query(database.User).filter(database.User.username == user_update.username).first()
        if conflict and conflict.id != user_id:
            raise HTTPException(status_code=400, detail="Username is already taken")
        db_user.username = user_update.username

    # If a new password is provided, hash it before saving
    if user_update.password:
        db_user.hashed_password = database.get_password_hash(user_update.password)
        
    if user_update.role:
        db_user.role = user_update.role
        
    db.commit()
    db.refresh(db_user)
    return {"message": "User updated successfully", "username": db_user.username}

# 4. DELETE A USER
@app.delete("/api/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db)):
    db_user = db.query(database.User).filter(database.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    db.delete(db_user)
    db.commit()
    return {"message": f"User '{db_user.username}' deleted successfully"}
