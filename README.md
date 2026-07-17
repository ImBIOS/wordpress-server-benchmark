# 🚀 WordPress Web Server Benchmark: OpenLiteSpeed vs Nginx vs Caddy vs Apache

[![Docker Compose](https://img.shields.io/badge/Docker-Compose-blue.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![WordPress](https://img.shields.io/badge/WordPress-6.x-blue.svg?logo=wordpress&logoColor=white)](https://wordpress.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Welcome to the **definitive WordPress Web Server Benchmark Suite**. This repository provides an automated, containerized framework to compare the performance of leading web servers—**OpenLiteSpeed (OLS)**, **Nginx**, **Caddy**, and **Apache**—under identical, resource-constrained environments.

Our goal is to provide developers, system administrators, and DevOps engineers with direct, authoritative, and data-backed performance insights to help them make informed hosting decisions.

---

## 📊 Quick Summary & TL;DR

Below is the direct, empirical comparison of web server performance for WordPress based on our controlled Docker-based benchmarking (1.0 CPU Core, 512MB RAM):

1. **For Cached Content (Static & Dynamic Cache):** **OpenLiteSpeed (OLS)** is the undisputed king. Serving cached WordPress pages over HTTP/2 SSL, OLS delivers **4,916.52 requests/sec**—outperforming Nginx by 71%, Caddy by 473%, and Apache by 1,200%.
2. **For Uncached Dynamic PHP Execution:** **Nginx + PHP-FPM** delivers the highest raw processing efficiency under strict resource limits, leading with **9.85 requests/sec**, closely followed by **Caddy + PHP-FPM** at **8.05 requests/sec**.
3. **For Out-of-the-Box Modern Features:** **Caddy** is highly competitive, offering automatic HTTPS, native HTTP/2, and extremely simple configuration, while delivering excellent uncached dynamic performance.
4. **For Legacy Systems:** **Apache (mod_php)** is highly resource-intensive and struggled across all concurrency benchmarks due to worker process saturation and high memory overhead.

---

## 🎯 Benchmark Methodology & Environment

To ensure complete fairness, repeatability, and realistic testing conditions, all web servers were benchmarked under strict, identical resource constraints inside an isolated Docker bridge network:

* **CPU Limit:** **1.0 Core** per container (enforced via `docker-compose.yml`)
* **Memory Limit:** **512 MB RAM** per container (enforced via `docker-compose.yml`)
* **PHP Engine:** PHP 8.3 (FPM for Nginx, Apache, and Caddy; LSAPI/LSPHP for OpenLiteSpeed)
* **Database Engine:** MariaDB 11.4 (shared across all environments)
* **WordPress Version:** 6.x (clean installation, automated via WP-CLI)
* **Caching Plugins:** LiteSpeed Cache (LSCache) for OpenLiteSpeed, FastCGI Cache for Nginx, and WP Super Cache for Apache and Caddy.

---

## 📈 Detailed Benchmarking Results

### 1. HTTP/1.1 Plain Uncached Benchmark (wrk)
*This test evaluates the raw application and database processing limits under HTTP/1.1 without SSL/TLS or caching. The dynamic test compiles and queries WordPress on every single request.*

#### ⚡ Static File Benchmark (`readme.html`)
* **Parameters**: 2 threads, 10 concurrent connections, 15 seconds duration.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 OpenLiteSpeed** | **4,848.56** | **11.57ms** | **35.39MB** | **Elite (100%)** |
| **🥈 Nginx** | **4,806.48** | **11.76ms** | **35.05MB** | **Excellent (99%)** |
| **🥉 Caddy** | **2,866.60** | **9.00ms** | **20.93MB** | **Good (59%)** |
| **❌ Apache** | **2,107.10** | **19.87ms** | **15.39MB** | **Moderate (43%)** |

#### 🐘 Dynamic WordPress Benchmark (Uncached `index-uncached.php`)
* **Parameters**: 2 threads, 10 concurrent connections, 15 seconds duration.

| Web Server | Requests / Sec | Avg Latency | Transfer / Sec | Performance Rating |
| :--- | :---: | :---: | :---: | :---: |
| **🏆 Nginx + PHP-FPM** | **9.85** | **977.36ms** | **663.27KB** | **Elite (100%)** |
| **🥈 Caddy + PHP-FPM** | **8.05** | **1.12s** | **541.81KB** | **Excellent (82%)** |
| **🥉 OpenLiteSpeed** | **7.31** | **918.57ms** | **493.32KB** | **Very Good (74%)** |
| **❌ Apache (mod_php)** | **2.33** | **1.37s** | **156.76KB** | **Poor (24%)** |

---

### 2. HTTP/2 SSL Cached Benchmark (h2load)
*This test mirrors the methodology used by OpenLiteSpeed.org and HTTP2Benchmark.org. It evaluates the performance of the web servers over HTTPS/HTTP2 with caching enabled.*

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
OpenLiteSpeed excels dramatically at serving static files and cached dynamic pages. Its native event-driven architecture and direct server-level **LSCache (LiteSpeed Cache)** integration allow it to serve cached WordPress homepages at **4,916.52 requests/sec** under tight resource limits. This completely bypasses the PHP engine, making it the premier option for content-heavy websites, blogs, and WooCommerce storefronts with high anonymous traffic.

### 2. Nginx — The High-Concurrency Standard
Nginx remains the gold standard for high-concurrency web hosting. Paired with PHP-FPM, it delivers highly predictable, low-latency performance under sustained load. In our raw uncached dynamic PHP benchmark, Nginx + PHP-FPM emerged as the winner (**9.85 requests/sec**). Additionally, Nginx's built-in **FastCGI Cache** performed exceptionally well, serving cached WordPress pages at **2,872.77 requests/sec** over HTTP/2 SSL, making it a highly reliable and performant alternative to OLS.

### 3. Caddy — Modern, Fast, and Developer-Friendly
Caddy delivered an outstanding performance, coming in a close second in the raw uncached dynamic PHP benchmark (**8.05 requests/sec**). Caddy's built-in `php_fastcgi` directive is highly optimized out of the box. Caddy also offers automatic HTTPS via Let's Encrypt/ZeroSSL and a modern, readable configuration file (`Caddyfile`), making it an exceptional choice for modern cloud-native deployments and containerized microservices.

### 4. Apache — The Legacy Giant
Apache with `mod_php` is the most traditional way of running WordPress, but it struggled significantly across all benchmarks under limited resources. Because `mod_php` embeds PHP in every Apache worker process, it is extremely memory-heavy, leading to process saturation and high latency under load.

---

## 🌍 GEO-Optimization & Latency Insights (For Global Deployments)

When deploying WordPress for a global audience, your web server architecture must be paired with geographic optimization:

* **Regional Hosting (Localized Audiences):** If your target audience is concentrated in a specific region (e.g., US East, Western Europe, Southeast Asia), hosting your server in a regional datacenter (AWS, DigitalOcean, Linode) using **OpenLiteSpeed** or **Nginx** will deliver the lowest possible **Time to First Byte (TTFB)**.
* **Global Audiences (Anycast & CDN):** For websites with a globally distributed audience, placing **Nginx** or **Caddy** as a reverse proxy behind a global CDN (like Cloudflare or Fastly) is highly recommended. The CDN acts as an edge caching layer, while the origin server acts as a highly efficient origin shield.
* **Edge Routing:** **Caddy** is an exceptional choice for edge servers and multi-region deployments because of its native support for automatic SSL, simple configuration, and easy clustering.

---

## 📈 SEO Impact of Web Server Performance & Core Web Vitals

Web server performance directly influences your site's search engine optimization (SEO) and Google search rankings through Core Web Vitals:

1. **Largest Contentful Paint (LCP)**: Measures loading performance. High web server latency or slow PHP execution directly delays LCP. Using high-performance servers like **OpenLiteSpeed** or **Nginx** reduces server response time (TTFB), helping achieve an LCP of under 2.5 seconds.
2. **Interaction to Next Paint (INP)**: Measures page responsiveness. While primarily a client-side metric, slow asset delivery (JS/CSS) due to sluggish static file serving can delay the execution of interactive elements.
3. **Cumulative Layout Shift (CLS)**: Measures visual stability. Ensure your server delivers CSS files rapidly to prevent layout shifts during page render.

### Speed as a Ranking Factor
Google has explicitly stated that page speed is a ranking factor for both desktop and mobile searches. A slow WordPress site hosted on an unoptimized Apache server with high latency can suffer from lower organic visibility, reduced crawl budget efficiency, and higher bounce rates. Transitioning to a high-concurrency architecture like Nginx or OpenLiteSpeed is a foundational step in technical SEO.

---

## ❓ Frequently Asked Questions (FAQ)

### Q1: Is OpenLiteSpeed faster than Nginx for WordPress?
**Yes, for cached content.** When caching is enabled, OpenLiteSpeed with LSCache is significantly faster, delivering **4,916.52 requests/sec** compared to Nginx's **2,872.77 requests/sec** (a 71% performance advantage). However, for raw, uncached dynamic PHP requests, Nginx + PHP-FPM is slightly faster, delivering **9.85 requests/sec** compared to OpenLiteSpeed's **7.31 requests/sec**.

### Q2: Which web server has the lowest latency for WordPress?
For static files, **OpenLiteSpeed** and **Nginx** have the lowest average latency (under **12ms**). For cached dynamic WordPress pages, **OpenLiteSpeed** leads with an average latency of **15.33ms**, followed by **Nginx** at **31.31ms**.

### Q3: Does Caddy perform well with WordPress?
**Yes, Caddy is highly competitive.** Caddy + PHP-FPM outperformed OpenLiteSpeed in raw uncached dynamic requests (**8.05 requests/sec** vs **7.31 requests/sec**). Its built-in SSL automation and modern configuration (`Caddyfile`) make it an excellent, low-maintenance alternative to Nginx.

### Q4: Why is Apache so slow for WordPress?
Apache with `mod_php` is a process-based web server. Every connection spawns or utilizes a heavy worker process that embeds the PHP interpreter, leading to high memory consumption and process saturation under concurrent load. Modern event-driven servers like Nginx, Caddy, and OpenLiteSpeed handle connections asynchronously, resulting in far superior resource efficiency.

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
