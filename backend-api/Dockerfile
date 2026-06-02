# Use a lightweight Python 3.11 environment
FROM python:3.11-slim

# Tell the container where our code will live
WORKDIR /app

# Copy the requirements and install them securely
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your Python files
COPY . .

# Open port 8000 for FastAPI
EXPOSE 8000

# The command to start the server
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
