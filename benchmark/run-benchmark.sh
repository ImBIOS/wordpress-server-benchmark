#!/bin/bash

echo "=================================================="
echo "      WordPress Web Server Benchmark Suite       "
echo "=================================================="

# Function to wait for a service (HTTP)
wait_for_service() {
    local url=$1
    local name=$2
    echo "Waiting for $name ($url) to be ready..."
    until curl -sS --fail "$url" > /dev/null; do
        sleep 2
    done
    echo "$name is ready!"
}

# Function to wait for a service (HTTPS)
wait_for_service_https() {
    local url=$1
    local name=$2
    echo "Waiting for $name HTTPS ($url) to be ready..."
    until curl -k -sS --fail "$url" > /dev/null; do
        sleep 2
    done
    echo "$name HTTPS is ready!"
}

# Wait for all services (HTTP)
wait_for_service "http://ols/readme.html" "OpenLiteSpeed"
wait_for_service "http://nginx/readme.html" "Nginx"
wait_for_service "http://apache/readme.html" "Apache"
wait_for_service "http://caddy/readme.html" "Caddy"

# Wait for all services (HTTPS)
wait_for_service_https "https://ols/readme.html" "OpenLiteSpeed HTTPS"
wait_for_service_https "https://nginx/readme.html" "Nginx HTTPS"
wait_for_service_https "https://apache/readme.html" "Apache HTTPS"
wait_for_service_https "https://caddy/readme.html" "Caddy HTTPS"

echo "All web servers are up and running on HTTP and HTTPS!"
sleep 5 # Give them a moment to settle down

RESULTS_DIR="/results"
mkdir -p "$RESULTS_DIR"
RESULT_FILE="$RESULTS_DIR/benchmark_results.md"

echo "Starting benchmarks..."

# ---------------------------------------------------------
# Method A: HTTP/1.1 Plain Uncached Benchmark (wrk)
# ---------------------------------------------------------
THREADS=2
CONNECTIONS=10
DURATION="15s"

run_wrk() {
    local url=$1
    local name=$2
    local test_type=$3
    
    echo "Running HTTP/1.1 $test_type benchmark on $name..." >&2
    
    # Run wrk and capture output
    local output
    output=$(wrk -t"$THREADS" -c"$CONNECTIONS" -d"$DURATION" "$url")
    
    # Extract metrics
    local req_per_sec
    req_per_sec=$(echo "$output" | grep "Requests/sec:" | awk '{print $2}')
    
    local transfer_per_sec
    transfer_per_sec=$(echo "$output" | grep "Transfer/sec:" | awk '{print $2}')
    
    local avg_latency
    avg_latency=$(echo "$output" | grep "Latency" | awk '{print $2}')
    
    echo "Result for $name ($test_type HTTP/1.1): $req_per_sec req/sec, Latency: $avg_latency" >&2
    
    # Save raw output
    echo "$output" > "$RESULTS_DIR/${name,,}_${test_type}.txt"
    
    # Return metrics
    echo "$req_per_sec|$avg_latency|$transfer_per_sec"
}

echo "--- Running HTTP/1.1 Static File Benchmarks ---"
ols_static=$(run_wrk "http://ols/readme.html" "OpenLiteSpeed" "static")
nginx_static=$(run_wrk "http://nginx/readme.html" "Nginx" "static")
apache_static=$(run_wrk "http://apache/readme.html" "Apache" "static")
caddy_static=$(run_wrk "http://caddy/readme.html" "Caddy" "static")

echo "--- Running HTTP/1.1 Dynamic WordPress Benchmarks (Uncached) ---"
ols_dynamic=$(run_wrk "http://ols/index-uncached.php" "OpenLiteSpeed" "dynamic")
nginx_dynamic=$(run_wrk "http://nginx/index-uncached.php" "Nginx" "dynamic")
apache_dynamic=$(run_wrk "http://apache/index-uncached.php" "Apache" "dynamic")
caddy_dynamic=$(run_wrk "http://caddy/index-uncached.php" "Caddy" "dynamic")


# ---------------------------------------------------------
# Method B: HTTP/2 SSL Cached Benchmark (h2load)
# ---------------------------------------------------------
H2_REQUESTS=5000
H2_CLIENTS=20
H2_THREADS=2
H2_STREAMS=5

run_h2load() {
    local url=$1
    local name=$2
    local test_type=$3
    
    echo "Running HTTP/2 $test_type benchmark on $name..." >&2
    
    # Run h2load and capture output
    local output
    output=$(h2load -n"$H2_REQUESTS" -c"$H2_CLIENTS" -t"$H2_THREADS" -m"$H2_STREAMS" "$url")
    
    # Extract metrics
    local line
    line=$(echo "$output" | grep "finished in")
    local req_per_sec
    req_per_sec=$(echo "$line" | awk '{print $4}')
    
    local transfer_per_sec
    transfer_per_sec=$(echo "$line" | awk '{print $6}')
    
    local latency_line
    latency_line=$(echo "$output" | grep -E "^request\s+:")
    local avg_latency
    avg_latency=$(echo "$latency_line" | awk '{print $8}')
    
    echo "Result for $name ($test_type HTTP/2): $req_per_sec req/sec, Latency: $avg_latency" >&2
    
    # Save raw output
    echo "$output" > "$RESULTS_DIR/${name,,}_h2_${test_type}.txt"
    
    # Return metrics
    echo "$req_per_sec|$avg_latency|$transfer_per_sec"
}

echo "--- Running HTTP/2 SSL Static File Benchmarks ---"
ols_h2_static=$(run_h2load "https://ols/readme.html" "OpenLiteSpeed" "static")
nginx_h2_static=$(run_h2load "https://nginx/readme.html" "Nginx" "static")
apache_h2_static=$(run_h2load "https://apache/readme.html" "Apache" "static")
caddy_h2_static=$(run_h2load "https://caddy/readme.html" "Caddy" "static")

echo "--- Running HTTP/2 SSL Dynamic WordPress Benchmarks (Cached) ---"
echo "Priming caches for all servers..." >&2
curl -k -sS "https://ols/" > /dev/null
curl -k -sS "https://nginx/" > /dev/null
curl -k -sS "https://apache/" > /dev/null
curl -k -sS "https://caddy/" > /dev/null
sleep 2

ols_h2_dynamic=$(run_h2load "https://ols/" "OpenLiteSpeed" "dynamic")
nginx_h2_dynamic=$(run_h2load "https://nginx/" "Nginx" "dynamic")
apache_h2_dynamic=$(run_h2load "https://apache/" "Apache" "dynamic")
caddy_h2_dynamic=$(run_h2load "https://caddy/" "Caddy" "dynamic")


# ---------------------------------------------------------
# Compile Results into Markdown Table
# ---------------------------------------------------------
cat <<EOF > "$RESULT_FILE"
# 📊 Detailed Benchmarking Results

These benchmarks were executed inside isolated, resource-limited Docker containers.
* **CPU Limit**: 1.0 Core per service
* **Memory Limit**: 512MB per service

---

## 1. HTTP/1.1 Plain Uncached Benchmark (wrk)
*This test evaluates the raw performance of the web servers under HTTP/1.1 without SSL/TLS overhead or caching. The dynamic test compiles and queries WordPress on every single hit.*

### ⚡ Static File Benchmark (readme.html)
*Parameters: $THREADS threads, $CONNECTIONS connections, $DURATION duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **OpenLiteSpeed** | $(echo "$ols_static" | cut -d'|' -f1) | $(echo "$ols_static" | cut -d'|' -f2) | $(echo "$ols_static" | cut -d'|' -f3) |
| **Nginx** | $(echo "$nginx_static" | cut -d'|' -f1) | $(echo "$nginx_static" | cut -d'|' -f2) | $(echo "$nginx_static" | cut -d'|' -f3) |
| **Caddy** | $(echo "$caddy_static" | cut -d'|' -f1) | $(echo "$caddy_static" | cut -d'|' -f2) | $(echo "$caddy_static" | cut -d'|' -f3) |
| **Apache** | $(echo "$apache_static" | cut -d'|' -f1) | $(echo "$apache_static" | cut -d'|' -f2) | $(echo "$apache_static" | cut -d'|' -f3) |

### 🐘 Dynamic WordPress Benchmark (Uncached index.php)
*Parameters: $THREADS threads, $CONNECTIONS connections, $DURATION duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **Caddy + PHP-FPM** | $(echo "$caddy_dynamic" | cut -d'|' -f1) | $(echo "$caddy_dynamic" | cut -d'|' -f2) | $(echo "$caddy_dynamic" | cut -d'|' -f3) |
| **Nginx + PHP-FPM** | $(echo "$nginx_dynamic" | cut -d'|' -f1) | $(echo "$nginx_dynamic" | cut -d'|' -f2) | $(echo "$nginx_dynamic" | cut -d'|' -f3) |
| **OpenLiteSpeed** | $(echo "$ols_dynamic" | cut -d'|' -f1) | $(echo "$ols_dynamic" | cut -d'|' -f2) | $(echo "$ols_dynamic" | cut -d'|' -f3) |
| **Apache (mod_php)** | $(echo "$apache_dynamic" | cut -d'|' -f1) | $(echo "$apache_dynamic" | cut -d'|' -f2) | $(echo "$apache_dynamic" | cut -d'|' -f3) |

---

## 2. HTTP/2 SSL Cached Benchmark (h2load)
*This test mirrors the methodology used by OpenLiteSpeed.org and HTTP2Benchmark.org. It evaluates the performance of the web servers over HTTPS/HTTP2 with caching enabled. OpenLiteSpeed uses LSCache, Nginx uses FastCGI Cache, and Apache/Caddy use WP Super Cache.*

### ⚡ Static File Benchmark (readme.html)
*Parameters: $H2_REQUESTS requests, $H2_CLIENTS concurrent clients, $H2_THREADS threads, $H2_STREAMS max streams*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **OpenLiteSpeed** | $(echo "$ols_h2_static" | cut -d'|' -f1) | $(echo "$ols_h2_static" | cut -d'|' -f2) | $(echo "$ols_h2_static" | cut -d'|' -f3) |
| **Nginx** | $(echo "$nginx_h2_static" | cut -d'|' -f1) | $(echo "$nginx_h2_static" | cut -d'|' -f2) | $(echo "$nginx_h2_static" | cut -d'|' -f3) |
| **Caddy** | $(echo "$caddy_h2_static" | cut -d'|' -f1) | $(echo "$caddy_h2_static" | cut -d'|' -f2) | $(echo "$caddy_h2_static" | cut -d'|' -f3) |
| **Apache** | $(echo "$apache_h2_static" | cut -d'|' -f1) | $(echo "$apache_h2_static" | cut -d'|' -f2) | $(echo "$apache_h2_static" | cut -d'|' -f3) |

### 🐘 Dynamic WordPress Benchmark (Cached index.php)
*Parameters: $H2_REQUESTS requests, $H2_CLIENTS concurrent clients, $H2_THREADS threads, $H2_STREAMS max streams*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **OpenLiteSpeed** | $(echo "$ols_h2_dynamic" | cut -d'|' -f1) | $(echo "$ols_h2_dynamic" | cut -d'|' -f2) | $(echo "$ols_h2_dynamic" | cut -d'|' -f3) |
| **Nginx** | $(echo "$nginx_h2_dynamic" | cut -d'|' -f1) | $(echo "$nginx_h2_dynamic" | cut -d'|' -f2) | $(echo "$nginx_h2_dynamic" | cut -d'|' -f3) |
| **Caddy** | $(echo "$caddy_h2_dynamic" | cut -d'|' -f1) | $(echo "$caddy_h2_dynamic" | cut -d'|' -f2) | $(echo "$caddy_h2_dynamic" | cut -d'|' -f3) |
| **Apache** | $(echo "$apache_h2_dynamic" | cut -d'|' -f1) | $(echo "$apache_h2_dynamic" | cut -d'|' -f2) | $(echo "$apache_h2_dynamic" | cut -d'|' -f3) |
EOF

echo "Benchmark complete! Results written to $RESULT_FILE"
