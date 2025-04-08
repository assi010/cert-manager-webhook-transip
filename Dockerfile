FROM golang:1.23.2-alpine AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build
ARG TARGETPLATFORM

COPY . .

RUN GOOS=linux \
    GOARCH=$(case ${TARGETPLATFORM:-linux/amd64} in \
                   "linux/amd64")   echo "x86_64"  ;; \
                   "linux/arm/v7")  echo "armhf"   ;; \
                   "linux/arm64")   echo "aarch64" ;; \
                   *)               echo ""        ;; esac) \
    CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.20.3

# UID of the non-root user 'app'
ENV APP_UID=1654

# Create a non-root user and group
RUN addgroup \
        --gid=$APP_UID \
        app \
    && adduser \
        --uid=$APP_UID \
        --ingroup=app \
        --disabled-password \
        app

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

USER $APP_UID
ENTRYPOINT ["webhook"]
