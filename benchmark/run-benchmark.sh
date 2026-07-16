#!/bin/bash

echo "=================================================="
echo "      WordPress Web Server Benchmark Suite       "
echo "=================================================="

# Function to wait for a service
wait_for_service() {
    local url=$1
    local name=$2
    echo "Waiting for $name ($url) to be ready..."
    until curl -sS --fail "$url" > /dev/null; do
        sleep 2
    done
    echo "$name is ready!"
}

# Wait for all services
wait_for_service "http://ols/readme.html" "OpenLiteSpeed"
wait_for_service "http://nginx/readme.html" "Nginx"
wait_for_service "http://apache/readme.html" "Apache"
wait_for_service "http://caddy/readme.html" "Caddy"

echo "All web servers are up and running!"
sleep 5 # Give them a moment to settle down

RESULTS_DIR="/results"
mkdir -p "$RESULTS_DIR"
RESULT_FILE="$RESULTS_DIR/benchmark_results.md"

echo "Starting benchmarks..."

# Define benchmark parameters
THREADS=2
CONNECTIONS=10
DURATION="15s"

run_wrk() {
    local url=$1
    local name=$2
    local test_type=$3
    
    echo "Running $test_type benchmark on $name..." >&2
    
    # Run wrk and capture output
    local output
    output=$(wrk -t"$THREADS" -c"$CONNECTIONS" -d"$DURATION" "$url")
    
    # Extract metrics using grep/awk
    local req_per_sec
    req_per_sec=$(echo "$output" | grep "Requests/sec:" | awk '{print $2}')
    
    local transfer_per_sec
    transfer_per_sec=$(echo "$output" | grep "Transfer/sec:" | awk '{print $2}')
    
    local avg_latency
    avg_latency=$(echo "$output" | grep "Latency" | awk '{print $2}')
    
    echo "Result for $name ($test_type): $req_per_sec req/sec, Latency: $avg_latency" >&2
    
    # Save raw output
    echo "$output" > "$RESULTS_DIR/${name,,}_${test_type}.txt"
    
    # Return metrics
    echo "$req_per_sec|$avg_latency|$transfer_per_sec"
}

# Run Static Benchmarks (readme.html)
echo "--- Running Static File Benchmarks ---"
ols_static=$(run_wrk "http://ols/readme.html" "OpenLiteSpeed" "static")
nginx_static=$(run_wrk "http://nginx/readme.html" "Nginx" "static")
apache_static=$(run_wrk "http://apache/readme.html" "Apache" "static")
caddy_static=$(run_wrk "http://caddy/readme.html" "Caddy" "static")

# Run Dynamic Benchmarks (index.php)
echo "--- Running Dynamic WordPress Benchmarks ---"
ols_dynamic=$(run_wrk "http://ols/" "OpenLiteSpeed" "dynamic")
nginx_dynamic=$(run_wrk "http://nginx/" "Nginx" "dynamic")
apache_dynamic=$(run_wrk "http://apache/" "Apache" "dynamic")
caddy_dynamic=$(run_wrk "http://caddy/" "Caddy" "dynamic")

# Create markdown table
cat <<EOF > "$RESULT_FILE"
### Static File Benchmark (readme.html)
*Parameters: $THREADS threads, $CONNECTIONS connections, $DURATION duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
|------------|----------------|-------------|----------------|
| **OpenLiteSpeed** | $(echo "$ols_static" | cut -d'|' -f1) | $(echo "$ols_static" | cut -d'|' -f2) | $(echo "$ols_static" | cut -d'|' -f3) |
| **Nginx** | $(echo "$nginx_static" | cut -d'|' -f1) | $(echo "$nginx_static" | cut -d'|' -f2) | $(echo "$nginx_static" | cut -d'|' -f3) |
| **Apache** | $(echo "$apache_static" | cut -d'|' -f1) | $(echo "$apache_static" | cut -d'|' -f2) | $(echo "$apache_static" | cut -d'|' -f3) |
| **Caddy** | $(echo "$caddy_static" | cut -d'|' -f1) | $(echo "$caddy_static" | cut -d'|' -f2) | $(echo "$caddy_static" | cut -d'|' -f3) |

### Dynamic WordPress Benchmark (uncached index.php)
*Parameters: $THREADS threads, $CONNECTIONS connections, $DURATION duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
|------------|----------------|-------------|----------------|
| **OpenLiteSpeed** | $(echo "$ols_dynamic" | cut -d'|' -f1) | $(echo "$ols_dynamic" | cut -d'|' -f2) | $(echo "$ols_dynamic" | cut -d'|' -f3) |
| **Nginx** | $(echo "$nginx_dynamic" | cut -d'|' -f1) | $(echo "$nginx_dynamic" | cut -d'|' -f2) | $(echo "$nginx_dynamic" | cut -d'|' -f3) |
| **Apache** | $(echo "$apache_dynamic" | cut -d'|' -f1) | $(echo "$apache_dynamic" | cut -d'|' -f2) | $(echo "$apache_dynamic" | cut -d'|' -f3) |
| **Caddy** | $(echo "$caddy_dynamic" | cut -d'|' -f1) | $(echo "$caddy_dynamic" | cut -d'|' -f2) | $(echo "$caddy_dynamic" | cut -d'|' -f3) |
EOF

echo "Benchmark complete! Results written to $RESULT_FILE"
