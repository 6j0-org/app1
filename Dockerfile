FROM python:3.9-slim

LABEL org.opencontainers.image.description="Demo python app"

WORKDIR /app

COPY api/app.py .
COPY requirements.txt .

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
