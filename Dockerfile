FROM golang:1.19.13-alpine3.18
WORKDIR /app
COPY . .
ENV USER=appuser
ENV UID=10001
RUN apk update && apk upgrade && \
    apk add --no-cache \
    git ca-certificates tzdata
RUN update-ca-certificates
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"
RUN go build -ldflags \
    '-w -s -extldflags "-static"' \
    -a -o application main.go

FROM scratch
ENV USER=appuser
COPY --from=0 /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=0 /etc/passwd /etc/passwd
COPY --from=0 /etc/group /etc/group
WORKDIR /app
COPY --from=0 /app ./
USER appuser
CMD ["./application"]

