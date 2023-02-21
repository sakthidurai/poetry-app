###############################################
# Base Image
###############################################
FROM python:3.11.2-alpine3.17 as base

WORKDIR /app

#alpine is a slim version and will not have curl.
RUN apk --no-cache add curl

ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true

###############################################
# builder Image
###############################################
FROM base as builder

RUN pip install --upgrade pip

#the poetry version here should match with the verison in pyproject.toml
RUN pip install "poetry==1.3.2"

#mandatory files to be copied to run poetry install
COPY pyproject.toml poetry.lock README.md docker-entrypoint.sh ./

#copy all the contents under 'src' and paste it under a new target folder 'src' in docker image
COPY /src ./src

#run poetry install
RUN poetry install --only=main --no-root && poetry build

###############################################
# Final Image
###############################################
FROM base as final

#setup python path to enable all the python modules 
ENV PYTHONPATH="$PYTHONPATH:/app/src"

COPY --from=builder /app ./
#COPY --chown=nonroot:nonroot --from=builder /app/dist ./dist
#COPY --chown=nonroot:nonroot --from=builder /app/.venv ./.venv
#COPY --chown=nonroot:nonroot docker-entrypoint.sh ./

RUN ls -la

RUN echo $PYTHONPATH

CMD ["sh","./docker-entrypoint.sh"]