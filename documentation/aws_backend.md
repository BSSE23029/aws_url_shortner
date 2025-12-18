Here is the detailed architectural document for the **AWS Backend**. This covers the specific implementation details of your Lambda, DynamoDB Single Table Design, and the networking constraints specific to your AWS Academy environment.

Save this as `02_AWS_Backend_Architecture_Detailed.md`.

---

```markdown
# ☁️ AWS Backend Architecture: Rad Link

**Version:** 1.0 (Semester Release)
**Region:** `us-east-1` (N. Virginia)
**Infrastructure Type:** Serverless (Event-Driven)

---

## 1. Compute Layer: Monolithic Lambda

Instead of managing microservices, the backend utilizes a **Monolithic Lambda** pattern to reduce cold starts and simplify state management for the "Mega-Sync" features.

### Function Details
*   **Name:** `url-shortener-logic`
*   **Runtime:** Node.js 20.x
*   **Memory:** 128MB (Standard) / Timeout: 3 seconds
*   **External Dependencies:** None (Uses AWS SDK v3 included in runtime).

### Internal Routing Logic
The Lambda acts as its own router, processing requests in this priority order:
1.  **API Endpoints:** Checks for specific paths (`/dashboard/sync`, `/urls/create`, `/urls/delete`).
2.  **Redirect Catch-All:** If the path does not match an API route, it assumes the path is a **Short Code** (Alias) and attempts a database lookup.

### Key Logic Modules
*   **"Poor Man's" Geo-Location:**
    *   Since CloudFront headers are unavailable, the Lambda queries `http://ip-api.com/json/{ip}`.
    *   **Performance Guard:** Implements an `AbortController` with a **400ms hard timeout**. If the Geo API is slow, the Lambda defaults to "Unknown" (XX) to prevent slowing down the user's redirect.
*   **Atomic Aggregation:**
    *   Uses `TransactWriteItems` or parallel `UpdateCommand` calls to ensure that when a link is clicked, the **User's Stats**, the **Link's Stats**, and the **Global System Stats** are updated simultaneously.

---

## 2. API Gateway (HTTP API v2)

We use **HTTP API** (not REST API) for lower latency and native CORS support.

### Route Configuration
| Route | Method | Integration | Auth | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `/dashboard/sync` | `GET` | Lambda | Cognito | Fetches all dashboard data. |
| `/urls/create` | `POST` | Lambda | Cognito | Creates short links. |
| `/urls/delete/{id}` | `DELETE` | Lambda | Cognito | Deletes a link. |
| `/{alias}` | `GET` | Lambda | **NONE** | Public redirect endpoint. |

### CORS Configuration
Configured Globally at the API Gateway level to allow Flutter Web access:
*   **Origins:** `*` (Allow All)
*   **Methods:** `GET, POST, DELETE, OPTIONS`
*   **Headers:** `Content-Type, Authorization`

---

## 3. Database: DynamoDB Single Table Design (STD)

**Table Name:** `Razasoft_Core`
**Billing Mode:** On-Demand (Pay per request)

### Schema Definitions
To support high-performance dashboards, we overload keys to store different types of data in one table.

| Attribute | Type | Purpose |
| :--- | :--- | :--- |
| **`PK`** | String | **Partition Key**. Identifies the Entity (Link, User, or System). |
| **`SK`** | String | **Sort Key**. Identifies the data type (Meta, Stats). |
| **`GSI1PK`** | String | **Global Secondary Index Partition**. Used to query "Links by User". |
| **`GSI1SK`** | String | **Global Secondary Index Sort**. Used to sort user links by Date. |

### Access Patterns & Entities

#### A. Link Metadata (The Redirect Info)
Stores the mapping between Alias and Original URL.
*   `PK`: `LINK#<shortCode>`
*   `SK`: `META`
*   `long_url`: `https://reddit.com` (Target)
*   `GSI1PK`: `USER#<userId>` (Owner Linkage)
*   `GSI1SK`: `DATE#<iso8601>` (Creation Date)

#### B. Link Statistics (The "Micro" Stats)
Stores daily analytics for a specific link using Map Attributes.
*   `PK`: `LINK#<shortCode>`
*   `SK`: `STATS#<YYYY-MM-DD>`
*   `clicks`: Number (Atomic Counter)
*   `os`: Map `{ "Android": N, "iOS": N }`
*   `geo`: Map `{ "US": N, "PK": N }`
*   `browser`: Map `{ "Chrome": N, "Safari": N }`

#### C. System Pulse (The "Macro" Stats)
A singleton row that aggregates the entire platform's activity for the "Stupidity Dashboard".
*   `PK`: `SYSTEM#GLOBAL`
*   `SK`: `STATS#TOTAL`
*   `total_clicks`: Number (Sum of all clicks ever)
*   `total_links`: Number (Sum of all links created)
*   `global_os`: Map (System-wide OS distribution)
*   `global_geo`: Map (System-wide Country distribution)

---

## 4. Networking & DNS

### Route 53
*   **Hosted Zone:** `razasoft.tech`
*   **Record:** `api.razasoft.tech` (CNAME) -> Points to API Gateway Domain (`d-xxxx.execute-api...`).

### SSL/TLS
*   **Certificate:** AWS Certificate Manager (ACM) `*.razasoft.tech`.
*   **Termination:** SSL is terminated at API Gateway. Traffic from Gateway to Lambda is internal AWS network.

---

## 5. Security Model (Semester Project Scope)

### Authentication
*   **Primary:** Amazon Cognito User Pool.
*   **Implementation:** The Frontend sends a JWT. API Gateway validates it.
*   **Lambda Logic:** Extracts `claims.sub` from the event context.
*   **Fallback:** For development ease, if no token is present, the Lambda defaults to `userId: "test-user-123"`.

### Data Integrity
*   **Validation:** Regex checks ensure Aliases contain no dots/spaces to prevent routing conflicts.
*   **Sanitization:** The backend accepts "Raw Input" URLs but ensures the *generated* short link is always `https://`.
```
