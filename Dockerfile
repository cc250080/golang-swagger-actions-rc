FROM alpine:3.15 as root-certs
RUN apk add -U --no-cache ca-certificates
RUN addgroup -g 1001 app
RUN adduser app -u 1001 -D -G app /home/app

FROM golang:1.17 as builder
WORKDIR /app
COPY --from=root-certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY . .
RUN cp swagger /go/bin/
RUN go generate go-rest-api/internal go-rest-api/pkg/swagger
RUN go build -o bin/go-rest-api internal/main.go

FROM debian:latest as final
COPY --from=root-certs /etc/passwd /etc/passwd
COPY --from=root-certs /etc/group /etc/group
COPY --chown=1001:1001 --from=root-certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --chown=1001:1001 --from=builder /app/bin/go-rest-api /go-rest-api
COPY --chown=1001:1001 --from=builder /app/ /app/
USER app
ENTRYPOINT ["/go-rest-api"]
