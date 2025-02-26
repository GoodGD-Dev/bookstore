# `python-base` sets up all our shared environment variables
FROM python:3.8.1-slim as python-base

    # python
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    \
    # poetry
    POETRY_VERSION=1.5.1 \
    # make poetry install to this location
    POETRY_HOME="/opt/poetry" \
    # make poetry create the virtual environment in the project's root
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential

# Instalar Poetry de forma mais robusta
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME python3 - && \
    ln -s $POETRY_HOME/bin/poetry /usr/local/bin/poetry && \
    poetry config virtualenvs.create false

RUN apt-get update \
    && apt-get -y install libpq-dev gcc \
    && pip install psycopg2

WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./

# Instalar todas as dependências do projeto
RUN poetry install --no-dev

# Instalar todas as dependências (incluindo as de desenvolvimento)
RUN poetry install

WORKDIR /app
COPY . /app/

# Garantir que o Django e outras dependências essenciais estejam instaladas
RUN pip install django gunicorn psycopg2-binary

# Adicionar coleta de arquivos estáticos
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "bookstore.wsgi:application", "--bind", "0.0.0.0:8000"]

