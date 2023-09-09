# Use the official Golang image as the base image
FROM golang:1.20

# Golang variables
ARG GO_VERSION
ARG API_KEY
ARG GO_ENV
ARG GO_PORT

# MongoDB variables
ARG MONGO_PORT
ARG MONGO_IP
ARG MONGO_USER
ARG MONGO_PASSWORD

ENV TZ=Europe/Amsterdam
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install essential packages
RUN apt update && apt upgrade -y && \
    apt install -y curl git openssh-server

RUN apt-get install -y ffmpeg libsm6 libxext6 zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev lzma liblzma-dev

# Set environment variables
ENV GOPATH=/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# Install SSH server
RUN mkdir /var/run/sshd && \
    echo 'root:password' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create .env file with environment variables
RUN echo "# APP DEVELOPMENT ENV" >> .env && \
    echo "GO_PORT = $GO_PORT" >> .env && \
    echo "GO_ENV = $GO_ENV" >> .env && \
    echo >> .env && \
    echo "# API KEY" >> .env && \
    echo "API_KEY = $API_KEY" >> .env && \
    echo >> .env && \
    echo "# MONGODB" >> .env && \
    echo "MONGODB_URL = mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_IP}:${MONGO_PORT}" >> .env

# Copy your Go application source code into the container
COPY ./cloud/app /app

# Build the Go application
WORKDIR /app
RUN go build -o cloud

# Expose port
EXPOSE 8081

# Start SSH and the Go application
CMD service ssh start && ./cloud
