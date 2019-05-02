FROM golang:1.11-alpine as builder

WORKDIR /go
COPY . .

RUN go build goapp.go

FROM alpine:3.9

RUN mkdir -p /usr/lib/src/
COPY --from=builder /go/goapp /usr/lib/src/goapp
RUN chmod +x /usr/lib/src/goapp

COPY ./sample.json /app/sample/sample.json
WORKDIR /usr/lib/src
EXPOSE 80

CMD ["./goapp"]