FROM golang:1.26-alpine AS builder
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

CMD ["/bin/sh", "-c", "duration=$((5 + RANDOM % 6)); end=$(( $(date +%s) + duration )); while [ $(date +%s) -lt $end ]; do echo \"[worker] tick $RANDOM job=$(printf '%04x' $RANDOM) at $(date -Iseconds)\"; sleep 1; done; if [ $((RANDOM % 4)) -eq 0 ]; then echo \"[worker] task failed\"; exit 1; fi; echo \"[worker] task completed\""]
