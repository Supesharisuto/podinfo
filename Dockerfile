FROM golang:1.14-alpine as builder

ARG REVISION

RUN mkdir -p /microservice-template/

WORKDIR /microservice-template

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 go build -ldflags "-s -w \
    -X github.com/Supesharisuto/microservice-template/pkg/version.REVISION=${REVISION}" \
    -a -o bin/microservice-template cmd/microservice-template/*

RUN CGO_ENABLED=0 go build -ldflags "-s -w \
    -X github.com/Supesharisuto/microservice-template/pkg/version.REVISION=${REVISION}" \
    -a -o bin/podcli cmd/podcli/*

FROM alpine:3.12

ARG BUILD_DATE
ARG VERSION
ARG REVISION

LABEL maintainer="stefanprodan" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/Supesharisuto/microservice-template" \
  org.opencontainers.image.source="https://github.com/Supesharisuto/microservice-template" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$REVISION \
  org.opencontainers.image.vendor="stefanprodan" \
  org.opencontainers.image.title="microservice-template" \
  org.opencontainers.image.description="Go microservice template for Kubernetes" \
  org.opencontainers.image.licenses="MIT"

RUN addgroup -S app \
    && adduser -S -g app app \
    && apk --no-cache add \
    ca-certificates curl netcat-openbsd

WORKDIR /home/app

COPY --from=builder /microservice-template/bin/microservice-template .
COPY --from=builder /microservice-template/bin/podcli /usr/local/bin/podcli
COPY ./ui ./ui
RUN chown -R app:app ./

USER app

CMD ["./microservice-template"]
