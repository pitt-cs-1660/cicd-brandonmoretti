FROM python:3.11-buster as builder

WORKDIR /app

RUN pip install --upgrade pip && pip install poetry

COPY pyproject.toml /app
COPY poetry.lock /app

RUN poetry config virtualenvs.create false \
  && poetry install --no-root --no-interaction --no-ansi

FROM python:3.11-buster as app

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

#COPY --from=builder /app /app
COPY entrypoint.sh /app/entrypoint.sh  

EXPOSE 8000

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]

CMD [ "uvicorn", "cc_compose.server:app", "--reload", "--host", "0.0.0.0", "--port", "8000" ]