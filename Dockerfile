# =============================================================================
# Dockerfile for Protoknox RAG Prototype
# Multi-stage build for optimized image size
# =============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Base - Python environment with system dependencies
# -----------------------------------------------------------------------------
FROM python:3.11-slim as base

# Set environment variables
# PYTHONUNBUFFERED: Ensures Python output is sent straight to terminal (useful for logging)
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Set working directory inside container
WORKDIR /app

# Install system dependencies
# - build-essential: C compiler for some Python packages
# - curl: For health checks and downloading
# - git: For some Python packages that might need it
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Stage 2: Dependencies - Install Python packages
# -----------------------------------------------------------------------------
FROM base as dependencies

# Copy only requirements first (for better layer caching)
# If requirements.txt doesn't change, Docker reuses this layer
COPY requirements.txt .

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# -----------------------------------------------------------------------------
# Stage 3: Development - Full development environment
# -----------------------------------------------------------------------------
FROM dependencies as development

# Copy application code
# This happens AFTER installing dependencies, so code changes don't trigger dependency reinstall
COPY src/ ./src/
COPY tests/ ./tests/

# Create directories for data and logs
RUN mkdir -p /app/data/raw /app/data/processed /app/logs

# Expose port (if we add a web interface later)
EXPOSE 8000

# Default command for development
# This can be overridden in docker-compose.yml
CMD ["python", "-m", "src.main"]

# -----------------------------------------------------------------------------
# Stage 4: Production - Minimal production image (future use)
# -----------------------------------------------------------------------------
FROM dependencies as production

# Copy only necessary application code
COPY src/ ./src/

# Create non-root user for security
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Create directories
RUN mkdir -p /app/data /app/logs

# Expose port
EXPOSE 8000

# Production command
CMD ["python", "-m", "src.main"]

# =============================================================================
# Build Instructions:
#
# Development build:
#   docker build --target development -t protoknox:dev .
#
# Production build:
#   docker build --target production -t protoknox:prod .
#
# Or use docker-compose (recommended):
#   docker-compose up --build
# =============================================================================
