"""Request/response models for the API."""

from typing import List, Optional

from pydantic import BaseModel, Field


class RecommendRequest(BaseModel):
    ingredients: str = Field(..., description="Ingredients, comma separated or free text")
    k: Optional[int] = Field(5, ge=1, le=50, description="How many recipes to return")


class EmbedResponse(BaseModel):
    status: str
    recipe_id: str
    dim: int
    embedding: List[float]


class HealthResponse(BaseModel):
    status: str
    database: str
    model_weights: str
