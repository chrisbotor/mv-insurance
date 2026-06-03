from typing import List
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .database import get_db
from .models import User, UserRole

# Your token endpoint URL
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/login")

# -------------------------------------------------------------------
# PASTE YOUR EXISTING SECURITY FUNCTIONS HERE:
# verify_password(), get_password_hash(), create_access_token()
# -------------------------------------------------------------------

# Your existing function that validates the token
async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    # ... your existing logic that decodes the JWT and queries the DB ...
    pass

async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# The new Role Bouncer
def RoleChecker(allowed_roles: List[UserRole]):
    def require_role(current_user: User = Depends(get_current_active_user)):
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action."
            )
        return current_user
    return require_role