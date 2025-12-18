razasoft.tech Info

Objects

Metadata

Properties

Permissions

Metrics

Management

Access Points
Objects (12)

Copy S3 URI
Copy URL
Download
Open
Delete
Actions
Create folder
Upload
Objects are the fundamental entities stored in Amazon S3. You can use Amazon S3 inventory  to get a list of all objects in your bucket. For others to access your objects, you'll need to explicitly grant them permissions. Learn more

Show versions

1

Name

Type

Last modified

Size

Storage class

Name

Type

Last modified

Size

Storage class

.last_build_id
last_build_id
December 14, 2025, 23:31:04 (UTC+05:00)
32.0 B
Standard
assets/
Folder
------

canvaskit/
Folder
------

favicon.png
png
December 14, 2025, 23:31:04 (UTC+05:00)
917.0 B
Standard
flutter_bootstrap.js
js
December 14, 2025, 23:30:58 (UTC+05:00)
9.5 KB
Standard
flutter_service_worker.js
js
December 14, 2025, 23:30:59 (UTC+05:00)
8.9 KB
Standard
flutter.js
js
December 14, 2025, 23:31:05 (UTC+05:00)
9.2 KB
Standard
icons/
Folder
------

index.html
html
December 14, 2025, 23:30:59 (UTC+05:00)
1.2 KB
Standard
main.dart.js
js
December 14, 2025, 23:31:02 (UTC+05:00)
3.0 MB
Standard
manifest.json
json
December 14, 2025, 23:31:03 (UTC+05:00)
963.0 B
Standard
version.json
json
December 14, 2025, 23:31:03 (UTC+05:00)
102.0 B
Standard
url-shortener-frontend-adil Info

Objects

Metadata

Properties

Permissions

Metrics

Management

Access Points
Objects (12)

Copy S3 URI
Copy URL
Download
Open
Delete
Actions
Create folder
Upload
Objects are the fundamental entities stored in Amazon S3. You can use Amazon S3 inventory  to get a list of all objects in your bucket. For others to access your objects, you'll need to explicitly grant them permissions. Learn more

1

Name

Type

Last modified

Size

Storage class

Name

Type

Last modified

Size

Storage class

.last_build_id
last_build_id
December 13, 2025, 14:20:13 (UTC+05:00)
32.0 B
Standard
assets/
Folder
------

canvaskit/
Folder
------

favicon.png
png
December 13, 2025, 14:20:13 (UTC+05:00)
917.0 B
Standard
flutter_bootstrap.js
js
December 13, 2025, 14:20:15 (UTC+05:00)
9.5 KB
Standard
flutter_service_worker.js
js
December 13, 2025, 14:20:16 (UTC+05:00)
8.3 KB
Standard
flutter.js
js
December 13, 2025, 14:20:15 (UTC+05:00)
9.2 KB
Standard
icons/
Folder
------

index.html
html
December 13, 2025, 14:20:17 (UTC+05:00)
1.2 KB
Standard
main.dart.js
js
December 13, 2025, 14:20:21 (UTC+05:00)
2.6 MB
Standard
manifest.json
json
December 13, 2025, 14:20:22 (UTC+05:00)
963.0 B
Standard
version.json
json
December 13, 2025, 14:20:23 (UTC+05:00)
102.0 B
Standard

CloudShell
Feedback
© 2025, Amazon Web Services, Inc. or its affiliates.

UrlShortener
Last updated
December 17, 2025, 15:08 (UTC+5:00)

Actions
Explore table items

Settings
Indexes
Monitor
Global tables
Backups
Exports and streams
Permissions

Protect your DynamoDB table from accidental writes and deletes
When you turn on point-in-time recovery (PITR), DynamoDB backs up your table data automatically so that you can restore to any given second in the preceding 1 to 35 days. Additional charges apply. Learn more
Edit PITR

General information Info
Get live item count
Partition key
id (String)
Sort key
--------

Capacity mode
On-demand
Table status
Active
Alarms
No active alarms
Point-in-time recovery (PITR)Info
Off
Item count
5
Table size
502 bytes
Average item size
100.4 bytes
Resource-based policyInfo
Not active
Amazon Resource Name (ARN)
 arn:aws:dynamodb:us-east-1:204722664311:table/UrlShortener
Additional info
Read/write capacity Info
Edit
The read/write capacity mode controls how you are charged for read and write throughput and how you manage capacity.

Capacity mode
On-demand
Maximum read request units
--------------------------

Maximum write request units
---------------------------

Index capacity
Auto scaling activities (0)
Last updated
December 17, 2025, 15:08 (UTC+5:00)

Recent events of automatic scaling. Learn more

1

Start time
End time
Target
Capacity unit
Description
Status
No auto scaling activities found
There are no auto scaling activities for the table or its global secondary indexes.

Warm throughput Info
Last updated
December 17, 2025, 15:08 (UTC+5:00)

Edit
Prepare your table for planned peak events, without impacting your application performance or availability. Learn more about Amazon DynamoDB pricing

Name
Status
Type
Read units per second
Write operations per second
UrlShortener
Active
Table
12,000
4,000
UserHistoryIndex
Active
Index
12,000
4,000
Deletion protection Info
Turn on
Protects the table from being deleted unintentionally. When this setting is on, you can't delete the table.

Deletion protection
Off
Time to Live (TTL) Info
Last updated
December 17, 2025, 15:08 (UTC+5:00)

Run preview
Turn on
Automatically delete expired items from a table.

TTL status
Off
Encryption Info
Manage encryption
Provides enhanced security by encrypting all your data at rest using encryption keys stored in AWS Key Management Service.

Key management
AWS owned key
Tags (0) Info
Last updated
December 17, 2025, 15:08 (UTC+5:00)

Manage tags
Tags are labels you assign to AWS resources that allow you to manage, identify, organize, search for, and filter those resources.

1

Key
Value
No tags are associated with the resource.
Manage tags

CloudShell
Feedback
© 2025, Amazon Web Services, Inc. or its affiliates.

## Global secondary indexes **(1)**

 [Info]()

**Delete**

[Create index](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#create-index?table=UrlShortener)

[ ]

* 
* 1
* 

| **Item radio selector** | Name                       | Status           | Partition key             | Sort key                     | Read capacity | Write capacity | Projected attributes | Size      | Item count |
| ----------------------------- | -------------------------- | ---------------- | ------------------------- | ---------------------------- | ------------- | -------------- | -------------------- | --------- | ---------- |
|                               | **UserHistoryIndex** | **Active** | **userId (String)** | **createdAt (String)** | On-demand     | On-demand      | All                  | 502 bytes | 5          |

# DailyStats

Last updated
December 17, 2025, 15:05 (UTC+5:00)

**Actions**

[Explore table items](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#item-explorer?maximize=true&table=DailyStats)

* [Settings](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=overview)
* [Indexes](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=indexes)
* [Monitor](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=monitoring)
* [Global tables](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=globalTables)
* [Backups](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=backups)
* [Exports and streams](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=streams)
* [Permissions](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=DailyStats&tab=permissions)

Protect your DynamoDB table from accidental writes and deletes

When you turn on point-in-time recovery (PITR), DynamoDB backs up your table data automatically so that you can restore to any given second in the preceding 1 to 35 days. Additional charges apply. [Learn more ](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html)

[Edit PITR](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#edit-pitr?table=DailyStats)

## General information

 [Info]()

**Get live item count**

Partition key

shortCode (String)

Sort key

date (String)

Capacity mode

On-demand

Table status

Active

Alarms

**No active alarms**

Point-in-time recovery (PITR)[Info]()

**Off**

Item count

1

Table size

37 bytes

Average item size

37 bytes

Resource-based policy[Info]()

**Not active**

Amazon Resource Name (ARN)

 arn:aws:dynamodb:us-east-1:204722664311:table/DailyStats

**Additional info**

## Read/write capacity

 [Info]()

[Edit](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#capacity-settings?table=DailyStats)

The read/write capacity mode controls how you are charged for read and write throughput and how you manage capacity.

Capacity mode

On-demand

Maximum read request units

Maximum write request units

## Auto scaling activities **(0)**

Last updated
December 17, 2025, 15:05 (UTC+5:00)

Recent events of automatic scaling. [Learn more ](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AutoScaling.Console.html#AutoScaling.Console.ViewingActivities)

[ ]

* 
* 1
* 

| Start time                                                                                                          | End time | Target | Capacity unit | Description | Status |
| ------------------------------------------------------------------------------------------------------------------- | -------- | ------ | ------------- | ----------- | ------ |
| No auto scaling activities foundThere are no auto scaling activities for the table or its global secondary indexes. |          |        |               |             |        |

## Warm throughput

 [Info]()

Last updated
December 17, 2025, 15:05 (UTC+5:00)

[Edit](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#warm-throughput?table=DailyStats "Edit")

Prepare your table for planned peak events, without impacting your application performance or availability. Learn more about [Amazon DynamoDB pricing ](https://aws.amazon.com/dynamodb/pricing)

| Name       | Status           | Type  | Read units per second | Write operations per second |
| ---------- | ---------------- | ----- | --------------------- | --------------------------- |
| DailyStats | **Active** | Table | 12,000                | 4,000                       |

## Deletion protection

 [Info]()

**Turn on**

Protects the table from being deleted unintentionally. When this setting is on, you can't delete the table.

Deletion protection

Off

## Time to Live (TTL)

 [Info]()

Last updated
December 17, 2025, 15:05 (UTC+5:00)

**Run preview**

[Turn on](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#enable-ttl?table=DailyStats)

Automatically delete expired items from a table.

TTL status

**Off**

## Encryption

 [Info]()

[Manage encryption](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#manage-encryption?table=DailyStats)

Provides enhanced security by encrypting all your data at rest using encryption keys stored in AWS Key Management Service.

Key management

AWS owned key

## Tags **(0)**

 [Info]()

Last updated
December 17, 2025, 15:05 (UTC+5:00)

[Manage tags](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tags?table=DailyStats)

Tags are labels you assign to AWS resources that allow you to manage, identify, organize, search for, and filter those resources.

[ ]

* 
* 1
* 

| Key                                                                                                                                                            | Value |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **No tags are associated with the resource.**[Manage tags](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tags?table=DailyStats) |       |

**CloudShell**

Feedback

© 2025, Amazon Web Services, Inc. or its affiliates.

## Global secondary indexes **(0)**

 [Info]()

**Delete**

[Create index](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#create-index?table=DailyStats)

[ ]

* 
* 1
* 

| **Item radio selector**                                                                                                                                                                                                                                              | Name | Status | Partition key | Sort key | Read capacity | Write capacity | Projected attributes | Size | Item count |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- | ------ | ------------- | -------- | ------------- | -------------- | -------------------- | ---- | ---------- |
| **No global secondary indexes**Global secondary indexes allow you to perform queries on attributes that are not part of the table's primary key.[Create index](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#create-index?table=DailyStats) |      |        |               |          |               |                |                      |      |            |

User

Last updated
December 17, 2025, 15:10 (UTC+5:00)

**Actions**

[Explore table items](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#item-explorer?maximize=true&table=User)

* [Settings](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=overview)
* [Indexes](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=indexes)
* [Monitor](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=monitoring)
* [Global tables](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=globalTables)
* [Backups](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=backups)
* [Exports and streams](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=streams)
* [Permissions](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#table?name=User&tab=permissions)

Protect your DynamoDB table from accidental writes and deletes

When you turn on point-in-time recovery (PITR), DynamoDB backs up your table data automatically so that you can restore to any given second in the preceding 1 to 35 days. Additional charges apply. [Learn more ](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/PointInTimeRecovery.html)

[Edit PITR](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#edit-pitr?table=User)

## General information

 [Info]()

**Get live item count**

Partition key

userId (String)

Sort key

Capacity mode

On-demand

Table status

Active

Alarms

**No active alarms**

Point-in-time recovery (PITR)[Info]()

**Off**

Item count

1

Table size

44 bytes

Average item size

44 bytes

Resource-based policy[Info]()

**Not active**

Amazon Resource Name (ARN)

 arn:aws:dynamodb:us-east-1:204722664311:table/User

**Additional info**

## Read/write capacity

 [Info]()

[Edit](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#capacity-settings?table=User)

The read/write capacity mode controls how you are charged for read and write throughput and how you manage capacity.

Capacity mode

On-demand

Maximum read request units

Maximum write request units

## Auto scaling activities **(0)**

Last updated
December 17, 2025, 15:10 (UTC+5:00)

Recent events of automatic scaling. [Learn more ](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AutoScaling.Console.html#AutoScaling.Console.ViewingActivities)

[ ]

* 
* 1
* 

| Start time                                                                                                          | End time | Target | Capacity unit | Description | Status |
| ------------------------------------------------------------------------------------------------------------------- | -------- | ------ | ------------- | ----------- | ------ |
| No auto scaling activities foundThere are no auto scaling activities for the table or its global secondary indexes. |          |        |               |             |        |

## Warm throughput

 [Info]()

Last updated
December 17, 2025, 15:10 (UTC+5:00)

[Edit](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#warm-throughput?table=User "Edit")

Prepare your table for planned peak events, without impacting your application performance or availability. Learn more about [Amazon DynamoDB pricing ](https://aws.amazon.com/dynamodb/pricing)

| Name | Status           | Type  | Read units per second | Write operations per second |
| ---- | ---------------- | ----- | --------------------- | --------------------------- |
| User | **Active** | Table | 12,000                | 4,000                       |

## Deletion protection

 [Info]()

**Turn on**

Protects the table from being deleted unintentionally. When this setting is on, you can't delete the table.

Deletion protection

Off

## Time to Live (TTL)

 [Info]()

Last updated
December 17, 2025, 15:10 (UTC+5:00)

**Run preview**

[Turn on](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#enable-ttl?table=User)

Automatically delete expired items from a table.

TTL status

**Off**

## Encryption

 [Info]()

[Manage encryption](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#manage-encryption?table=User)

Provides enhanced security by encrypting all your data at rest using encryption keys stored in AWS Key Management Service.

Key management

AWS owned key

## Tags **(0)**

 [Info]()

Last updated
December 17, 2025, 15:10 (UTC+5:00)

[Manage tags](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tags?table=User)

Tags are labels you assign to AWS resources that allow you to manage, identify, organize, search for, and filter those resources.

[ ]

* 
* 1
* 

| Key                                                                                                                                                      | Value |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **No tags are associated with the resource.**[Manage tags](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#tags?table=User) |       |

**CloudShell**

Feedback

© 20

## Global secondary indexes **(0)**

 [Info]()

**Delete**

[Create index](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#create-index?table=User)

[ ]

* 
* 1
* 

| **Item radio selector**                                                                                                                                                                                                                                        | Name | Status | Partition key | Sort key | Read capacity | Write capacity | Projected attributes | Size | Item count |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---- | ------ | ------------- | -------- | ------------- | -------------- | -------------------- | ---- | ---------- |
| **No global secondary indexes**Global secondary indexes allow you to perform queries on attributes that are not part of the table's primary key.[Create index](https://us-east-1.console.aws.amazon.com/dynamodbv2/home?region=us-east-1#create-index?table=User) |      |        |               |          |               |                |                      |      |            |

url-shortener-logic

**Throttle**

**Copy ARN**

**Actions**

## Function overview

 [Info]()

**Export to Infrastructure Composer**

**Download**

DiagramTemplate

![](https://a.b.cdn.console.awsstatic.com/a/v1/ASJXZFLVLBGU5KRUAC63L3KCZ62OQVM4G3PQXYVSD4FAUUJ6QI7Q/icons/lambda.svg)

### url-shortener-logic

**Layers**

(0)

![]()

### API Gateway

(3)

[Add trigger](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/add/relation?type=trigger&targetType=lambda&target=arn:aws:lambda:us-east-1:204722664311:function:url-shortener-logic)

**Add destination**

Description

Last modified

2 days ago

Function ARN

arn:aws:lambda:us-east-1:204722664311:function:url-shortener-logic

Function URL

[Info]()-

* [Code](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/url-shortener-logic?tab=code)
* [Test](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/url-shortener-logic?tab=testing)
* [Monitor](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/url-shortener-logic?tab=monitoring)
* [Configuration](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/url-shortener-logic?tab=configure)
* [Aliases](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/url-shortener-logic?tab=aliases)
* [Versions](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/url-shortener-logic?tab=versions)

## Code source

 [Info]()

**Open in Visual Studio Code**

**Upload from**

<iframe id="editor" class="" title="AWS Lambda code editor based on Code-OSS (VS Code open source)" allow="clipboard-write; clipboard-read" sandbox="allow-scripts allow-same-origin allow-forms allow-popups" src="https://a.b.cdn.console.awsstatic.com/a/v1/DH6HSCFV46PQRIP3WSCZLPZ4BTXZFCLWXW6B5VIT4NMTIDZIQKSA/index.html?origin=https://us-east-1.console.aws.amazon.com&v2=true&function=url-shortener-logic&toolkit=true&isDevo=false&vsCodeCdn=https://a.b.cdn.console.awsstatic.com/a/v1/DH6HSCFV46PQRIP3WSCZLPZ4BTXZFCLWXW6B5VIT4NMTIDZIQKSA"></iframe>

## Code properties

 [Info]()

Package size

2.5 kB

SHA256 hash

nDkepaXZHzPyoRdQ+f1FAJlbCb1UK/Uk5cNNkylVC7s=

Last modified

2 days ago

Encryption with AWS KMS customer managed KMS key

[Info]()

## Runtime settings

 [Info]()

**Edit**

**Edit runtime management configuration**

Runtime

Node.js 20.x

Handler

[Info]()index.handler

Architecture

[Info]()x86_64

**Runtime management configuration**

## Layers

 [Info]()

**Edit**

[Add a layer](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/add/layer?function=url-shortener-logic)

| Merge order                  | Name | Layer version | Compatible runtimes | Compatible architectures | Version ARN |
| ---------------------------- | ---- | ------------- | ------------------- | ------------------------ | ----------- |
| There is no data to display. |      |               |                     |                          |             |

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

import { DynamoDBDocumentClient, PutCommand, GetCommand, UpdateCommand, QueryCommand, DeleteCommand } from"@aws-sdk/lib-dynamodb";

import { randomUUID } from"crypto";

constclient=new DynamoDBClient({});

constdocClient=DynamoDBDocumentClient.from(client);

// TABLE NAMES

constTABLE_URLS=process.env.TABLE_NAME||"UrlShortener";

constTABLE_USERS=process.env.TABLE_USERS||"Users";

constTABLE_STATS=process.env.TABLE_STATS||"DailyStats";

constINDEX_HISTORY="UserHistoryIndex"; // Make sure this matches your GSI name

exportconsthandler=async (event) => {

console.log("Event:", JSON.stringify(event));

// CORS Headers

constheaders= {

"Access-Control-Allow-Origin":"*",

"Access-Control-Allow-Headers":"Content-Type,Authorization",

"Access-Control-Allow-Methods":"OPTIONS,POST,GET,DELETE",

  };

constmethod=event.requestContext?.http?.method;

constpath=event.rawPath||event.requestContext?.http?.path;

// 1. PREFLIGHT

if (method === "OPTIONS") return { statusCode: 200, headers, body: "" };

try {

// =======================================================

// A. LIST HISTORY & USER STATS (GET /urls?userId=...)

// =======================================================

if (method==="GET"&&path.endsWith("/urls")) {

constuserId=event.queryStringParameters?.userId;

if (!userId) return { statusCode:400, headers, body:JSON.stringify({ error:"userId required" }) };

// 1. Query the Links

consthistoryCommand=newQueryCommand({

TableName:TABLE_URLS,

IndexName:INDEX_HISTORY,

KeyConditionExpression:"userId = :uid",

ExpressionAttributeValues: { ":uid":userId },

ScanIndexForward:false, // Newest first

    });

// 2. Get User Aggregate Stats (Atomic Counters)

conststatsCommand=newGetCommand({

TableName:TABLE_USERS,

Key: { userId:userId }

    });

// Run both in parallel for speed

const [historyResult, statsResult] =awaitPromise.all([

docClient.send(historyCommand),

docClient.send(statsCommand)

    ]);

return {

statusCode:200,

headers,

body:JSON.stringify({

urls:historyResult.Items|| [],

stats:statsResult.Item|| { totalLinks:0, totalClicks:0 }

    }),

    };

    }

// =======================================================

// B. REDIRECT + ANALYTICS (GET /{id})

// =======================================================

if (method==="GET") {

constshortCode=event.pathParameters?.id;

if (!shortCode) return { statusCode:400, headers, body:JSON.stringify({ error:"No code" }) };

// 1. Get Original URL

constresult=awaitdocClient.send(newGetCommand({ TableName:TABLE_URLS, Key: { id:shortCode }}));

if (!result.Item) {

return { statusCode:404, headers, body:JSON.stringify({ error:"Short URL not found" }) };

    }

// 2. RECORD ANALYTICS (Atomic Updates)

consttoday=newDate().toISOString().split('T')[0]; // "2025-12-15"

constownerId=result.Item.userId;

// We execute these updates in parallel.

// We do NOT await them to finish before returning the redirect to keep it fast.

constupdates= [

// Increment clicks on the Link itself

docClient.send(newUpdateCommand({

TableName:TABLE_URLS, Key: { id:shortCode },

UpdateExpression:"ADD clicks :inc", ExpressionAttributeValues: { ":inc":1 }

    })),

// Increment clicks for the Day (Graph Data)

docClient.send(newUpdateCommand({

TableName:TABLE_STATS, Key: { shortCode:shortCode, date:today },

UpdateExpression:"ADD clicks :inc", ExpressionAttributeValues: { ":inc":1 }

    }))

    ];

// Only update User total clicks if it's a registered user

if (ownerId&&ownerId!=='anonymous') {

updates.push(docClient.send(newUpdateCommand({

TableName:TABLE_USERS, Key: { userId:ownerId },

UpdateExpression:"ADD totalClicks :inc", ExpressionAttributeValues: { ":inc":1 }

    })));

    }

// Execute DB updates

awaitPromise.all(updates);

// 3. Return Redirect

return {

statusCode:301,

headers: { "Location":result.Item.originalUrl, "Cache-Control":"private, max-age=0" }

    };

    }

// =======================================================

// C. CREATE URL + UPDATE STATS (POST /urls)

// =======================================================

if (method==="POST") {

letbody= {};

if (event.body) body=typeofevent.body==="string"?JSON.parse(event.body) :event.body;

const { originalUrl, userId, customCode } =body;

if (!originalUrl) return { statusCode:400, headers, body:JSON.stringify({ error:"URL required" }) };

letshortCode;

// Handle Custom Alias

if (customCode) {

if (!/^[a-zA-Z0-9-]{3,20}$/.test(customCode)) {

return { statusCode:400, headers, body:JSON.stringify({ error:"Invalid custom code format" }) };

    }

constexisting=awaitdocClient.send(newGetCommand({ TableName:TABLE_URLS, Key: { id:customCode }}));

if (existing.Item) return { statusCode:409, headers, body:JSON.stringify({ error:"Alias already taken" }) };

shortCode=customCode;

    } else {

shortCode=randomUUID().substring(0, 6);

    }

constitem= {

id:shortCode,

originalUrl,

userId:userId||"anonymous",

clicks:0,

createdAt:newDate().toISOString(),

    };

// 1. Save URL

awaitdocClient.send(newPutCommand({ TableName:TABLE_URLS, Item:item }));

// 2. Increment User Link Count

if (userId) {

awaitdocClient.send(newUpdateCommand({

TableName:TABLE_USERS, Key: { userId:userId },

UpdateExpression:"ADD totalLinks :inc", ExpressionAttributeValues: { ":inc":1 }

    }));

    }

return {

statusCode:201, headers,

body:JSON.stringify({

message:"Created",

shortCode,

shortUrl:`https://razasoft.tech/${shortCode}`,

originalUrl

    }),

    };

    }

// =======================================================

// D. DELETE URL + CLEANUP (DELETE /urls/{id})

// =======================================================

if (method==="DELETE") {

// Assume API Gateway passes ID in path, and userId in Query

constshortCode=event.pathParameters?.id;

constuserId=event.queryStringParameters?.userId;

if (!shortCode||!userId) return { statusCode:400, headers, body:JSON.stringify({ error:"Missing ID or UserID" }) };

// 1. Verify Ownership

constresult=awaitdocClient.send(newGetCommand({ TableName:TABLE_URLS, Key: { id:shortCode }}));

if (!result.Item) return { statusCode:404, headers, body:JSON.stringify({ error:"Not found" }) };

if (result.Item.userId!==userId) return { statusCode:403, headers, body:JSON.stringify({ error:"Unauthorized" }) };

// 2. Delete

awaitdocClient.send(newDeleteCommand({ TableName:TABLE_URLS, Key: { id:shortCode }}));

// 3. Decrement User Stats

awaitdocClient.send(newUpdateCommand({

TableName:TABLE_USERS, Key: { userId:userId },

UpdateExpression:"ADD totalLinks :dec", ExpressionAttributeValues: { ":dec":-1 }

    }));

return { statusCode:200, headers, body:JSON.stringify({ message:"Deleted" }) };

    }

// =======================================================

// E. GET GRAPH DATA (GET /stats/{id})

// =======================================================

if (method==="GET"&&path.startsWith("/stats/")) {

constshortCode=path.split("/").pop(); // Get ID from end of path

if (!shortCode) return { statusCode:400, headers, body:JSON.stringify({ error:"No code" }) };

constcommand=newQueryCommand({

TableName:TABLE_STATS,

KeyConditionExpression:"shortCode = :code",

ExpressionAttributeValues: { ":code":shortCode },

ScanIndexForward:true// Oldest date first

    });

constresult=awaitdocClient.send(command);

return {

statusCode:200,

headers,

body:JSON.stringify({

shortCode:shortCode,

dailyClicks:result.Items|| []

    }),

    };

    }

  } catch (error) {

console.error("Error:", error);

return { statusCode:500, headers, body:JSON.stringify({ error:error.message }) };

  }

};

# auth-signin-function

**Throttle**

**Copy ARN**

**Actions**

## Function overview

 [Info]()

**Export to Infrastructure Composer**

**Download**

DiagramTemplate

![](https://a.b.cdn.console.awsstatic.com/a/v1/ASJXZFLVLBGU5KRUAC63L3KCZ62OQVM4G3PQXYVSD4FAUUJ6QI7Q/icons/lambda.svg)

### auth-signin-function

**Layers**

(0)

![]()

### API Gateway

[Add trigger](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/add/relation?type=trigger&targetType=lambda&target=arn:aws:lambda:us-east-1:204722664311:function:auth-signin-function)

**Add destination**

Description

Last modified

6 days ago

Function ARN

arn:aws:lambda:us-east-1:204722664311:function:auth-signin-function

Function URL

[Info]()-

* [Code](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/auth-signin-function?tab=code)
* [Test](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/auth-signin-function?tab=testing)
* [Monitor](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/auth-signin-function?tab=monitoring)
* [Configuration](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/auth-signin-function?tab=configure)
* [Aliases](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/auth-signin-function?tab=aliases)
* [Versions](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/functions/auth-signin-function?tab=versions)

## Code source

 [Info]()

**Open in Visual Studio Code**

**Upload from**

<iframe id="editor" class="" title="AWS Lambda code editor based on Code-OSS (VS Code open source)" allow="clipboard-write; clipboard-read" sandbox="allow-scripts allow-same-origin allow-forms allow-popups" src="https://a.b.cdn.console.awsstatic.com/a/v1/DH6HSCFV46PQRIP3WSCZLPZ4BTXZFCLWXW6B5VIT4NMTIDZIQKSA/index.html?origin=https://us-east-1.console.aws.amazon.com&v2=true&function=auth-signin-function&toolkit=true&isDevo=false&vsCodeCdn=https://a.b.cdn.console.awsstatic.com/a/v1/DH6HSCFV46PQRIP3WSCZLPZ4BTXZFCLWXW6B5VIT4NMTIDZIQKSA"></iframe>

## Code properties

 [Info]()

Package size

573 byte

SHA256 hash

BJanoZwx7OitJ8vyF4oc1WMJaAzK/3bHfoDfCwYAEdU=

Last modified

6 days ago

Encryption with AWS KMS customer managed KMS key

[Info]()

## Runtime settings

 [Info]()

**Edit**

**Edit runtime management configuration**

Runtime

Node.js 24.x

Handler

[Info]()index.handler

Architecture

[Info]()x86_64

**Runtime management configuration**

## Layers

 [Info]()

**Edit**

[Add a layer](https://us-east-1.console.aws.amazon.com/lambda/home?region=us-east-1#/add/layer?function=auth-signin-function)

| Merge order                  | Name | Layer version | Compatible runtimes | Compatible architectures | Version ARN |
| ---------------------------- | ---- | ------------- | ------------------- | ------------------------ | ----------- |
| There is no data to display. |      |               |                     |                          |             |

**CloudShell**

Feedback

© 2025, Amazon Web Services, Inc. or its affiliates.

// For Node.js 18.x with CommonJS

exports.handler=async (event) => {

console.log('Event:', JSON.stringify(event));

letemail='';

try {

constbody=JSON.parse(event.body||'{}');

email=body.email||'unknown@example.com';

  } catch (err) {

console.error('JSON parse error:', err);

  }

constresponseBody= {

success:true,

data: {

token:'dummy_jwt_token_from_lambda',

user: {

id:'user_123',

email,

name:email.split('@')[0],

createdAt:newDate().toISOString(),

mfaEnabled:false,

    },

requiresMfa:false,

    },

message:'Sign in successful (stub)',

  };

return {

statusCode:200,

headers: { 'Content-Type':'application/json' },

body:JSON.stringify(responseBody),

  };

};

Overview: User pool - jw9jmf

 [Info]()

**Rename**

**Delete user pool**

## User pool information

User pool name

User pool - jw9jmf

User pool ID

us-east-1_OJORVuNmI

ARN

arn:aws:cognito-idp:us-east-1:204722664311:userpool/us-east-1_OJORVuNmI

Token signing key URL

[https://cognito-idp.us-east-1.amazonaws.com/us-east-1_OJORVuNmI/.well-known/jwks.json ](https://cognito-idp.us-east-1.amazonaws.com/us-east-1_OJORVuNmI/.well-known/jwks.json)

Estimated number of users

4

Feature plan

[Essentials](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/settings/feature-plan?region=us-east-1)

Created time

December 11, 2025 at 23:23 GMT+5

Last updated time

December 11, 2025 at 23:23 GMT+5

### Recommendations

![](https://a.b.cdn.console.awsstatic.com/a/v1/3KY6VAQ2JMKUZB5ZTHA2NQZJ4G35CKJGKALUGK7WRWLCDKTPA65Q/img/user-pool-overview/svgs/first-app-icon.svg)

#### Set up your app:

[url-shortener-spa-adil](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/applications/app-clients/5s971p9gkjn8ughq25jqfo5qk5/quick-setup-guide?region=us-east-1)

Want to set up your application for Amazon Cognito? Our quick setup guides will get you started.

[View quick setup guide](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/applications/app-clients/5s971p9gkjn8ughq25jqfo5qk5/quick-setup-guide?region=us-east-1)

![](https://a.b.cdn.console.awsstatic.com/a/v1/3KY6VAQ2JMKUZB5ZTHA2NQZJ4G35CKJGKALUGK7WRWLCDKTPA65Q/img/user-pool-overview/svgs/try-login-pages-icon.svg)

#### Apply branding to your managed login pages

Now that you have login pages, you can customize logo images and the look and feel of your authentication service.

[View login page](https://us-east-1ojorvunmi.auth.us-east-1.amazoncognito.com/login?client_id=5s971p9gkjn8ughq25jqfo5qk5&response_type=code&scope=email+openid+phone&redirect_uri=https%3A%2F%2Fd84l1y8p4kdic.cloudfront.net "View login page, opens in new tab")

[Configure styles](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/branding/managed-login/enhanced?region=us-east-1)

![](https://a.b.cdn.console.awsstatic.com/a/v1/3KY6VAQ2JMKUZB5ZTHA2NQZJ4G35CKJGKALUGK7WRWLCDKTPA65Q/img/user-pool-overview/svgs/threat-protection-icon.svg)

#### Detect risks and protect users

Activate threat protection and get runtime analysis of risk factors when users connect to your application.

[Add threat protection](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/security/threat-protection?region=us-east-1)

![](https://a.b.cdn.console.awsstatic.com/a/v1/3KY6VAQ2JMKUZB5ZTHA2NQZJ4G35CKJGKALUGK7WRWLCDKTPA65Q/img/user-pool-overview/svgs/passwordless-icon.svg)

#### Set up passwordless sign-in

Support passwordless sign-in to your application with one-time codes from email and SMS messages. Support passkey sign-in with biometric devices and hardware security keys.

[Configure](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/authentication/sign-in?region=us-east-1)

![](https://a.b.cdn.console.awsstatic.com/a/v1/3KY6VAQ2JMKUZB5ZTHA2NQZJ4G35CKJGKALUGK7WRWLCDKTPA65Q/img/user-pool-overview/svgs/mfa-icon.svg)

#### Set up MFA

Improve security for your application with SMS, email, and authenticator-app multi-factor authentication.

[Edit MFA](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/authentication/sign-in?region=us-east-1)

![](https://a.b.cdn.console.awsstatic.com/a/v1/3KY6VAQ2JMKUZB5ZTHA2NQZJ4G35CKJGKALUGK7WRWLCDKTPA65Q/img/user-pool-overview/svgs/social-providers-icon.svg)

#### Add sign-in with social providers

Bring in users with credentials from social identity providers like Login with Amazon, Sign in with Apple, Google, Facebook, or from custom providers that federate with SAML and OIDC.

[Manage providers](https://us-east-1.console.aws.amazon.com/cognito/v2/idp/user-pools/us-east-1_OJORVuNmI/authentication/social-and-custom-providers?region=us-east-1)

**CloudShell**

Feedback

© 2025, Amazon Web Services, Inc. or its affiliates.

Public

 razasoft.tech

 [Info]()

**Delete zone**

**Test record**

**Configure query logging**

## Hosted zone details

**Edit hosted zone**

* Records (4)
* Accelerated recovery
* DNSSEC signing
* Hosted zone tags (0)

## Records **(4)**

 [Info]()

**Delete record**

**Import zone file**

**Create record**

**Automatic** **mode is the current search behavior optimized for best filter results.** [To change modes go to settings.](https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones?region=us-east-1#)

[ ]

**Type**

**Routing policy**

**Alias**

* 
* 1
* 

|  | Record name | Type | Routing policy | Differentiator | Alias | Value/Route traffic to | TTL (seconds) | Health check ID | Evaluate target health | Record ID |
| - | ----------- | ---- | -------------- | -------------- | ----- | ---------------------- | ------------- | --------------- | ---------------------- | --------- |

|  | Record name                                               | Type  | Routing policy | Differentiator | Alias | Value/Route traffic to                                                                           | TTL (seconds) | Health check ID | Evaluate target health | Record ID |
| - | --------------------------------------------------------- | ----- | -------------- | -------------- | ----- | ------------------------------------------------------------------------------------------------ | ------------- | --------------- | ---------------------- | --------- |
|  | **razasoft.tech**                                   | NS    | Simple         | -              | No    | ns-1626.awsdns-11.co.uk.``ns-156.awsdns-19.com.``ns-1084.awsdns-07.org.``ns-941.awsdns-53.net.`` | 172800        | -               | -                      | -         |
|  | **razasoft.tech**                                   | SOA   | Simple         | -              | No    | ns-1626.awsdns-11.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400``                | 900           | -               | -                      | -         |
|  | **_dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech** | CNAME | Simple         | -              | No    | _a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws.``                              | 300           | -               | -                      | -         |
|  | **api.razasoft.tech**                               | CNAME | Simple         | -              | No    | d-5dg0q4clh5.execute-api.us-east-1.amazonaws.com``                                               | 300           | -               | -                      | -         |

f399acbc-9bc3-49ff-9fb7-46d05b2cc228

**Delete**

## Certificate status

Identifier

f399acbc-9bc3-49ff-9fb7-46d05b2cc228

ARN

arn:aws:acm:us-east-1:204722664311:certificate/f399acbc-9bc3-49ff-9fb7-46d05b2cc228

Type

Amazon Issued

Status

**Issued**

## Domains **(2)**

**Create records in Route 53**

[Export to CSV](data:text/csv;charset=utf-8,%EF%BB%BFDomain%20name%2CCNAME%20name%2CType%2CCNAME%20value%0D%0Arazasoft.tech%2C_dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech.%2CCNAME%2C_a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws.%0D%0A*.razasoft.tech%2C_dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech.%2CCNAME%2C_a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws.)

* 
* 1
* 

| Domain          | Status            | Renewal status | Type  | CNAME name                                       | CNAME value                                                       |
| --------------- | ----------------- | -------------- | ----- | ------------------------------------------------ | ----------------------------------------------------------------- |
| razasoft.tech   | **Success** | -              | CNAME | _dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech. | _a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws. |
| *.razasoft.tech | **Success** | -              | CNAME | _dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech. | _a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws. |

## Details

In use

Yes

Domain name

razasoft.tech

Number of additional names

1

Serial number

01:7f:cb:71:ef:cb:50:8e:5a:ff:4d:39:1a🆎84:5b

Public key info

RSA 2048

Signature algorithm

SHA-256 with RSA

Can be used with

CloudFront, Elastic Load Balancing, API Gateway[ and other integrated services. ](https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html)

Requested at

December 13, 2025, 15:09:36 (UTC+05:00)

Issued at

December 13, 2025, 15:46:59 (UTC+05:00)

Not before

December 13, 2025, 05:00:00 (UTC+05:00)

Not after

January 12, 2027, 04:59:59 (UTC+05:00)

Renewal eligibility

Eligible

Export option

Disabled

## Associated resources **(3)**

* 
* 1
* 

| Resources                                                                                                 |
| --------------------------------------------------------------------------------------------------------- |
| arn:aws:elasticloadbalancing:us-east-1:250044486744:loadbalancer/app/prod-iad-1-az1-1-87/e68c4ff59d774933 |
| arn:aws:elasticloadbalancing:us-east-1:250044486744:loadbalancer/app/prod-iad-1-az2-1-55/be662136312b5722 |
| arn:aws:elasticloadbalancing:us-east-1:250044486744:loadbalancer/app/prod-iad-1-az5-1-11/e2d0e8322f177b76 |

## Tags **(0)**

**Manage**

* 
* 1
* 

| Key                                                     | Value |
| ------------------------------------------------------- | ----- |
| **No tags**No tags associated with this resource. |       |

3d246691-11c3-47f9-afd1-ef1dec37d27b

**Delete**

## Certificate status

Identifier

3d246691-11c3-47f9-afd1-ef1dec37d27b

ARN

arn:aws:acm:us-east-1:204722664311:certificate/3d246691-11c3-47f9-afd1-ef1dec37d27b

Type

Amazon Issued

Status

**Issued**

## Domains **(2)**

**Create records in Route 53**

[Export to CSV](data:text/csv;charset=utf-8,%EF%BB%BFDomain%20name%2CCNAME%20name%2CType%2CCNAME%20value%0D%0Arazasoft.tech%2C_dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech.%2CCNAME%2C_a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws.%0D%0A*.razasoft.tech%2C_dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech.%2CCNAME%2C_a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws.)

* 
* 1
* 

| Domain          | Status            | Renewal status | Type  | CNAME name                                       | CNAME value                                                       |
| --------------- | ----------------- | -------------- | ----- | ------------------------------------------------ | ----------------------------------------------------------------- |
| razasoft.tech   | **Success** | -              | CNAME | _dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech. | _a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws. |
| *.razasoft.tech | **Success** | -              | CNAME | _dc45ef3471cc39a7da917e98e3c7481a.razasoft.tech. | _a1d3d4a2fea6ba8d4b87f118daae25a2.jkddzztszm.acm-validations.aws. |

## Details

In use

No

Domain name

razasoft.tech

Number of additional names

1

Serial number

0f:6b:13:a2:8c:50:39:32:bb:0d:2d:b5:db:7c:08:18

Public key info

RSA 2048

Signature algorithm

SHA-256 with RSA

Can be used with

CloudFront, Elastic Load Balancing, API Gateway[ and other integrated services. ](https://docs.aws.amazon.com/acm/latest/userguide/acm-services.html)

Requested at

December 15, 2025, 21:39:29 (UTC+05:00)

Issued at

December 15, 2025, 21:39:44 (UTC+05:00)

Not before

December 15, 2025, 05:00:00 (UTC+05:00)

Not after

January 14, 2027, 04:59:59 (UTC+05:00)

Renewal eligibility

Ineligible

Export option

Disabled

## Tags **(0)**

**Manage**

* 
* 1
* 

| Key                                                     | Value |
| ------------------------------------------------------- | ----- |
| **No tags**No tags associated with this resource. |       |

**CloudShell**

Feedback

aws-cloud9-AuditEnv-b3ab2449114f4604afbe49138142f468

**Delete**

**Update stack**

**Stack actions**

**Create stack**

* Stack info
* Events
* Resources
* Outputs
* Parameters
* Template
* Changesets
* Git sync

## Overview

Stack ID

[arn:aws:cloudformation:us-east-1:204722664311:stack/aws-cloud9-AuditEnv-b3ab2449114f4604afbe49138142f468/e4361940-db2c-11f0-adc4-0affc6ecdf33 ](https://us-east-1.console.aws.amazon.com/go/view?arn=arn%3Aaws%3Acloudformation%3Aus-east-1%3A204722664311%3Astack%2Faws-cloud9-AuditEnv-b3ab2449114f4604afbe49138142f468%2Fe4361940-db2c-11f0-adc4-0affc6ecdf33&source=cloudformation)

Description

Status

**CREATE_COMPLETE**

Detailed status

Status reason

Root stack

Parent stack

Created time

2025-12-17 14:43:50 UTC+0500

Updated time

Deleted time

Drift status

**NOT_CHECKED**

Last drift check time

Termination protection

Deactivated

IAM role

## Latest operations

### Operation 1

Operation ID

[49fca2f4-6bfc-4726-8a05-f7fcced74d8f](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/operations/info?stackId=arn%3Aaws%3Acloudformation%3Aus-east-1%3A204722664311%3Astack%2Faws-cloud9-AuditEnv-b3ab2449114f4604afbe49138142f468%2Fe4361940-db2c-11f0-adc4-0affc6ecdf33&operationId=49fca2f4-6bfc-4726-8a05-f7fcced74d8f)

Operation type

CREATE_STACK

### Tags

Stack-level tags will apply to all supported resources in your stack. You can add up to 50 unique tags for each stack.

[ ]

* 
* 1
* 

| Key                    | Value                                                     |
| ---------------------- | --------------------------------------------------------- |
| aws:cloud9:environment | b3ab2449114f4604afbe49138142f468                          |
| aws:cloud9:owner       | AROAS7KTL6N3TCXNP7HIQ:user4655589=madilshahzad6@gmail.com |

## Stack policy

## Overview

Stack ID

[arn:aws:cloudformation:us-east-1:204722664311:stack/c184191a4775035l13107970t1w204722664311/156f4410-d695-11f0-8608-0affdc8bd0d5 ](https://us-east-1.console.aws.amazon.com/go/view?arn=arn%3Aaws%3Acloudformation%3Aus-east-1%3A204722664311%3Astack%2Fc184191a4775035l13107970t1w204722664311%2F156f4410-d695-11f0-8608-0affdc8bd0d5&source=cloudformation)

Description

associate Learner Lab template (academy)

Status

**CREATE_COMPLETE**

Detailed status

Status reason

Root stack

Parent stack

Created time

2025-12-11 18:27:04 UTC+0500

Updated time

Deleted time

Drift status

**NOT_CHECKED**

Last drift check time

Termination protection

Deactivated

IAM role

## Latest operations

### Operation 1

Operation ID

[36615355-ae9a-44a5-adce-56f17a59ec8d](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/operations/info?stackId=arn%3Aaws%3Acloudformation%3Aus-east-1%3A204722664311%3Astack%2Fc184191a4775035l13107970t1w204722664311%2F156f4410-d695-11f0-8608-0affdc8bd0d5&operationId=36615355-ae9a-44a5-adce-56f17a59ec8d)

Operation type

CREATE_STACK
