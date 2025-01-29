FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt requirements.txt
COPY app.py /app/

# Create a non-root user and set ownership for the entire directory
RUN addgroup -S appgroup && adduser -S appuser -G appgroup \
    && chown -R appuser:appgroup /app


RUN pip install --no-cache-dir -r requirements.txt

# Switch to non-root user
USER appuser

CMD ["python", "/app/app.py"]
