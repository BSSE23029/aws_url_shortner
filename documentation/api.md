Here is the **fully expanded** API documentation. This version covers **headers, request schemas, response examples, error codes, and backend side-effects** for every endpoint in your system.

Save this as `03_API_Contract_Detailed.md`.

---

```markdown
# 📡 API Contract & Technical Specification: Rad Link

**Version:** 1.0 (Semester Release)
**Protocol:** HTTP API (v2) via AWS API Gateway
**Base URL:** `https://api.razasoft.tech`

---

## 1. Global Standards

### A. Authentication & Headers
All secured endpoints require the following headers.
*   **Content-Type:** `application/json`
*   **Authorization:** `Bearer <COGNITO_JWT_TOKEN>`
    *   *Note:* If the token is missing, the backend currently defaults to `test-user-123` for development/grading purposes.

### B. CORS (Cross-Origin Resource Sharing)
The API supports Flutter Web clients. Every response includes:
```http
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: OPTIONS,POST,GET,DELETE
```

### C. Standard Response Wrapper

All JSON responses (except Redirects) follow this envelope structure:

```json
{
  "success": true,      // Boolean: status of operation
  "data": { ... },      // Object/Array: The requested payload (null on error)
  "message": "..."      // String: Optional info or error description
}
```

---

## 2. Endpoints Detail

### 🔹 Endpoint 1: Dashboard Mega-Sync

**Purpose:** Fetches *everything* needed to render the Flutter Dashboard and Analytics screens in a single network request. It aggregates User Data and System-Wide "Stupidity" Stats.

* **Method:** `GET`
* **Path:** `/dashboard/sync`
* **Auth Required:** Yes

**Response Body (200 OK):**

```json
{
  "success": true,
  "data": {
    "urls": [
      {
        "id": "abc123",
        "shortCode": "abc123",
        "originalUrl": "https://google.com",
        "shortUrl": "https://api.razasoft.tech/abc123",
        "clickCount": 42,
        "createdAt": "2025-12-18T10:00:00.000Z",
        "userId": "test-user-123"
      }
    ],
    "globalStats": {
      "totalSystemClicks": 15420,
      "totalSystemLinks": 502,
      "osDistribution": {
        "Android": 8500,
        "iOS": 6000,
        "Windows": 500,
        "Other": 420
      },
      "geoDistribution": {
        "PK": 5000,
        "US": 4000,
        "DE": 2000,
        "XX": 100
      }
    }
  }
}
```

---

### 🔹 Endpoint 2: Create Short URL

**Purpose:** Generates a new short link. Supports custom aliases and "Raw Input" mode (preserves exactly what the user typed).

* **Method:** `POST`
* **Path:** `/urls/create`
* **Auth Required:** Yes

**Request Body:**

```json
{
  "originalUrl": "reddit.com",      // Required. Can be bare domain or full URL.
  "customCode": "my-cool-link"      // Optional. If omitted, random 6-char generated.
}
```

**Validation Logic:**

1. **Alias:** Must match Regex `^[a-zA-Z0-9-_]{3,20}$`. No dots, no spaces.
2. **Original URL:** Saved **exactly** as input (Raw Input Mode). No protocol prepending is performed server-side (relying on browser/user input).

**Side Effects:**

* Atomically increments `total_links` in `SYSTEM#GLOBAL`.
* Creates `LINK#<code`> entity in DynamoDB.

**Response Body (200 OK):**

```json
{
  "success": true,
  "data": {
    "url": {
      "id": "my-cool-link",
      "shortCode": "my-cool-link",
      "originalUrl": "reddit.com",
      "shortUrl": "https://api.razasoft.tech/my-cool-link",
      "createdAt": "2025-12-18T12:00:00Z",
      "clickCount": 0,
      "userId": "test-user-123"
    }
  }
}
```

**Error Responses:**

* `400 Bad Request`: "Alias invalid. Use 3-20 chars..." or "URL required".
* `409 Conflict`: "Alias already taken!"

---

### 🔹 Endpoint 3: The Redirect (Public)

**Purpose:** The core function. Redirects a user to the destination and captures telemetry data.

* **Method:** `GET`
* **Path:** `/{alias}` (e.g., `/my-cool-link`)
* **Auth Required:** NO (Public access)

**Behavior:**

1. **Lookup:** Searches DynamoDB for `LINK#<alias>`.
2. **Telemetry (Fire & Forget):**
   * Resolves Geo-IP via `ip-api.com` (400ms timeout).
   * Parses User-Agent for OS/Browser/Bot status.
   * **Atomic Transactions:** Increments `clicks` on the specific Link *AND* the Global System stats simultaneously.
3. **Redirect:** Returns HTTP 301.

**Response Headers (301 Moved Permanently):**

* `Location`: `reddit.com` (or whatever was saved)
* `Cache-Control`: `private, max-age=0` (Disabled caching to ensure analytics are counted per click).

**Error Responses:**

* `404 Not Found`: "Link not found" (JSON body).

---

### 🔹 Endpoint 4: Delete URL

**Purpose:** Removes a link.

* **Method:** `DELETE`
* **Path:** `/urls/delete/{id}`
* **Auth Required:** Yes

**Validation Logic:**

* Checks if `GSI1PK` (Owner ID) matches the `sub` claim in the Auth Token.
* Prevents users from deleting other users' links.

**Response Body (200 OK):**

```json
{
  "success": true,
  "message": "Deleted"
}
```

---

## 3. Error Code Reference

| Status Code   | Meaning               | Context                                       |
| :------------ | :-------------------- | :-------------------------------------------- |
| **200** | OK                    | Request succeeded.                            |
| **301** | Moved Permanently     | Redirect successful.                          |
| **400** | Bad Request           | Invalid Alias format or missing URL.          |
| **401** | Unauthorized          | Auth Token missing or invalid.                |
| **403** | Forbidden             | Trying to delete a link you don't own.        |
| **404** | Not Found             | Short code does not exist.                    |
| **409** | Conflict              | Custom Alias already exists.                  |
| **500** | Internal Server Error | Lambda crash or DynamoDB throughput exceeded. |

---

## 4. Backend-Frontend Data Mapping

When the Flutter app receives the **Dashboard Mega-Sync**, it maps the JSON directly to the `GlobalStatsModel`.

| JSON Key (Backend)                     | Flutter Model Property | Type                 |
| :------------------------------------- | :--------------------- | :------------------- |
| `data.globalStats.totalSystemClicks` | `totalSystemClicks`  | `int`              |
| `data.globalStats.totalSystemLinks`  | `totalSystemLinks`   | `int`              |
| `data.globalStats.osDistribution`    | `osDistribution`     | `Map<String, int>` |
| `data.globalStats.geoDistribution`   | `geoDistribution`    | `Map<String, int>` |

*Note: The Flutter app uses `Map<String, int>` specifically for Syncfusion Pie/Bar charts.*



The industry standard for API documentation today is centered around the **OpenAPI Specification (OAS)** (formerly known as Swagger).

If you want your documentation to be respected by professional developers (like those at Stripe, Twilio, or Google), it must be **interactive**, **machine-readable**, and **comprehensive**.

Here is the breakdown of the Industry Standard structure.

---

### 1. The "Golden Rule": Docs-as-Code

Modern documentation is not written in Word documents. It is written in **YAML** or **JSON** files that live in the git repository alongside the code.

* **Format:** OpenAPI 3.0 or 3.1.
* **Philosophy:** If the code changes, the docs update automatically.

---

### 2. The Required Structure (The "Stripe" Standard)

A complete API documentation site consists of three distinct parts:

#### Part A: Getting Started (The Guides)

Before showing endpoints, you must explain how the system works.

1. **Authentication:**
   * Do I use an API Key? Bearer Token? OAuth2?
   * Where do I put it? (Header, Query Param?)
   * *Example:* `Authorization: Bearer <token>`
2. **Base URLs:**
   * Production: `https://api.razasoft.tech`
   * Sandbox/Staging: `https://stage-api.razasoft.tech`
3. **Errors:**
   * List standard HTTP codes (200, 400, 401, 403, 404, 429, 500).
   * Show the standard JSON error format.
4. **Rate Limits:**
   * How many requests per minute? What headers return the remaining limit?

#### Part B: API Reference (The Dictionary)

This is the technical breakdown of every endpoint. For **EACH** endpoint, you must include:

1. **Method & Path:** e.g., `POST /urls/create`
2. **One-Line Summary:** e.g., "Create a shortened URL."
3. **Description:** A paragraph explaining specific logic (e.g., "If no custom code is provided, a random 6-character string is generated.")
4. **Parameters (Inputs):**
   * **Headers:** (e.g., Auth, Content-Type)
   * **Path Params:** (e.g., `/{id}`)
   * **Query Params:** (e.g., `?sort=desc`)
   * **Body:** The JSON payload.
   * *Crucial:* Data types (string, int), Constraints (min length, regex), and **Required vs Optional**.
5. **Request Example:** A copy-pasteable JSON snippet.
6. **Response Example:** The exact JSON returned on success (200).
7. **Code Snippets:** Auto-generated examples in cURL, Python, Node.js, and Go.

#### Part C: The "Try It Out" Button

Static text is dead. Industry standard docs allow the developer to click a button, type their token, and hit the actual API directly from the browser.

---

### 3. Concrete Example: Your `create` Endpoint

Here is how your `POST /urls/create` endpoint should look in a standard documentation format (Markdown/OpenAPI style):

---

#### **Create Short URL**

`POST /urls/create`

Generates a new shortened URL for a given destination. Supports optional custom aliases.

**Authorizations:**

* `BearerAuth` (Header)

**Request Body** (`application/json`):

| Field           | Type   | Required      | Description            | Constraints                |
| :-------------- | :----- | :------------ | :--------------------- | :------------------------- |
| `originalUrl` | string | **Yes** | The destination URL.   | Must be valid URL format.  |
| `customCode`  | string | No            | Optional custom alias. | 3-20 chars,`[a-z0-9-_]`. |

**Example Request:**

```bash
curl -X POST "https://api.razasoft.tech/urls/create" \
  -H "Authorization: Bearer <your_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "originalUrl": "https://reddit.com",
    "customCode": "my-link"
  }'
```

**Success Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "url": {
      "id": "my-link",
      "shortUrl": "https://api.razasoft.tech/my-link",
      "originalUrl": "https://reddit.com",
      "createdAt": "2025-12-18T12:00:00Z",
      "clickCount": 0
    }
  }
}
```

**Error Responses:**

* **400 Bad Request:** `{"success": false, "message": "Alias invalid."}`
* **409 Conflict:** `{"success": false, "message": "Alias already taken."}`

---

### 4. The Tooling Stack

You don't write the HTML/CSS for this. You write a **YAML** spec, and tools render it.

1. **The Source:** **OpenAPI Specification (OAS 3.0)**. You write one `openapi.yaml` file that describes your whole API.
2. **The Renderer (UI):**
   * **Swagger UI:** The classic standard. Functional, but looks a bit old.
   * **Redoc:** The modern standard. Clean, widely used, looks like Stripe docs.
   * **Stoplight Elements:** Excellent, modern, interactive.
3. **The Hosting:**
   * **Postman:** You can publish docs directly from a Postman Collection.
   * **ReadMe.com:** The industry leader for hosted docs (paid).
   * **GitHub Pages:** You can host Redoc or Swagger UI for free on GitHub.

### Summary

To be "Industry Standard":

1. Define your API in **OpenAPI 3.0 YAML**.
2. Render it using **Redoc** or **Swagger UI**.
3. Ensure every endpoint has **Request/Response Examples**.
4. Include a **"Try It Now"** feature.

```


```
