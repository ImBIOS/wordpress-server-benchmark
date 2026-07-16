# 📊 Detailed Benchmarking Results

These benchmarks were executed inside isolated, resource-limited Docker containers.
* **CPU Limit**: 1.0 Core per service
* **Memory Limit**: 512MB per service

---

## 1. HTTP/1.1 Plain Uncached Benchmark (wrk)
*This test evaluates the raw performance of the web servers under HTTP/1.1 without SSL/TLS overhead or caching. The dynamic test compiles and queries WordPress on every single hit.*

### ⚡ Static File Benchmark (readme.html)
*Parameters: 2 threads, 10 connections, 15s duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **OpenLiteSpeed** | 4848.56 | 11.57ms | 35.39MB |
| **Nginx** | 4806.48 | 11.76ms | 35.05MB |
| **Caddy** | 2866.60 | 9.00ms | 20.93MB |
| **Apache** | 2107.10 | 19.87ms | 15.39MB |

### 🐘 Dynamic WordPress Benchmark (Uncached index.php)
*Parameters: 2 threads, 10 connections, 15s duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **Caddy + PHP-FPM** | 8.05 | 1.12s | 541.81KB |
| **Nginx + PHP-FPM** | 9.85 | 977.36ms | 663.27KB |
| **OpenLiteSpeed** | 7.31 | 918.57ms | 493.32KB |
| **Apache (mod_php)** | 2.33 | 1.37s | 156.76KB |

---

## 2. HTTP/2 SSL Cached Benchmark (h2load)
*This test mirrors the methodology used by OpenLiteSpeed.org and HTTP2Benchmark.org. It evaluates the performance of the web servers over HTTPS/HTTP2 with caching enabled. OpenLiteSpeed uses LSCache, Nginx uses FastCGI Cache, and Apache/Caddy use WP Super Cache.*

### ⚡ Static File Benchmark (readme.html)
*Parameters: 5000 requests, 20 concurrent clients, 2 threads, 5 max streams*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **OpenLiteSpeed** | 8809.24 | 8.89ms | 62.53MB/s |
| **Nginx** | 4125.11 | 19.15ms | 29.64MB/s |
| **Caddy** | 2376.04 | 40.62ms | 16.87MB/s |
| **Apache** | 1564.31 | 38.19ms | 11.43MB/s |

### 🐘 Dynamic WordPress Benchmark (Cached index.php)
*Parameters: 5000 requests, 20 concurrent clients, 2 threads, 5 max streams*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
| :--- | :---: | :---: | :---: |
| **OpenLiteSpeed** | 4916.52 | 15.33ms | 322.45MB/s |
| **Nginx** | 2872.77 | 31.31ms | 188.54MB/s |
| **Caddy** | 857.91 | 115.52ms | 56.29MB/s |
| **Apache** | 378.29 | 218.55ms | 24.93MB/s |
