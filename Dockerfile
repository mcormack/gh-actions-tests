FROM python:3.14.2-alpine AS builder

RUN apk add --no-cache curl

# Isolate python app and installs from system-level python
RUN python -m venv /opt/venv/

WORKDIR /app

# COPY local_folder/file container_destination
COPY requirements.txt /tmp/requirements.txt

# RUN within_container_while_building
RUN pip install -r /tmp/requirements.txt

COPY app/ .

EXPOSE 8000

CMD ["uvicorn", "main_api:app", "--host", "0.0.0.0", "--port", "8000"]
