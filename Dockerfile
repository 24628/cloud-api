FROM golang:1.20.8
WORKDIR /app
COPY cloud/app/ .

#Get packages
RUN go get -u github.com/gin-gonic/gin

RUN go build -o cloud-api main.go
CMD ["./cloud-api"]