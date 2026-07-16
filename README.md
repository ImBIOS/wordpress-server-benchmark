# 🚀 WordPress Web Server Benchmark Suite (Docker-Based)

[![Docker Compose](https://img.shields.io/badge/Docker-Compose-blue.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![WordPress](https://img.shields.io/badge/WordPress-6.x-blue.svg?logo=wordpress&logoColor=white)](https://wordpress.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An **SEO-optimized** and **GEO-optimized** automated benchmarking suite designed to evaluate and compare the performance of leading web servers capable of running WordPress under identical, highly controlled environments.

This project spins up fully isolated, resource-limited Docker containers for **OpenLiteSpeed (OLS)**, **Nginx**, **Apache (mod_php)**, and **Caddy**, installs a clean instance of WordPress for each, and runs performance benchmarks using `wrk` inside a dedicated benchmarking container.

---

## 🎯 Benchmark Results

The following benchmarks were conducted inside a resource-limited Docker bridge network environment. Each web server and PHP-FPM container was limited to **1.0 CPU Core** and **512MB RAM** to ensure fair, repeatable, and realistic testing conditions.

---

### 1. HTTP/1.1 Plain Uncached Benchmark (wrk)
*This test evaluates the raw performance of the web servers under HTTP/1.1 without SSL/TLS overhead or caching. The dynamic test compiles and queries WordPress on every single hit.*

#### ⚡ Static File Benchmark (`readme.html`)
* **Parameters**: 2 threads, 10 concurrent connections, 15 seconds duration.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 OpenLiteSpeed** | **4,848.56** | **11.57ms** | **35.39MB** | **Elite (100%)** |
| **🥈 Nginx** | **4,806.48** | **11.76ms** | **35.05MB** | **Excellent (99%)** |
| **🥉 Caddy** | **2,866.60** | **9.00ms** | **20.93MB** | **Good (59%)** |
| **❌ Apache** | **2,107.10** | **19.87ms** | **15.39MB** | **Moderate (43%)** |

#### 🐘 Dynamic WordPress Benchmark (Uncached `index.php`)
* **Parameters**: 2 threads, 10 concurrent connections, 15 seconds duration.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 Nginx + PHP-FPM** | **9.85** | **977.36ms** | **663.27KB** | **Elite (100%)** |
| **🥈 Caddy + PHP-FPM** | **8.05** | **1.12s** | **541.81KB** | **Excellent (82%)** |
| **🥉 OpenLiteSpeed** | **7.31** | **918.57ms** | **493.32KB** | **Very Good (74%)** |
| **❌ Apache (mod_php)** | **2.33** | **1.37s** | **156.76KB** | **Poor (24%)** |

---

### 2. HTTP/2 SSL Cached Benchmark (h2load)
*This test mirrors the methodology used by OpenLiteSpeed.org and HTTP2Benchmark.org. It evaluates the performance of the web servers over HTTPS/HTTP2 with caching enabled. OpenLiteSpeed uses LSCache, Nginx uses FastCGI Cache, and Apache/Caddy use WP Super Cache.*

#### ⚡ Static File Benchmark (`readme.html`)
* **Parameters**: 5000 requests, 20 concurrent clients, 2 threads, 5 max streams.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 OpenLiteSpeed** | **8,809.24** | **8.89ms** | **62.53MB** | **Elite (100%)** |
| **🥈 Nginx** | **4,125.11** | **19.15ms** | **29.64MB** | **Excellent (47%)** |
| **🥉 Caddy** | **2,376.04** | **40.62ms** | **16.87MB** | **Good (27%)** |
| **❌ Apache** | **1,564.31** | **38.19ms** | **11.43MB** | **Moderate (18%)** |

#### 🐘 Dynamic WordPress Benchmark (Cached `index.php`)
* **Parameters**: 5000 requests, 20 concurrent clients, 2 threads, 5 max streams.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 OpenLiteSpeed + LSCache** | **4,916.52** | **15.33ms** | **322.45MB** | **Elite (100%)** |
| **🥈 Nginx + FastCGI Cache** | **2,872.77** | **31.31ms** | **188.54MB** | **Excellent (58%)** |
| **🥉 Caddy + WP Super Cache** | **857.91** | **115.52ms** | **56.29MB** | **Good (17%)** |
| **❌ Apache + WP Super Cache** | **378.29** | **218.55ms** | **24.93MB** | **Poor (8%)** |

---

## 🔍 Key Architectural Insights

### 1. OpenLiteSpeed (OLS) — The Static & Caching King
OpenLiteSpeed excels dramatically at serving static files due to its event-driven architecture and highly optimized kernel-level sendfile operations. In production, OLS is usually paired with the **LSCache (LiteSpeed Cache)** plugin, which bypasses PHP entirely for cached pages. This makes it an incredibly strong contender for content-heavy sites and blogs.

### 2. Nginx — The High-Concurrency Standard
Nginx remains the gold standard for high-concurrency web hosting. Paired with PHP-FPM, it delivers highly predictable, low-latency performance under sustained load. In our raw uncached dynamic PHP benchmark, Nginx + PHP-FPM emerged as the winner (9.85 req/sec). Its static file serving is also extremely fast, almost identical to OpenLiteSpeed.

### 3. Caddy — Modern, Fast, and Developer-Friendly
Caddy delivered an outstanding performance, coming in a close second in the raw uncached dynamic PHP benchmark (8.05 req/sec)! Caddy's built-in `php_fastcgi` directive is highly optimized out of the box. Caddy also offers automatic HTTPS via Let's Encrypt/ZeroSSL and a modern, readable configuration file (`Caddyfile`).

### 4. Apache — The Legacy Giant
Apache with `mod_php` is the most traditional way of running WordPress, but it struggled significantly in both static and dynamic benchmarks under limited resources. Because `mod_php` embeds PHP in every Apache worker process, it is extremely memory-heavy, leading to process saturation and high latency under load.

---

## 🌍 GEO-Optimization & Latency Considerations

When choosing a web server for global WordPress hosting, your geographic architecture is just as important as your server choice:

* **Regional US/EU/Asia Hosting**: If your target audience is concentrated in a specific region (e.g., US East, Western Europe, Southeast Asia), hosting your server in a regional datacenter (AWS, DigitalOcean, Linode) using **OpenLiteSpeed** or **Nginx** will deliver the lowest possible **Time to First Byte (TTFB)**.
* **Global Audiences (Anycast & CDN)**: For websites with a globally distributed audience, pairing **Nginx** or **Caddy** as a reverse proxy behind a global CDN (like Cloudflare or Fastly) is highly recommended.
* **Edge Routing**: **Caddy** is an exceptional choice for edge servers and multi-region deployments because of its native support for automatic SSL and easy clustering.

---

## SEO Impact of Server Performance & Core Web Vitals

Web server performance directly influences your site's search engine optimization (SEO) and Google search rankings through Core Web Vitals:

1. **Largest Contentful Paint (LCP)**: Measures loading performance. High web server latency or slow PHP execution directly delays LCP. Using high-performance servers like **OpenLiteSpeed** or **Nginx** reduces server response time (TTFB), helping achieve an LCP of under 2.5 seconds.
2. **Interaction to Next Paint (INP)**: Measures page responsiveness. While primarily a client-side metric, slow asset delivery (JS/CSS) due to sluggish static file serving can delay the execution of interactive elements.
3. **Cumulative Layout Shift (CLS)**: Measures visual stability. Ensure your server delivers CSS files rapidly to prevent layout shifts during page render.

### Speed as a Ranking Factor
Google has explicitly stated that page speed is a ranking factor for both desktop and mobile searches. A slow WordPress site hosted on an unoptimized Apache server with high latency can suffer from lower organic visibility, reduced crawl budget efficiency, and higher bounce rates. Transitioning to a high-concurrency architecture like Nginx or OpenLiteSpeed is a foundational step in technical SEO.

---

## 🛠️ Project Structure

```
├── apache/               # Apache Dockerfile & virtual host config
├── benchmark/            # Benchmarking container (wrk, h2load, bash scripts)
│   └── results/          # Raw benchmark outputs (.txt & .md)
├── caddy/                # Caddyfile configuration
├── db/                   # Database initialization scripts (init.sql)
├── nginx/                # Nginx virtual host configuration
├── php-fpm/              # Shared PHP-FPM Dockerfile & Opcache settings
├── wordpress_ols/        # Isolated WordPress directory for OpenLiteSpeed
├── wordpress_nginx/      # Isolated WordPress directory for Nginx
├── wordpress_apache/     # Isolated WordPress directory for Apache
├── wordpress_caddy/      # Isolated WordPress directory for Caddy
├── docker-compose.yml
├── setup.sh         # Host setup script (downloads WP, configures wp-config.php)
└── setup-wp.sh      # Automated WordPress installer script (runs WP-CLI)
```

---

## 🚀 Quick Start (Run Your Own Benchmarks)

Follow these simple steps to spin up the entire suite and run the benchmarks on your local machine or server.

### Prerequisites
* Docker and Docker Compose installed.
* Ports `8081`, `8082`, `8083`, and `8084` available on your host.

### Step 1: Initialize the Project
Download WordPress core and configure the dynamic `wp-config.php` file:
```bash
./setup.sh
```

### Step 2: Start Services & Install WordPress
Spin up the containers and run the automated WordPress installations using WP-CLI:
```bash
./setup-wp.sh
```

### Step 3: Run the Benchmarks
Run the dedicated benchmarking container to execute the tests and update the results:
```bash
docker compose run --rm benchmarker
```

Your raw benchmark outputs and formatted Markdown table will be written directly to `./benchmark/results/`.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
