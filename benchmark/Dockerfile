FROM alpine:latest

# Install wrk, h2load (via nghttp2), curl, bash, and jq
RUN apk add --no-cache wrk nghttp2 curl bash jq

WORKDIR /benchmark

COPY run-benchmark.sh .
RUN chmod +x run-benchmark.sh

CMD ["./run-benchmark.sh"]
