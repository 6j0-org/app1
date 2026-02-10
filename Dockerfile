FROM python@3.14.3

# ARG POETRY_HTTP_BASIC_GITLAB_USERNAME

LABEL org.opencontainers.image.description="Demo python app"

WORKDIR /app

COPY api/app.py .
COPY requirements.txt .

RUN pip install -r requirements.txt

# Secrets have to be mounted in the RUN step where they'll be used.
# RUN \
#   --mount=type=secret,id=POETRY_HTTP_BASIC_GITLAB_PASSWORD,env=POETRY_HTTP_BASIC_GITLAB_PASSWORD \
#   poetry install --no-interaction --no-ansi

EXPOSE 5000

CMD ["python", "app.py"]
