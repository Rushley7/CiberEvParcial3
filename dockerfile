FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python create_db.py

EXPOSE 5000

ENV FLASK_DEBUG=false

CMD ["python", "vulnerable_app.py"]