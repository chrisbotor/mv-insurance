import enum
from sqlalchemy import Column, Integer, String, Boolean, Enum
from database import Base

# Define the exact roles allowed in the system for RBAC
class UserRole(str, enum.Enum):
    super_admin = "super_admin"
    tier_1 = "tier_1"
    tier_2 = "tier_2"
    client = "client"

# Define the User table schema
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    
    # Defaults to 'client' so external web signups are safely restricted
    role = Column(Enum(UserRole), default=UserRole.client)