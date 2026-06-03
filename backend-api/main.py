from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from typing import Optional
from pydantic import BaseModel

# Import your newly separated modules
import database
import models
import auth

# Initialize the database on startup
models.Base.metadata.create_all(bind=database.engine)

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

class UserLogin(BaseModel):
    username: str
    password: str

class UserUpdate(BaseModel):
    username: Optional[str] = None
    password: Optional[str] = None
    role: Optional[str] = None

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

# 1. READ ALL USERS (Protected: Only Super Admins and Tier 1 can view the user list)
@app.get("/api/users", dependencies=[Depends(auth.RoleChecker([models.UserRole.super_admin, models.UserRole.tier_1]))])
def get_users(db: Session = Depends(database.get_db)):
    users = db.query(models.User).all()
    return {"users": [{"id": u.id, "username": u.username, "role": u.role} for u in users]}


# 2. ADD A NEW USER (Protected: Only Super Admins can create staff accounts)
@app.post("/api/users", status_code=status.HTTP_201_CREATED, dependencies=[Depends(auth.RoleChecker([models.UserRole.super_admin]))])
def create_user(user: UserCreate, db: Session = Depends(database.get_db)):
    existing_user = db.query(models.User).filter(models.User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username is already taken")
    
    # Hash the password automatically using the function from auth.py
    hashed_pw = auth.get_password_hash(user.password)
    new_user = models.User(username=user.username, hashed_password=hashed_pw, role=user.role)
    
    db.add(new_user)
    db.commit()
    return {"message": "User created successfully", "username": new_user.username}


# 3. EDIT AN EXISTING USER (Protected: Only Super Admins can edit accounts)
@app.put("/api/users/{user_id}", dependencies=[Depends(auth.RoleChecker([models.UserRole.super_admin]))])
def update_user(user_id: int, user_update: UserUpdate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user_update.username:
        conflict = db.query(models.User).filter(models.User.username == user_update.username).first()
        if conflict and conflict.id != user_id:
            raise HTTPException(status_code=400, detail="Username is already taken")
        db_user.username = user_update.username

    if user_update.password:
        db_user.hashed_password = auth.get_password_hash(user_update.password)
        
    if user_update.role:
        db_user.role = user_update.role
        
    db.commit()
    db.refresh(db_user)
    return {"message": "User updated successfully", "username": db_user.username}


# 4. DELETE A USER (Protected: Only Super Admins can delete accounts)
@app.delete("/api/users/{user_id}", dependencies=[Depends(auth.RoleChecker([models.UserRole.super_admin]))])
def delete_user(user_id: int, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    db.delete(db_user)
    db.commit()
    return {"message": f"User '{db_user.username}' deleted successfully"}


# 5. USER LOGIN (Open: Anyone can attempt to log in)
@app.post("/api/login")
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.get_db)):
    # 1. Authenticate the user via the auth module
    user = auth.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    # 2. Inject the role into the token data payload
    access_token = auth.create_access_token(
        data={
            "sub": user.username, # Make sure this matches how you look up users in auth.py
            "role": user.role.value 
        }
    )
    
    # 3. Return the token
    return {"access_token": access_token, "token_type": "bearer", "role": user.role.value}