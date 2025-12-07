# 🚀 Quick Start Guide

Get your AWS URL Shortener frontend up and running in minutes!

## Prerequisites

- Flutter SDK 3.0+ installed ([Install Flutter](https://flutter.dev/docs/get-started/install))
- An IDE (VS Code, Android Studio, or IntelliJ)
- Basic knowledge of Flutter and AWS

## 📦 Installation

### 1. Clone & Setup

```bash
cd aws_url_shortner
flutter pub get
```

### 2. Run the App

```bash
# For web
flutter run -d chrome

# For mobile (iOS)
flutter run -d ios

# For mobile (Android)
flutter run -d android
```

The app will start with mock data - you can explore all features without a backend!

## 🎯 What You'll See

### 1. Sign In Screen
- Email/password authentication UI
- "Forgot Password" flow
- Link to Sign Up

**Demo credentials** (mock mode):
- Email: Any email format
- Password: Any password

### 2. Dashboard
- Stats overview (Total URLs, Clicks, Active URLs)
- Recent URLs list
- Quick create button
- Region indicator at bottom

### 3. Create URL
- Enter long URL
- Optional custom short code
- **Optimistic UI** - URL appears created instantly
- Copy and share functionality

### 4. URL Details & Analytics
- Click analytics
- Device breakdown
- Geographic distribution
- Date-based charts

## 🏗️ Project Structure Tour

```
lib/
├── main.dart                    # App entry point
├── models/models.dart          # Data models
├── state/app_state.dart        # State management
├── theme/app_theme.dart        # Theme & colors
├── screens/                    # All app screens
│   ├── auth/                   # Login, signup, MFA
│   ├── dashboard/              # Main dashboard
│   ├── url/                    # URL management
│   └── error/                  # Error screens
└── widgets/                    # Reusable components
```

## 🎨 Customization

### Change Theme Colors

Edit `lib/theme/app_theme.dart`:

```dart
static const Color primaryBlue = Color(0xFF232F3E);    // Change this
static const Color accentTeal = Color(0xFF00A8E1);     // And this
```

### Change App Name

Edit `pubspec.yaml`:

```yaml
name: your_app_name
description: "Your description"
```

### Add Your Logo

Replace the icon in authentication screens:

```dart
Icon(
  Icons.link,  // Replace with your asset
  size: 64,
  color: AppTheme.accentTeal,
)
```

## 🔌 Connect to AWS Backend

### Quick Integration

1. **Create API Service** (see `AWS_INTEGRATION_GUIDE.md`)
2. **Update endpoints** in your API service
3. **Replace mock data** with real API calls
4. **Configure Cognito** for authentication

### Essential AWS Resources

You'll need:
- ✅ Cognito User Pool (authentication)
- ✅ API Gateway (REST endpoints)
- ✅ Lambda functions (business logic)
- ✅ DynamoDB (data storage)
- ✅ S3 + CloudFront (hosting)

See `AWS_INTEGRATION_GUIDE.md` for detailed setup.

## 🧪 Testing Features

### Test Authentication Flow

1. Click "Sign Up" → Fill form → See success message
2. Click "Sign In" → Enter credentials → Goes to MFA
3. Enter MFA code → Goes to Dashboard

### Test URL Creation (Optimistic UI)

1. Click "Create Short URL"
2. Enter a long URL
3. Click "Create" → **Instant success!**
4. URL appears in dashboard immediately

### Test Error Handling

**Throttling (429):**
- Rapidly click create multiple times
- See custom "Slow down!" toast

**WAF Blocked:**
- Navigate to `/waf-blocked` route
- See security-focused error screen

**Session Expired:**
- Trigger session expiry simulation
- See re-auth modal (keeps your work)

## 📱 Platform-Specific Setup

### iOS

```bash
cd ios
pod install
cd ..
flutter run -d ios
```

### Android

No extra setup needed! Just:

```bash
flutter run -d android
```

### Web

```bash
flutter run -d chrome
```

## 🎨 Feature Highlights

### 1. Zero-Latency Dashboard
- **Skeleton loaders** fade in 100-150ms
- Simulates DynamoDB DAX microsecond reads
- No heavy loading spinners

### 2. Optimistic UI
- URLs show as created **instantly**
- Backend processes in background
- Rollback on error

### 3. Smart Error Handling
- **429** → Friendly "slow down" toast
- **WAF** → Security-focused error page
- **401** → Session expired modal
- **Network** → Retry option

### 4. Geo-Awareness
- Shows connected AWS region
- Displays latency (when available)
- Live connection status

## 🔧 Development Tips

### Hot Reload

Save any file to see changes instantly:

```bash
# App is running, then just save files
# Flutter will hot reload automatically!
```

### Debug Mode

```bash
flutter run --debug
```

### Performance Profiling

```bash
flutter run --profile
```

## 📚 Next Steps

1. **Read the Documentation**
   - `FRONTEND_README.md` - Full feature documentation
   - `AWS_INTEGRATION_GUIDE.md` - Backend integration

2. **Customize the UI**
   - Update theme colors
   - Add your branding
   - Modify layouts

3. **Connect to AWS**
   - Set up Cognito
   - Create API Gateway
   - Deploy Lambda functions

4. **Deploy to Production**
   - Build for web: `flutter build web`
   - Upload to S3
   - Configure CloudFront

## 🆘 Common Issues

### "Flutter not found"
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
```

### "No connected devices"
```bash
# For web
flutter run -d chrome

# For mobile
flutter devices  # List available devices
```

### Errors after `flutter pub get`
```bash
flutter clean
flutter pub get
```

## 📞 Need Help?

- **Flutter Docs**: https://flutter.dev/docs
- **AWS Docs**: https://docs.aws.amazon.com
- **GitHub Issues**: Open an issue in the repo

## 🎉 You're Ready!

Your AWS URL Shortener frontend is ready to go. Start exploring the features, customize the UI, and when you're ready, connect it to your AWS backend!

**Happy Coding! 🚀**

---

**Pro Tip**: Run the app now and click around. Everything works with mock data - you can see all features without any backend setup!

```bash
flutter run -d chrome
```
