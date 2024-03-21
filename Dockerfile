FROM golang:1.21-alpine AS builder
RUN apk add git
WORKDIR /src
ENV CGO_ENABLED=0
COPY go.* ./
RUN go mod download
COPY . ./
RUN --mount=type=cache,target=/root/.cache/go-build go build -o go-echo-quickstart .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
RUN update-ca-certificates

# Add binary
WORKDIR /app/
COPY --from=builder /src/go-echo-quickstart ./

ENV PORT=8080
EXPOSE 8080

CMD ["/app/go-echo-quickstart"]
