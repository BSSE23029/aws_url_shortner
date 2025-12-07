# AWS URL Shortener - Flutter Frontend

A modern, enterprise-grade Flutter frontend for URL shortening service designed for AWS serverless deployment.

## 🏗️ Architecture Overview

This Flutter app is specifically designed to work with AWS serverless architecture:
- **Amazon Cognito** - Authentication with MFA support
- **API Gateway** - RESTful API with rate limiting
- **AWS Lambda** - Serverless compute
- **DynamoDB with DAX** - Microsecond-level data access
- **CloudFront** - Global CDN for static assets
- **Route 53** - Geo-routing for optimal performance
- **AWS WAF** - Web Application Firewall for security
- **Global Tables** - Multi-region data replication

## 🎨 Design Features

### Authentication Flow
- ✅ **Sign In** - Clean email/password authentication
- ✅ **Sign Up** - Account creation with validation
- ✅ **MFA Screen** - 6-digit TOTP code input with auto-submit
- ✅ **Forgot Password** - Password reset flow with email confirmation
- ✅ **Session Expired Modal** - Re-authenticate without losing work

### Dashboard (Optimized for DAX)
- ✅ **Zero Latency Feel** - Skeleton loaders that vanish almost instantly
- ✅ **Stats Overview** - Total URLs, clicks, and active links
- ✅ **Recent URLs List** - Quick access to latest shortened URLs
- ✅ **Pull to Refresh** - Manual refresh capability

### URL Management
- ✅ **Optimistic UI** - URLs appear created instantly before backend confirms
- ✅ **Create Short URL** - With optional custom code
- ✅ **URL Details** - Comprehensive analytics view
- ✅ **Analytics Dashboard** - Clicks by date, country, and device

### Error Handling & Security
- ✅ **WAF Blocked Screen** - Security-focused error page for blocked requests
- ✅ **429 Throttling Toast** - Friendly "slow down" notification for rate limits
- ✅ **Network Errors** - Graceful handling with retry options
- ✅ **Session Management** - Automatic token refresh and expiry handling

### Geo-Awareness
- ✅ **Region Indicator** - Shows which AWS region is serving the request
- ✅ **Latency Display** - Optional latency indicator
- ✅ **Connection Status** - Live connection indicator

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point with routing
├── models/
│   └── models.dart               # Data models (URL, User, Analytics, API Response)
├── state/
│   └── app_state.dart            # Simple state management (no external packages)
├── theme/
│   └── app_theme.dart            # AWS-inspired blue/teal theme
├── screens/
│   ├── auth/
│   │   ├── sign_in_screen.dart
│   │   ├── sign_up_screen.dart
│   │   ├── mfa_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── url/
│   │   ├── create_url_screen.dart
│   │   └── url_details_screen.dart
│   └── error/
│       └── waf_blocked_screen.dart
└── widgets/
    ├── skeleton_loader.dart       # DAX-optimized loading animation
    ├── session_expired_dialog.dart
    ├── toast_notifications.dart   # Error and success toasts
    └── region_indicator.dart      # Geo-awareness indicators
```

## 🎨 Theme & Colors

**Primary Palette (AWS-inspired):**
- Primary Blue: `#232F3E` - AWS Dark Blue
- Accent Teal: `#00A8E1` - AWS Teal
- Light Blue: `#527FFF` - Interactive elements

**Semantic Colors:**
- Success: `#4CAF50`
- Warning: `#FF9800`
- Error: `#E53935`
- Security Alert: `#D32F2F` (for WAF blocks)

## 🚀 Key Features Implementation

### 1. Optimistic UI Updates
```dart
// URL is shown as created immediately
final newUrl = UrlModel(...);
appState.addUrlOptimistic(newUrl);

// Backend call happens in background
_createUrlInBackground(newUrl);
```

### 2. Skeleton Loaders (DAX Speed)
- Animated gradient effect
- Instant disappearance (100-150ms)
- Used for URL lists and stats cards

### 3. Error State Management
```dart
enum ApiErrorType {
  networkError,
  sessionExpired,
  rateLimitExceeded,  // 429 - Throttling toast
  wafBlocked,          // Security blocked
  validationError,
  serverError,
}
```

### 4. Session Management
- JWT token storage in state
- Automatic session expiry detection
- Re-authentication modal without navigation

### 5. Region Awareness
- Displays current serving region (e.g., "us-east-1")
- Shows latency when available
- Live connection status indicator

## 📱 Screen Flows

### Authentication
```
Sign In → MFA (if enabled) → Dashboard
         ↓
    Forgot Password → Email Sent → Sign In
         ↓
    Sign Up → Verification Email → Sign In
```

### URL Creation
```
Dashboard → Create URL → Success Screen → Dashboard
                ↓
           (Optimistic UI - instant feedback)
                ↓
           (Lambda processes in background)
```

### Error Handling
```
API Call → 429 Rate Limit → Throttling Toast (temporary)
        → WAF Block → WAF Blocked Screen
        → Session Expired → Re-auth Modal
        → Network Error → Error Toast with Retry
```

## 🔧 Development

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- No external packages required (pure Flutter implementation)

### Run the App
```bash
# Get dependencies
flutter pub get

# Run on your preferred device
flutter run

# Build for web (AWS S3 + CloudFront deployment)
flutter build web --release

# Build for mobile
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Integration with AWS Backend

To integrate with your AWS backend, update the API calls in:
1. Authentication screens → Call Cognito APIs
2. Dashboard → Fetch URLs from DynamoDB via API Gateway
3. Create URL → POST to Lambda via API Gateway
4. Analytics → Query DynamoDB for click data

Example API structure:
```dart
// In your API service
class ApiService {
  static const String baseUrl = 'https://your-api-gateway-url.amazonaws.com';
  
  Future<ApiResponse<List<UrlModel>>> fetchUrls() async {
    // Call GET /urls with JWT token
    // Parse response from Lambda
  }
  
  Future<ApiResponse<UrlModel>> createUrl(String originalUrl) async {
    // Call POST /urls with body
    // Return created URL with short code
  }
}
```

## 🌐 AWS Deployment

### Frontend Hosting (Recommended)
1. **Build**: `flutter build web --release`
2. **Upload to S3**: Copy `build/web/*` to S3 bucket
3. **CloudFront**: Configure distribution pointing to S3
4. **Route 53**: Set up DNS with geo-routing

### Benefits of AWS Serverless
- ⚡ **Near-Zero Latency**: DAX caching for microsecond reads
- 🌍 **Global Reach**: CloudFront edge locations worldwide
- 🔒 **Enterprise Security**: WAF protection, Cognito MFA
- 📈 **Auto-Scaling**: Lambda scales automatically
- 💰 **Cost-Effective**: Pay only for what you use

## 🎯 Design Principles

1. **Zero Latency Feel**: UI responds instantly, backend catches up
2. **Security-First**: Clear communication about WAF blocks and security
3. **Geo-Awareness**: Users see which region serves them
4. **Error Transparency**: Specific error messages for different failure modes
5. **Enterprise Grade**: Professional, trustworthy design aesthetic

## 📝 Notes

- No external state management packages (Provider, Riverpod, etc.)
- No external HTTP packages - use `dart:io` or implement your own
- Pure Flutter widgets and animations
- Optimized for web and mobile deployment
- Material Design 3 with custom theme

## 🔜 Next Steps for Production

1. **Integrate Real APIs**: Replace mock data with actual AWS API Gateway calls
2. **Add Clipboard**: Implement copy-to-clipboard for short URLs
3. **Add Analytics SDK**: Integrate AWS Pinpoint or similar
4. **Error Tracking**: Add error reporting service
5. **Performance Monitoring**: Implement performance tracking
6. **Offline Support**: Add local caching for offline viewing
7. **Push Notifications**: Integrate with SNS for alerts

## 📄 License

This project structure and code are provided as a template for AWS serverless deployment.

---

**Built with Flutter 💙 | Designed for AWS ☁️**
