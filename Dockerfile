# Stage 1: Build Stage
FROM python:3.8.10-alpine AS builder

ENV APP_HOME=/app
WORKDIR $APP_HOME

# Copy requirements first for better caching
COPY requirements.txt .

# Install build dependencies and Python packages
RUN apk add --no-cache --virtual .build-deps gcc musl-dev libffi-dev \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt \
    && apk del .build-deps

# Stage 2: Production Stage
FROM python:3.8.10-alpine

ENV APP_HOME=/app
WORKDIR $APP_HOME

# Install runtime dependencies
RUN apk add --no-cache libffi

# Copy installed dependencies from builder stage
COPY --from=builder /install /usr/local

# Copy application code
COPY . .

# Use non-root user
RUN adduser -D orange
USER orange

# Expose port 5000
EXPOSE 5000

# Set the label with the correct format
LABEL org.opencontainers.image.source="https://github.com/abdelrahman18036/library-inventory-team3"

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "app:app"]