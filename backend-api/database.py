from sqlalchemy import create_engine, Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker

# --- INTERNAL CLUSTER CONNECTION ---
# Replace 'your_k8s_user', 'your_k8s_password', and 'your_db_name' 
# with the actual credentials you used when creating the Postgres pod.
SQLALCHEMY_DATABASE_URL = "postgresql://postgres:Jun3082014!@my-postgres-postgresql.default.svc.cluster.local:5432/insurance_db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- TABLES ---
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    role = Column(String)

class Policy(Base):
    __tablename__ = "policies"
    id = Column(String, primary_key=True, index=True)
    holder_name = Column(String)
    vehicle = Column(String)
    status = Column(String)

def init_db():
    # Add this line to wipe the old conflicting tables
    Base.metadata.drop_all(bind=engine) 
    
    # Now it will recreate them with the correct columns
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # Inject one Super Admin if the database is empty
    if not db.query(User).first():
        db.add(User(username="admin_user", role="Super Admin"))
        db.commit()
    db.close()
