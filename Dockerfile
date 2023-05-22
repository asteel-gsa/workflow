FROM python:3.10-slim AS builder

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN apt-get -y update
RUN apt-get -y install git

# RUN --mount=type=cache,target=/root/.cache \

WORKDIR ..

RUN \
    apt-get update && \
    apt-get install -yqq apt-transport-https wget gnupg2


RUN \
    set -ex && \
    pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    pip install -r /tmp/dev-requirements.txt && \
    rm -rf /root/.cache/

RUN \
    apt-get install -yqq groff && \
    apt-get install -yqq zip && \
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && \
    unzip awscli-bundle.zip && \
    ./awscli-bundle/install -b /usr/local/bin/aws

COPY package.* /src/
WORKDIR /src/

RUN npm install
RUN chown -R 1001:123 "/root/.npm"

COPY . /src/

RUN npm run build && python manage.py collectstatic

# ------------------------------------------------------------
# Dev/testing layer
# ------------------------------------------------------------

FROM builder AS release

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
