FROM python:3.10.2-alpine as builder
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ARG WORKDIR

WORKDIR ./$WORKDIR
COPY ./Pipfile ./

RUN apk add gcc python3-dev musl-dev jpeg-dev zlib-dev libjpeg

RUN mkdir ./.venv
RUN pip install pipenv
RUN pipenv install --skip-lock


FROM python:3.10.2-alpine as runner
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ARG WORKDIR
ARG PORT

RUN apk add geos gdal

WORKDIR ./$WORKDIR
COPY --from=builder ./$WORKDIR/.venv ./.venv
COPY . .

ENV VIRTUAL_ENV=./.venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

EXPOSE $PORT

ENTRYPOINT ./docker/start-server.sh
