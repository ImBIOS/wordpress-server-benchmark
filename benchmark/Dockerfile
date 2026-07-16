FROM alpine:latest

# Install wrk, curl, bash, and jq
RUN apk add --no-cache wrk curl bash jq

WORKDIR /benchmark

COPY run-benchmark.sh .
RUN chmod +x run-benchmark.sh

CMD ["./run-benchmark.sh"]
