from pydantic import BaseModel


class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: int
    name: str
    email: str

    model_config = {"from_attributes": True}


class MedicationRequest(BaseModel):
    id: str
    name: str
    time: str
    status: str
    day: int = 0


class MedicationResponse(BaseModel):
    id: str
    name: str
    time: str
    status: str
    day: int = 0

    model_config = {"from_attributes": True}
