# Stage 1: Build Stage
FROM python:3.8-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache --virtual .build-deps gcc musl-dev libffi-dev

# Copy and install dependencies to a specific directory
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Production Stage
FROM python:3.8-alpine

WORKDIR /app

# Install runtime dependencies (if needed)
RUN apk add --no-cache libffi

# Copy only the installed dependencies from the builder stage
COPY --from=builder /install /usr/local

# Copy the application code from the local directory to the container
COPY . .

# Define environment variable
ENV NAME=World

# Expose port 5000
EXPOSE 5000

# Run the application using Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--threads", "4", "app:app"]
