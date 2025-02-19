# FROM python:3.13.2-slim-bookworm
FROM python@sha256:ae9f9ac89467077ed1efefb6d9042132d28134ba201b2820227d46c9effd3174

LABEL org.opencontainers.image.description="Demo python app"

WORKDIR /app

COPY api/app.py .
COPY requirements.txt .

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
