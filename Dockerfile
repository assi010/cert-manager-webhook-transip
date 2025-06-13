FROM --platform=$BUILDPLATFORM golang:1.24.4-alpine AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

ARG TARGETOS
ARG TARGETARCH

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM alpine:3.22.0

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
