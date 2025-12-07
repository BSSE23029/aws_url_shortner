# AWS Middleware Setup Guide 🚀

Complete guide for connecting the Flutter middleware to AWS Lambda functions across multiple regions.

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Debug Mode vs Production](#debug-mode-vs-production)
3. [AWS Lambda Setup](#aws-lambda-setup)
4. [Multi-Region Configuration](#multi-region-configuration)
5. [Lambda Function Examples](#lambda-function-examples)
6. [Testing the Connection](#testing-the-connection)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Quick Start

### Step 1: Enable Debug Mode (No AWS Required)

By default, the app runs in **debug mode** with mock data:

```dart
// lib/config.dart
static const bool isDebugMode = true;  // 👈 Already set!
```

✅ **You can develop the entire app without any AWS setup!**

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Run the App

```bash
flutter run -d chrome
```

The app will use mock data automatically. No Lambda functions needed!

---

## 🔄 Debug Mode vs Production

### Debug Mode (`isDebugMode = true`)

**What happens:**
- All API calls return instant mock data
- No network requests made
- No AWS credentials needed
- Perfect for development and testing

**Use when:**
- Developing UI/UX
- Testing flows without backend
- Avoiding AWS costs during development

### Production Mode (`isDebugMode = false`)

**What happens:**
- Real HTTP requests to AWS Lambda
- Actual authentication via Cognito
- Real data from DynamoDB
- Multi-region routing

**Use when:**
- Deploying to production
- Integration testing with real backend
- Performance testing

---

## ☁️ AWS Lambda Setup

### Prerequisites

- AWS Account
- AWS CLI installed and configured
- Basic knowledge of Lambda and API Gateway

### Architecture Overview

```
Flutter App (HTTP)
    ↓
API Gateway (Multi-Region)
    ↓
AWS Lambda Functions
    ↓
DynamoDB + DAX
```

### Step-by-Step Lambda Deployment

#### 1. Create Lambda Functions

You need to create Lambda functions for each endpoint:

**Authentication Functions:**
- `auth-signin` - Handle user sign in
- `auth-signup` - Handle user registration
- `auth-mfa` - Verify MFA codes
- `auth-forgot-password` - Send password reset emails
- `auth-reset-password` - Complete password reset

**URL Management Functions:**
- `urls-list` - Get all user URLs
- `urls-create` - Create new short URL
- `urls-details` - Get URL details
- `urls-analytics` - Get URL analytics
- `urls-delete` - Delete a URL

#### 2. Create API Gateway

1. Go to AWS Console → API Gateway
2. Create **REST API**
3. Create resources for each endpoint:

```
/auth
  /signin (POST)
  /signup (POST)
  /mfa (POST)
  /forgot-password (POST)
  /reset-password (POST)

/urls (GET)
  /create (POST)
  /details/{id} (GET)
  /analytics/{id} (GET)
  /delete/{id} (DELETE)
```

4. Connect each method to corresponding Lambda function
5. Deploy to stage: `prod`

#### 3. Get Your API URLs

After deployment, you'll get URLs like:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod
https://def456uvw.execute-api.us-west-2.amazonaws.com/prod
https://ghi789rst.execute-api.eu-west-1.amazonaws.com/prod
```

#### 4. Update Flutter Configuration

```dart
// lib/config.dart

// Set to false to use real AWS
static const bool isDebugMode = false;

// Add your API Gateway URLs
static const Map<String, String> lambdaUrls = {
  'us-east-1': 'https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/prod',
  'us-west-2': 'https://YOUR-API-ID.execute-api.us-west-2.amazonaws.com/prod',
  'eu-west-1': 'https://YOUR-API-ID.execute-api.eu-west-1.amazonaws.com/prod',
  'ap-southeast-1': 'https://YOUR-API-ID.execute-api.ap-southeast-1.amazonaws.com/prod',
};

// Set your preferred default region
static const String defaultRegion = 'us-east-1';
```

---

## 🌍 Multi-Region Configuration

### Why Multi-Region?

- **Lower latency** - Users connect to nearest region
- **High availability** - Failover if one region is down
- **Better performance** - Geo-distributed load

### Setting Up Multiple Regions

1. Deploy Lambda functions in each region
2. Create API Gateway in each region
3. Update `lambdaUrls` in `config.dart`
4. (Optional) Use Route 53 for geo-routing

### Dynamic Region Selection

The middleware automatically uses the configured region:

```dart
// Current region (can be changed at runtime)
AppConfig.currentRegion = 'us-west-2';

// Get current Lambda URL
String url = AppConfig.currentLambdaUrl;  
// Returns: https://...us-west-2.../prod
```

### Changing Region in App

```dart
// In any screen with WidgetRef
ref.read(regionProvider.notifier).state = 'eu-west-1';
```

---

## 💻 Lambda Function Examples

### Example 1: Sign In Function (Node.js)

```javascript
// Lambda: auth-signin

const AWS = require('aws-sdk');
const cognito = new AWS.CognitoIdentityServiceProvider();

exports.handler = async (event) => {
    const { email, password } = JSON.parse(event.body);
    
    try {
        const params = {
            AuthFlow: 'USER_PASSWORD_AUTH',
            ClientId: process.env.COGNITO_CLIENT_ID,
            AuthParameters: {
                USERNAME: email,
                PASSWORD: password
            }
        };
        
        const result = await cognito.initiateAuth(params).promise();
        
        // Check if MFA is required
        if (result.ChallengeName === 'SOFTWARE_TOKEN_MFA') {
            return {
                statusCode: 200,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    success: true,
                    data: {
                        requiresMfa: true,
                        session: result.Session
                    },
                    message: 'MFA required'
                })
            };
        }
        
        // Direct sign in successful
        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                success: true,
                data: {
                    token: result.AuthenticationResult.IdToken,
                    user: {
                        id: result.AuthenticationResult.AccessToken,
                        email: email,
                        name: 'User Name'  // Get from Cognito attributes
                    },
                    requiresMfa: false
                },
                message: 'Sign in successful'
            })
        };
        
    } catch (error) {
        return {
            statusCode: 401,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                success: false,
                message: error.message || 'Authentication failed'
            })
        };
    }
};
```

### Example 2: Create URL Function (Python)

```python
# Lambda: urls-create

import json
import boto3
import random
import string
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('url-shortener-urls')

def generate_short_code():
    """Generate random 6-character code"""
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(6))

def lambda_handler(event, context):
    # Parse request
    body = json.loads(event['body'])
    original_url = body.get('originalUrl')
    custom_code = body.get('customCode')
    
    # Get user from JWT token (API Gateway authorizer)
    user_id = event['requestContext']['authorizer']['claims']['sub']
    
    # Generate or use custom short code
    short_code = custom_code or generate_short_code()
    
    # Check if custom code already exists
    if custom_code:
        response = table.get_item(Key={'shortCode': short_code})
        if 'Item' in response:
            return {
                'statusCode': 400,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({
                    'success': False,
                    'message': 'Custom code already taken'
                })
            }
    
    # Create URL entry
    url_id = f"url_{int(datetime.now().timestamp() * 1000)}"
    item = {
        'id': url_id,
        'shortCode': short_code,
        'originalUrl': original_url,
        'shortUrl': f"https://short.link/{short_code}",
        'userId': user_id,
        'clickCount': 0,
        'createdAt': datetime.now().isoformat(),
        'isActive': True
    }
    
    # Save to DynamoDB
    table.put_item(Item=item)
    
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'success': True,
            'data': {'url': item},
            'message': 'URL created successfully'
        })
    }
```

### Example 3: Get URLs List Function (Python)

```python
# Lambda: urls-list

import json
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('url-shortener-urls')

def lambda_handler(event, context):
    # Get user ID from JWT
    user_id = event['requestContext']['authorizer']['claims']['sub']
    
    # Query DynamoDB for user's URLs
    response = table.query(
        IndexName='UserIdIndex',
        KeyConditionExpression=Key('userId').eq(user_id)
    )
    
    urls = response['Items']
    
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'success': True,
            'data': {
                'urls': urls,
                'total': len(urls)
            },
            'message': 'URLs retrieved successfully'
        })
    }
```

---

## 🧪 Testing the Connection

### 1. Test with Debug Mode First

```dart
// lib/config.dart
static const bool isDebugMode = true;
```

Run the app - everything should work with mock data.

### 2. Switch to Production Mode

```dart
// lib/config.dart
static const bool isDebugMode = false;
```

### 3. Test Authentication

1. Open app → Sign In screen
2. Enter test credentials
3. Check CloudWatch logs in AWS Lambda
4. Verify JWT token is returned

### 4. Test URL Creation

1. Navigate to Dashboard
2. Click "Create Short URL"
3. Enter a URL
4. Check DynamoDB table for new entry

### 5. Monitor Performance

Check the dashboard footer:
```
Connected to: us-east-1 (Debug Mode)  // Debug
Connected to: us-east-1                // Production
```

---

## 🐛 Troubleshooting

### Issue: "Network Error"

**Cause:** API Gateway URL is incorrect or unreachable

**Solution:**
1. Verify URL in `config.dart` matches API Gateway
2. Check if API Gateway is deployed
3. Test URL in Postman/curl

```bash
curl https://YOUR-API-ID.execute-api.us-east-1.amazonaws.com/prod/urls
```

### Issue: "401 Unauthorized"

**Cause:** Missing or invalid JWT token

**Solution:**
1. Check Cognito configuration
2. Verify API Gateway authorizer is set up
3. Ensure `Authorization` header is sent:

```dart
// middleware/api_client.dart (already implemented)
headers['Authorization'] = 'Bearer $_authToken';
```

### Issue: "403 WAF Blocked"

**Cause:** AWS WAF rules blocking request

**Solution:**
1. Check WAF logs in AWS Console
2. Whitelist your IP if testing
3. Adjust WAF rules for your use case

### Issue: "429 Rate Limit Exceeded"

**Cause:** Too many requests

**Solution:**
1. Check API Gateway throttling settings
2. Implement exponential backoff
3. The app already shows a friendly toast:

```dart
// Middleware automatically detects 429 and shows toast
ThrottlingToast.show(context);
```

### Issue: App stuck in loading

**Cause:** Lambda function timeout or error

**Solution:**
1. Check CloudWatch logs for Lambda errors
2. Increase Lambda timeout (default: 3s → 10s)
3. Check DynamoDB capacity

### Issue: CORS errors in web

**Cause:** API Gateway CORS not configured

**Solution:**

Add to API Gateway response headers:
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS
Access-Control-Allow-Headers: Content-Type,Authorization,X-Region
```

---

## 🎯 Best Practices

### 1. Use Environment Variables

Don't hardcode AWS credentials in Lambda:

```javascript
const COGNITO_CLIENT_ID = process.env.COGNITO_CLIENT_ID;
const DYNAMODB_TABLE = process.env.DYNAMODB_TABLE;
```

### 2. Implement Caching with DAX

For instant dashboard loading:

```python
# Use DAX client instead of DynamoDB
import amazondax
dax = amazondax.AmazonDaxClient()
table = dax.Table('url-shortener-urls')
```

### 3. Add CloudWatch Monitoring

Log important events:

```javascript
console.log('User sign in:', { userId, timestamp: Date.now() });
```

### 4. Secure Your API

- Enable AWS WAF
- Use Cognito JWT authorizer
- Implement rate limiting
- Whitelist allowed origins

### 5. Test in Debug Mode First

Always test new features in debug mode before deploying Lambda changes.

---

## 📊 Performance Tips

### For "Instant" Dashboard Feel

1. **Use DynamoDB DAX** - Microsecond read latency
2. **Optimize Lambda cold starts** - Use provisioned concurrency
3. **Enable HTTP/2** - In API Gateway settings
4. **Add CloudFront CDN** - Cache static responses

### Monitoring Latency

The app shows latency in the footer:

```dart
'Connected to: ${ref.watch(regionProvider)} (Debug Mode)'
```

Add latency tracking:

```dart
// In ApiClient.request()
final start = DateTime.now();
final response = await http.post(...);
final latency = DateTime.now().difference(start);
print('API latency: ${latency.inMilliseconds}ms');
```

---

## 🚀 Deployment Checklist

### Before Going Live

- [ ] Lambda functions deployed in all regions
- [ ] API Gateway configured with CORS
- [ ] Cognito user pool created
- [ ] DynamoDB tables created with DAX
- [ ] WAF rules configured
- [ ] Set `isDebugMode = false`
- [ ] Update all API URLs in `config.dart`
- [ ] Test authentication flow
- [ ] Test URL creation and analytics
- [ ] Monitor CloudWatch logs
- [ ] Set up alarms for errors

### Post-Deployment

- [ ] Test from different regions
- [ ] Monitor latency
- [ ] Check error rates
- [ ] Verify costs are within budget
- [ ] Set up auto-scaling

---

## 💡 Additional Resources

### AWS Documentation

- [AWS Lambda](https://docs.aws.amazon.com/lambda/)
- [API Gateway](https://docs.aws.amazon.com/apigateway/)
- [Amazon Cognito](https://docs.aws.amazon.com/cognito/)
- [DynamoDB DAX](https://docs.aws.amazon.com/amazondax/)

### Flutter Middleware Code

- `lib/config.dart` - Configuration
- `lib/middleware/api_client.dart` - HTTP client
- `lib/providers/providers.dart` - State management

---

## 🎉 You're All Set!

The middleware is **100% plug-and-play**:

1. ✅ Works in debug mode immediately (no setup)
2. ✅ Switch to production by changing one boolean
3. ✅ Add Lambda URLs and you're connected
4. ✅ Multi-region support built-in
5. ✅ Error handling automatic

**Start coding your features now, worry about AWS later!** 🚀

---

## 📞 Need Help?

- Check CloudWatch logs for Lambda errors
- Test API endpoints with Postman
- Enable debug logging in the middleware
- Verify AWS credentials and permissions

**Happy Building!** 💙
