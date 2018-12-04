FROM alpine:3.8
RUN apk add --no-cache --update poppler-utils && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup -h /work
USER appuser
WORKDIR /work
