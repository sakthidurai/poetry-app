#!/bin/bash

source .venv/bin/activate  && which python
python src/hello/routes/app.py
exec "$@"
#exec gunicorn --bind 0.0.0.0:5000 --forwarded-allow-ips='*' wsgi:app