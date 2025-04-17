FROM node:18-slim AS scraper
WORKDIR /app/src/node

# Install system dependencies from apt.txt
COPY apt.txt .

RUN apt-get update && \
    xargs -a apt.txt apt-get install -y --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*


# Set the environment variable to use the system Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# Copy package.json and install Node dependencies
COPY src/node/package*.json ./

RUN npm install

# Copy the scraper script
COPY src/node/scrape.js ./

# Set environment variable for the URL to scrape (default to example.com)

# Scrape data when the container is run
CMD ["node", "scrape.js"]

# Stage 2: Hosting (Python + Flask)
FROM python:3.10-slim AS hosting

# Install curl
RUN apt-get update && apt-get install -y curl

# Install Poetry (Python's package manager)
RUN curl -sSL https://install.python-poetry.org | python3 - 

# Add Poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set Poetry to create the virtual environment inside the project directory
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

# Set working directory for Python files
WORKDIR /app/src/python

RUN pip install flask
RUN pip install flask requests beautifulsoup4

# Copy the Python dependencies files
COPY pyproject.toml poetry.lock ./

# Install Python dependencies using Poetry
RUN poetry install --no-interaction --no-root

# Copy the scraped data from the previous stage
# Copy the Flask server script
COPY src/python/server.py .

# Expose port for the Flask app
EXPOSE 5000

# Run the Flask server
CMD ["python", "server.py"]
