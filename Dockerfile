FROM python:3.7-slim-buster AS base

LABEL maintainer="Eero Ruohola <eero.ruohola@shuup.com>"

# Установка зависимостей
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-dev \
        libpq-dev \
        libffi-dev \
        libssl-dev \
        libpangocairo-1.0-0 \
        gcc \
        curl && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app
COPY . /app

# Установка Python-зависимостей
RUN pip3 install --no-cache-dir \
    markupsafe==2.0.1 \
    django-prometheus \
    shuup \
    psycopg2-binary

# Миграции и инициализация
RUN python3 -m shuup_workbench migrate
RUN python3 -m shuup_workbench shuup_init

# Создание суперпользователя через временный скрипт
RUN echo "from django.contrib.auth import get_user_model\n\
from django.db import IntegrityError\n\
try:\n\
    get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')\n\
except IntegrityError:\n\
    pass" > create_superuser.py && \
    python3 -m shuup_workbench shell < create_superuser.py && \
    rm create_superuser.py

CMD ["python3", "-m", "shuup_workbench", "runserver", "0.0.0.0:8000"]