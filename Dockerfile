# Stage 1: Builder/Tester

# Slim Images are better if you want to use pandas:
FROM python:3.14-slim AS builder

# ALPINE EXAMPLE:
# FROM python:3.14.2-alpine AS builder
# RUN apk add --no-cache curl

# Use apt-get for Debian-based slim images, removes some unused lists
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Isolate python app and installs from system-level python
RUN python -m venv /opt/venv/
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# COPY local_folder/file container_destination
COPY requirements.txt requirements-test.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ ./app

# --- Stage 2: Tester ---
# Inherits from builder, adds test deps, and runs tests
FROM builder AS tester
COPY requirements-test.txt .
RUN pip install --no-cache-dir -r requirements-test.txt

# Copy everything needed for tests
COPY tests/ ./tests

RUN pytest

# Stage 3: Production
FROM python:3.14-slim AS production

# Install curl for the final stage
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the entire venv from builder (Includes installed dependencies)
COPY --from=builder /opt/venv /opt/venv
# Copy only app code
COPY --from=builder /app/app .

# Ensure the app uses the venv without "activating" it
ENV PATH="/opt/venv/bin:$PATH"
# For FastAPI, adding ENV PYTHONUNBUFFERED=1 ensures logs are sent straight to the terminal without buffering
ENV PYTHONUNBUFFERED=1

# # ALPINE EXAMPLE:
# # Run as non-root user for security, -D :dont assign password
# RUN adduser -D my_user
# USER my_user

# Debian adduser syntax
RUN useradd -m my_user
USER my_user

EXPOSE 8000

CMD ["uvicorn", "main_api:app", "--host", "0.0.0.0", "--port", "8000"]
