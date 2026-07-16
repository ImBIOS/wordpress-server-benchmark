### Static File Benchmark (readme.html)
*Parameters: 2 threads, 10 connections, 15s duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
|------------|----------------|-------------|----------------|
| **OpenLiteSpeed** | 5793.65 | 9.65ms | 42.28MB |
| **Nginx** | 5622.76 | 10.43ms | 41.00MB |
| **Apache** | 2034.14 | 18.64ms | 14.86MB |
| **Caddy** | 3025.06 | 9.98ms | 22.08MB |

### Dynamic WordPress Benchmark (uncached index.php)
*Parameters: 2 threads, 10 connections, 15s duration*

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec |
|------------|----------------|-------------|----------------|
| **OpenLiteSpeed** | 7.26 | 1.32s | 488.55KB |
| **Nginx** | 7.85 | 1.09s | 528.23KB |
| **Apache** | 3.19 | 1.34s | 216.26KB |
| **Caddy** | 9.37 | 1.04s | 630.07KB |
