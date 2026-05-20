from sqlalchemy import Column, Integer, String

from database import Base


class UserModel(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)


class MedicationModel(Base):
    __tablename__ = "medications"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    time = Column(String, nullable=False)
    status = Column(String, nullable=False, default="pending")
    user_email = Column(String, nullable=False, index=True)
    day = Column(Integer, nullable=False, default=0)
