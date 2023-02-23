###############################################
# Base Image
###############################################
FROM python:3.11.2-bullseye as base

WORKDIR /app

#RUN adduser guest && groupadd guestgroup && usermod -aG guestgroup guest
RUN useradd --user-group --system --create-home --no-log-init guest

RUN groups guest

#you need curl if you use alpine base image as it is a lighter version. Otherwise, this line will remain commented.
#RUN apk --no-cache add curl

ENV PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    #non root user's bin has to be attached to path variable in order to run any command as nonroot user
    PATH="/home/guest/.local/bin:${PATH}" \ 
    PYTHONPATH="$PYTHONPATH:/app/src"

###############################################
# Builder Image
###############################################
FROM base as builder

#line 33 to line 39 is for assigning nonroot user to app directory.
WORKDIR /app

USER root

RUN chown -R guest /app/

USER guest

WORKDIR /app

RUN pip install --upgrade pip

#the poetry version here should match with the verison in pyproject.toml
RUN pip install "poetry==1.3.2"

#mandatory files to be copied to run poetry install
COPY --chown=guest:guest pyproject.toml poetry.lock README.md docker-entrypoint.sh ./

#copy all the contents under 'src' and paste it under a new target folder 'src' in docker image
COPY --chown=guest:guest /src ./src

#run poetry install
RUN poetry install --only=main --no-root && poetry build

###############################################
# Final Image
###############################################
FROM base as final

WORKDIR /app

COPY --from=builder /app ./
#COPY --chown=guest:guest --from=builder /app ./
#COPY --chown=nonroot:nonroot --from=builder /app/dist ./dist
#COPY --chown=nonroot:nonroot --from=builder /app/.venv ./.venv
#COPY --chown=nonroot:nonroot docker-entrypoint.sh ./

CMD ["sh","./docker-entrypoint.sh"]