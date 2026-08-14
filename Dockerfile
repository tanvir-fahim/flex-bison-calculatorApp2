FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    python3 \
    gcc \
    flex \
    bison \
    && rm -rf /var/lib/apt-lists/*

WORKDIR /app
COPY . .

ENV PORT=8080
EXPOSE 8080

CMD ["python3", "server.py"]