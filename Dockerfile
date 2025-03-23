FROM golang:1.23 AS compile

WORKDIR /usr/src/app

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app ./...

FROM alpine:latest AS compressor
RUN apk add --no-cache upx
COPY --from=compile /app /app
RUN upx --best /app

FROM scratch AS service

COPY --from=compile /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=compressor /app .

ENTRYPOINT ["/app"]
