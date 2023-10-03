FROM python:3.9-slim-bullseye@sha256:25a976dc387d01af6cb8c419a03e4b553d88ac5152d250920c94553e24cad3c7 as build

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    gcc \
    libpq-dev \
    python3.9-dev\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/app

RUN python -m venv /usr/app/venv
ENV PATH="/usr/app/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install -r requirements.txt

#
# Stage 2
FROM python:3.9-slim-bullseye@sha256:25a976dc387d01af6cb8c419a03e4b553d88ac5152d250920c94553e24cad3c7

RUN useradd -r -u 999 -U django \
    && mkdir /usr/app \
    && chown django:django /usr/app

WORKDIR /usr/app

COPY --chown=django:django --from=build /usr/app/venv ./venv
COPY --chown=django:django ./ .

USER 999

ENV PATH="/usr/app/venv/bin:$PATH"
ENV ALLOWED_HOSTS = "*"
EXPOSE 8000

ENTRYPOINT [ "gunicorn" ]
CMD [ "--worker-tmp-dir", "/dev/shm", "mysite.wsgi" ]
