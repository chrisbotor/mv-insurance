from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Update this string with your exact Postgres credentials
SQLALCHEMY_DATABASE_URL = "postgresql://postgres:Jun3082014!@my-postgres-postgresql/insurance_db"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# This is the dependency we will inject into our routes to talk to the DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()