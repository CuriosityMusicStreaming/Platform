FROM golang:1.16

ADD setup-image.sh /app/

WORKDIR /app

RUN setup-image.sh