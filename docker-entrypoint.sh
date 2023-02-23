#!/bin/bash
ls -la

echo "python path is" $PYTHONPATH
#the below line can also be executed as 'source .venv/bin/activate'. However,
#'source' may not be available in all the shells. So, we are using '. .venv/bin/activate'
#for more info, https://stackoverflow.com/questions/11027782/virtualenv-venv-bin-activate-vs-source-venv-bin-activate

. .venv/bin/activate  && which python

python src/routes/app.py

exec "$@"
#exec gunicorn --bind 0.0.0.0:5000 --forwarded-allow-ips='*' wsgi:app