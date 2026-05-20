from typing import List

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

import auth as auth_utils
from database import Base, engine, get_db
from models import MedicationModel, UserModel
from schemas import (
    LoginRequest,
    MedicationRequest,
    MedicationResponse,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="MedBox API")

bearer = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer),
    db: Session = Depends(get_db),
) -> UserModel:
    payload = auth_utils.decode_token(credentials.credentials)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Недійсний токен"
        )
    user = db.query(UserModel).filter(UserModel.email == payload.get("sub")).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Користувача не знайдено"
        )
    return user


@app.post("/auth/register", response_model=TokenResponse, status_code=201)
def register(body: RegisterRequest, db: Session = Depends(get_db)):
    if db.query(UserModel).filter(UserModel.email == body.email).first():
        raise HTTPException(status_code=400, detail="Email вже використовується")
    user = UserModel(
        name=body.name,
        email=body.email,
        hashed_password=auth_utils.hash_password(body.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    token = auth_utils.create_access_token(
        {"sub": user.email, "name": user.name}
    )
    return TokenResponse(access_token=token)


@app.post("/auth/login", response_model=TokenResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.email == body.email).first()
    if user is None or not auth_utils.verify_password(body.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Невірний email або пароль")
    token = auth_utils.create_access_token(
        {"sub": user.email, "name": user.name}
    )
    return TokenResponse(access_token=token)


@app.get("/auth/me", response_model=UserResponse)
def me(current_user: UserModel = Depends(get_current_user)):
    return current_user


@app.get("/medications", response_model=List[MedicationResponse])
def get_medications(
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return (
        db.query(MedicationModel)
        .filter(MedicationModel.user_email == current_user.email)
        .all()
    )


@app.post("/medications", response_model=MedicationResponse, status_code=201)
def add_medication(
    body: MedicationRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    med = MedicationModel(**body.model_dump(), user_email=current_user.email)
    db.add(med)
    db.commit()
    db.refresh(med)
    return med


@app.put("/medications/{med_id}", response_model=MedicationResponse)
def update_medication(
    med_id: str,
    body: MedicationRequest,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    med = db.query(MedicationModel).filter(
        MedicationModel.id == med_id,
        MedicationModel.user_email == current_user.email,
    ).first()
    if med is None:
        raise HTTPException(status_code=404, detail="Ліки не знайдено")
    for field, value in body.model_dump().items():
        setattr(med, field, value)
    db.commit()
    db.refresh(med)
    return med


@app.delete("/medications/{med_id}", status_code=204)
def delete_medication(
    med_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    med = db.query(MedicationModel).filter(
        MedicationModel.id == med_id,
        MedicationModel.user_email == current_user.email,
    ).first()
    if med is None:
        raise HTTPException(status_code=404, detail="Ліки не знайдено")
    db.delete(med)
    db.commit()
