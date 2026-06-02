from sqlalchemy import create_engine, Column, Integer, String, Float, ForeignKey, text
from sqlalchemy.orm import declarative_base, sessionmaker
from passlib.context import CryptContext

# --- SECURITY ---
# This tells Python to use the industry-standard bcrypt algorithm
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

# --- INTERNAL CLUSTER CONNECTION ---
# Replace with your actual K8s Postgres credentials
SQLALCHEMY_DATABASE_URL = "postgresql://your_k8s_user:your_k8s_password@my-postgres-postgresql.default.svc.cluster.local:5432/your_db_name"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- TABLES ---
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)  # NEW: The scrambled password
    role = Column(String)

class Policy(Base):
    __tablename__ = "policies"
    id = Column(String, primary_key=True, index=True)
    holder_name = Column(String)
    vehicle = Column(String)
    status = Column(String)

def init_db():
    # Temporarily force drop the old users table so we can add the new password column
    with engine.begin() as conn:
        conn.execute(text("DROP TABLE IF EXISTS users CASCADE"))
        
    # Rebuild the schema
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # Inject the core team with HASHED passwords
    if not db.query(User).first():
        db.add_all([
            User(username="admin", role="Super Admin", hashed_password=get_password_hash("AdminPass2026!")),
            User(username="tier1", role="Tier 1 Assessor", hashed_password=get_password_hash("Tier1Pass2026!")),
            User(username="tier2", role="Tier 2 Support", hashed_password=get_password_hash("Tier2Pass2026!"))
        ])
        db.commit()
    db.close()
