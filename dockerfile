# Base image: alpine:3.13
FROM alpine:3.13

WORKDIR /heythella/api

# Install Python 3.8 non-data packages
RUN python=3.8-slim

# Install system dependencies (python3)
RUN pip install --user -t .

# Clean up working directory after build
CMD ["rm", "-rf", "*"]

# Docker Health check
RUN dockerhealth --colors --all-sources --latest

# Run application in non-preemptive container mode
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4"]
