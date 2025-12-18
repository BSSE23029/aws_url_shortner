Here is the **comprehensive** System Architecture Overview. This document ties everything together—connecting the Frontend, Backend, and Networking layers into a single cohesive picture. It highlights the specific design decisions made for the semester project environment.

Save this as `01_System_Architecture_Overview_Detailed.md`.

---

```markdown
# 🏗️ System Architecture Overview: Rad Link

**Project Name:** Rad Link (URL Shortener & Analytics Platform)
**Architecture Style:** Cloud-Native Serverless
**Infrastructure Provider:** AWS (Academy Learner Lab)
**Region:** `us-east-1` (N. Virginia)

---

## 1. Executive Summary

**Rad Link** is a high-performance URL shortening service that differentiates itself through **"Radical Transparency"**. Unlike traditional shorteners that only show user-specific stats, Rad Link features a **"Stupidity Dashboard"**—a real-time visualization of system-wide usage, including global OS wars (Android vs iOS), geographic traffic heatmaps, and total platform throughput.

The system is built on a **Serverless First** principle, utilizing AWS Lambda and DynamoDB to handle burst traffic with zero idle costs. The Frontend is a reactive **Flutter Web** application designed with a Cyber/Glassmorphism aesthetic.

---

## 2. High-Level Topology

```mermaid
[User Browser]  <--->  [Flutter App]
       |
       | (HTTPS Requests)
       v
[Route 53 DNS] (api.razasoft.tech)
       |
       v
[AWS API Gateway] (HTTP API v2)
       |
       +---(Auth Check)---> [Amazon Cognito]
       |
       v
[AWS Lambda] (Monolithic Logic Node.js 20.x)
       |
       +---(Geo Lookup)---> [External API: ip-api.com]
       |
       v
[Amazon DynamoDB] (Single Table Design)
```

---

## 3. Core Architecture Constraints (Academy Specific)

This architecture was adapted to fit the specific permissions and budget of the AWS Academy Learner Lab environment:

1. **Direct API Gateway Access:**

   * *Standard Approach:* Use CloudFront to cache API responses and frontend assets.
   * *Our Approach:* The Flutter App talks **directly** to API Gateway via a custom domain (`api.razasoft.tech`). This simplifies invalidation and deployment.
2. **No Frontend Hosting (S3/CloudFront):**

   * *Standard Approach:* Host Flutter Web build in S3 behind CloudFront.
   * *Our Approach:* The Flutter build is run locally or on a standard web server for grading, as Academy S3 bucket policies often block public website hosting.
3. **Client-Side Geo-Location (Lambda):**

   * *Standard Approach:* Use `CloudFront-Viewer-Country` headers.
   * *Our Approach:* Since we bypassed CloudFront, the Lambda performs a real-time IP lookup against `ip-api.com` with a strict **400ms timeout circuit breaker** to ensure redirects remain fast.

---

## 4. Key Subsystems

### A. The "Mega-Sync" Engine (Frontend-Backend Bridge)

To ensure the dashboard feels "Instant", we avoid "Chatty APIs" (making 10 small requests).

* **Mechanism:** When the Dashboard loads, the Flutter app makes **ONE** call to `GET /dashboard/sync`.
* **Lambda Action:** Executes parallel DynamoDB queries to fetch:
  1. The User's Link History (via GSI).
  2. The System Global Stats (via Primary Key).
* **Result:** The UI renders the entire application state in a single frame update.

### B. Atomic Analytics (The "Write" Path)

We prioritize data consistency during high-concurrency events (e.g., a viral link).

* **Mechanism:** DynamoDB `TransactWriteItems` or `UpdateCommand`.
* **Logic:** When a link is clicked:
  * Increment `LINK#<id>` click count.
  * Increment `SYSTEM#GLOBAL` total click count.
  * Increment `LINK#<id>` specific counters (OS map, Country map).
  * Increment `SYSTEM#GLOBAL` aggregate counters.
* **Outcome:** All stats stay perfectly synchronized without race conditions.

### C. Smart URL Handling (Raw Input Mode)

To maximize compatibility, the system minimizes interference with user input.

* **Input:** Users can enter `reddit.com`, `http://site.com`, or `ftp://files`.
* **Processing:** The backend only prepends `https://` if **no protocol** is detected.
* **Redirect:** The `Location` header is sent exactly as stored, relying on the browser to handle protocol-less redirects (treating them as relative if not handled correctly, hence the `https` enforcement for bare domains).

---

## 5. Security & Authentication

### Authentication Flow

1. **Identity Provider:** Amazon Cognito User Pool.
2. **Login:** Flutter uses SRP (Secure Remote Password) protocol to exchange credentials for a **JWT (ID Token)**.
3. **Transport:** The JWT is sent in the `Authorization: Bearer` header.
4. **Verification:** API Gateway natively verifies the JWT signature before invoking the Lambda.
5. **Context:** The Lambda extracts `event.requestContext.authorizer.jwt.claims.sub` to identify the user securely.

### Data Isolation

* **User Data:** Isolated via `GSI1PK` (Partitioned by User ID).
* **Global Data:** stored in a specific partition `SYSTEM#GLOBAL`, readable by everyone (via the API logic) but only writable by the system.

---

## 6. Scalability & Performance

* **Compute:** AWS Lambda scales horizontally to handle thousands of concurrent redirects.
* **Database:** DynamoDB On-Demand mode handles burst traffic without throttling (up to account limits).
* **Latency:**
  * **Redirects:** ~200-500ms (depending on Geo-IP lookup speed).
  * **Dashboard Load:** ~150ms (Single DB Query).

```

```
