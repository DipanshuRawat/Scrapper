FROM node:18-slim AS scraper
WORKDIR /app/src/node

# Install system dependencies from apt.txt
COPY apt.txt .

RUN apt-get update && \
    xargs -a apt.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*


# Set the environment variable to use the system Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

COPY src/node/package*.json ./

RUN npm install

COPY src/node/scrape.js ./

CMD ["node", "scrape.js"]

# Stage 2: Hosting (Python + Flask)
FROM python:3.10-slim AS hosting

RUN apt-get update && apt-get install -y curl

# Install Poetry (Python's package manager)
RUN curl -sSL https://install.python-poetry.org | python3 - 

ENV PATH="/root/.local/bin:$PATH"

ENV POETRY_VIRTUALENVS_IN_PROJECT=true

WORKDIR /app/src/python

RUN pip install flask

RUN pip install flask requests beautifulsoup4

COPY pyproject.toml poetry.lock ./

# Install Python dependencies using Poetry
RUN poetry install --no-interaction --no-root

COPY src/python/server.py .

EXPOSE 5000

CMD ["python", "server.py"]
