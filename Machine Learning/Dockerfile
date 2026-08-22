FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app/src \
    HOST=0.0.0.0 \
    PORT=8080 \
    HF_HOME=/app/.cache/huggingface

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./

# Inference is CPU only. The default PyPI torch drags in ~3.5 GB of CUDA and
# Triton wheels, which blows the build out of Render's disk and time budget.
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu torch && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get purge -y --auto-remove build-essential

# Bake the MiniLM encoder into the image; otherwise every cold start downloads
# it from the Hugging Face hub unauthenticated, and boot fails when it 429s.
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"

COPY src/ ./src/

# Only the served weights - the per-epoch checkpoints next to it are ~870 MB.
# Not in git by design, so this image must be built where model.pt exists.
COPY model/model.pt ./model/model.pt

EXPOSE $PORT

CMD exec uvicorn recipe_ml.api.app:app --host "$HOST" --port "$PORT" --workers 1
