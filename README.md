# 🚀 WordPress Web Server Benchmark Suite (Docker-Based)

[![Docker Compose](https://img.shields.io/badge/Docker-Compose-blue.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![WordPress](https://img.shields.io/badge/WordPress-6.x-blue.svg?logo=wordpress&logoColor=white)](https://wordpress.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

An **SEO-optimized** and **GEO-optimized** automated benchmarking suite designed to evaluate and compare the performance of leading web servers capable of running WordPress under identical, highly controlled environments.

This project spins up fully isolated, resource-limited Docker containers for **OpenLiteSpeed (OLS)**, **Nginx**, **Apache (mod_php)**, and **Caddy**, installs a clean instance of WordPress for each, and runs performance benchmarks using `wrk` inside a dedicated benchmarking container.

---

## 🎯 Benchmark Results

The following benchmarks were conducted inside a resource-limited Docker bridge network environment. Each web server and PHP-FPM container was limited to **1.0 CPU Core** and **512MB RAM** to ensure fair, repeatable, and realistic testing conditions.

### ⚡ Static File Benchmark (`readme.html`)
*This test evaluates the raw web server performance when serving static assets (HTML, CSS, JS, images) without invoking PHP or MariaDB.*
* **Parameters**: 2 threads, 10 concurrent connections, 15 seconds duration.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 OpenLiteSpeed** | **5,793.65** | **9.65ms** | **42.28MB** | **Elite (100%)** |
| **🥈 Nginx** | **5,622.76** | **10.43ms** | **41.00MB** | **Excellent (97%)** |
| **🥉 Caddy** | **3,025.06** | **9.98ms** | **22.08MB** | **Good (52%)** |
| **❌ Apache** | **2,034.14** | **18.64ms** | **14.86MB** | **Moderate (35%)** |

---

### 🐘 Dynamic WordPress Benchmark (Uncached `index.php`)
*This test measures the raw performance of the web server's PHP and Database integration by loading the fully dynamic, uncached WordPress homepage.*
* **Parameters**: 2 threads, 10 concurrent connections, 15 seconds duration.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 Caddy + PHP-FPM** | **9.37** | **1.04s** | **630.07KB** | **Elite (100%)** |
| **🥈 Nginx + PHP-FPM** | **7.85** | **1.09s** | **528.23KB** | **Excellent (84%)** |
| **🥉 OpenLiteSpeed** | **7.26** | **1.32s** | **488.55KB** | **Very Good (77%)** |
| **❌ Apache (mod_php)** | **3.19** | **1.34s** | **216.26KB** | **Poor (34%)** |

---

## 🔍 Key Architectural Insights

### 1. OpenLiteSpeed (OLS) — The Static & Caching King
OpenLiteSpeed excels dramatically at serving static files due to its event-driven architecture and highly optimized kernel-level sendfile operations. In production, OLS is usually paired with the **LSCache (LiteSpeed Cache)** plugin, which bypasses PHP entirely for cached pages. This makes it an incredibly strong contender for content-heavy sites and blogs.

### 2. Nginx — The High-Concurrency Standard
Nginx remains the gold standard for high-concurrency web hosting. Paired with PHP-FPM, it delivers highly predictable, low-latency performance under sustained load. Its static file serving is almost identical to OpenLiteSpeed, making it a robust and versatile choice for any WordPress setup.

### 3. Caddy — Modern, Fast, and Developer-Friendly
Caddy surprised us by winning the raw uncached dynamic PHP benchmark! Caddy's built-in `php_fastcgi` directive is highly optimized out of the box. Caddy also offers automatic HTTPS via Let's Encrypt/ZeroSSL and a modern, readable configuration file (`Caddyfile`).

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
├── apache/          # Apache Dockerfile & virtual host config
├── benchmark/       # Benchmarking container (wrk, bash scripts)
│   └── results/     # Raw wrk benchmark outputs (.txt & .md)
├── caddy/           # Caddyfile configuration
├── db/              # Database initialization scripts (init.sql)
├── nginx/           # Nginx virtual host configuration
├── php-fpm/         # Shared PHP-FPM Dockerfile & Opcache settings
├── wordpress/       # WordPress core directory (downloaded during setup)
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
