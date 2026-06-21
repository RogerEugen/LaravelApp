# Learn Laravel - Kiswahili Learning Platform

A complete full-stack educational application designed to teach the Laravel web framework to learners in **Kiswahili language**. This project combines a modern REST API backend with a feature-rich Flutter mobile application.

**Tagline:** Learn Laravel kwa Kiswahili kupitia masomo na quizzes (Learn Laravel in Kiswahili through lessons and quizzes)

---

## 📋 Project Overview

This application provides an accessible, interactive platform for students to master the Laravel framework through:

- 📚 **Structured Lessons** - Progressive learning modules in Kiswahili
- 🎯 **Interactive Quizzes** - Test your knowledge and get immediate feedback
- 📊 **Progress Tracking** - Monitor learning journey and achievement
- 💬 **Real-Time Chat** - Community support and admin assistance via WebSocket
- 👤 **User Authentication** - Secure token-based access control
- 🎨 **Modern Mobile Experience** - Cross-platform iOS and Android app
- ⚙️ **Admin Dashboard** - Course and user management panel

---

## 🎯 Primary Goal

**Make Laravel education accessible to Kiswahili-speaking developers** through a comprehensive learning platform that combines theoretical knowledge with practical exercises.

---

## 🛠️ Technology Stack

### Backend Architecture

| Technology | Purpose | Version |
|-----------|---------|---------|
| **PHP** | Server-side language (31% of codebase) | 8.3+ |
| **Laravel Framework** | Web application framework | 13.8+ |
| **Laravel Reverb** | WebSocket server for real-time features | 1.10+ |
| **Laravel Sanctum** | API token authentication | 4.3+ |
| **Blade** | Server-side templating (18.6% of codebase) | Built-in |
| **MySQL** | Relational database | 5.7+ |
| **Tailwind CSS** | Utility-first CSS framework | 4.0+ |
| **Vite** | Frontend build tool | 8.0+ |

### Frontend Architecture

| Technology | Purpose | Details |
|-----------|---------|---------|
| **Dart** | Programming language (37% of codebase) | 3.11.5+ |
| **Flutter** | Cross-platform mobile framework | Latest stable |
| **HTTP** | API communication | http: ^1.5.0 |
| **WebSocket** | Real-time messaging | web_socket_channel: ^3.0.3 |
| **Local Storage** | User preferences | shared_preferences: ^2.5.3 |
| **Audio** | Notification sounds | audioplayers: ^6.7.1 |
| **Image Picker** | Profile photo upload | image_picker: ^1.2.2 |
| **File Picker** | File selection | file_picker: ^11.0.2 |

### Build & Infrastructure

| Component | Purpose |
|-----------|---------|
| **C++** (6.6% of codebase) | Performance-critical components |
| **CMake** (5.1% of codebase) | Build system for native code |
| **Swift** (0.6% of codebase) | iOS-specific optimizations |
| **Android NDK** | Android native development |

---

## 📁 Project Structure

```
LaravelApp/
│
├── LearningApp/                    # Laravel REST API Backend
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/        # API endpoint handlers
│   │   │   ├── Middleware/         # Authentication & request processing
│   │   │   └── Requests/           # Form validation rules
│   │   ├── Models/                 # Database models (User, Lesson, Quiz, etc.)
│   │   └── Services/               # Business logic
│   │
│   ├── routes/
│   │   └── api.php                 # API v1 routes (/api/v1/*)
│   │
│   ├── database/
│   │   ├── migrations/             # Schema definitions
│   │   ├── factories/              # Model factories for testing
│   │   └── seeders/                # Sample data (demo account, topics)
│   │
│   ├── config/
│   │   ├── reverb.php              # WebSocket configuration
│   │   ├── sanctum.php             # Authentication settings
│   │   └── database.php            # Database connection
│   │
│   ├── resources/
│   │   └── js/                     # Frontend assets (CSS, component styles)
│   │
│   ├── .env.example                # Environment variables template
│   ├── composer.json               # PHP dependencies
│   ├── package.json                # Node.js dev dependencies
│   └── README.md                   # Backend setup instructions
│
├── learningapk/                    # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── screens/                # UI screens
│   │   │   ├── LoginScreen.dart
│   │   │   ├── LessonScreen.dart
│   │   │   ├── QuizScreen.dart
│   │   │   ├── ChatScreen.dart
│   │   │   └── ProfileScreen.dart
│   │   ├── services/               # API & WebSocket services
│   │   ├── models/                 # Data models
│   │   ├── providers/              # State management
│   │   └── widgets/                # Reusable UI components
│   │
│   ├── assets/
│   │   └── icon/                   # App icons and images
│   │
│   ├── android/                    # Android configuration
│   │   ├── app/build.gradle        # Android build settings
│   │   └── AndroidManifest.xml     # Android permissions & config
│   │
│   ├── ios/                        # iOS configuration
│   │   ├── Podfile                 # iOS dependencies
│   │   └── Runner/                 # iOS app configuration
│   │
│   ├── pubspec.yaml                # Flutter dependencies
│   └── README.md                   # Flutter setup instructions
│
└── README.md                       # This file - Project documentation
```

---

## ✨ Key Features

### 👥 User Roles & Access Control

1. **Guest Users**
   - Browse public landing page
   - View available topics
   - Read lesson content
   - Cannot attempt quizzes or save progress

2. **Authenticated Students**
   - Complete authentication with email/password
   - Attempt and submit quizzes
   - Save learning progress
   - Participate in community chat
   - Upload profile picture (JPG, PNG, WebP - max 5 MB)
   - Switch between English and Kiswahili interface
   - Receive real-time chat notifications

3. **Administrators (Owner)**
   - All student capabilities
   - View user management dashboard
   - Manage course content (topics and lessons)
   - Monitor user progress and quiz attempts
   - Send messages to users via real-time chat
   - View analytics and reports

### 📚 Learning Features

- **Progressive Curriculum** - Topics organized with lessons in sequence
- **Quiz System** - Multiple-choice and short-answer questions
- **Immediate Feedback** - Quiz results with explanations
- **Progress Saving** - Automatic progress tracking per lesson and quiz
- **Language Support** - Full Kiswahili and English interfaces
- **Offline Access** - Lessons can be cached for offline viewing

### 💬 Real-Time Communication

- **WebSocket Protocol** - Pusher-compatible endpoint via Laravel Reverb
- **Live Chat** - Student-to-admin messaging
- **Community Chat** - Student-to-student discussion
- **Notification Sounds** - Audio alerts for new messages
- **Persistent Storage** - Chat history maintained in database

### 🔐 Security Features

- **Sanctum Token Authentication** - Secure API token-based access
- **Request Validation** - Input validation on all endpoints
- **CORS Protection** - Cross-origin request handling
- **Rate Limiting** - Protect against abuse
- **Password Hashing** - bcrypt (12 rounds)
- **Session Management** - Database-backed sessions with 120-minute lifetime

### 📱 Mobile App Features

- **Cross-Platform** - Works on iOS (any version) and Android 7.0+ (API 24+)
- **Responsive UI** - Material Design implementation
- **Local Storage** - Preferences saved on device (language, theme)
- **Image Upload** - Camera or gallery profile pictures
- **Audio Notifications** - Backend notification sounds play on incoming messages
- **Smooth Navigation** - Intuitive screen transitions and user flow

---

## 🚀 Getting Started

### Prerequisites

**Backend (Laravel):**
- PHP 8.3 or higher
- MySQL 5.7 or higher
- Composer (PHP package manager)
- Node.js 18+ (for frontend assets)

**Mobile (Flutter):**
- Flutter SDK (latest stable)
- Dart SDK (included with Flutter)
- Android Studio (for Android development)
- Xcode (for iOS development on Mac)
- iOS deployment target: 12.0+
- Android minimum SDK: API 24 (Android 7.0)

### Backend Setup (Laravel)

#### Step 1: Install PHP Dependencies
```bash
cd LearningApp
composer install
```

#### Step 2: Configure Environment
```bash
cp .env.example .env
php artisan key:generate
```

#### Step 3: Setup Database
Update `.env` with your database credentials:
```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=learningapp
DB_USERNAME=root
DB_PASSWORD=your_password
```

#### Step 4: Run Migrations & Seeders
```bash
php artisan migrate --seed
```

This creates the database schema and populates demo data (demo account, sample topics, and lessons).

#### Step 5: Install Frontend Dependencies
```bash
npm install
npm run build
```

#### Step 6: Start Services

**Terminal 1 - Laravel API Server:**
```bash
php artisan serve --host=0.0.0.0 --port=8000
```

**Terminal 2 - WebSocket Server (Reverb):**
```bash
php artisan reverb:start --host=0.0.0.0 --port=8080
```

Or run both simultaneously:
```bash
composer run dev
```

✅ Backend is ready at: `http://localhost:8000`

### Mobile Setup (Flutter)

#### Step 1: Install Dependencies
```bash
cd ../learningapk
flutter pub get
```

#### Step 2: Run on Android Emulator
```bash
flutter run
```

The app automatically connects to:
- **API:** `http://10.0.2.2:8000/api/v1`
- **WebSocket:** `ws://10.0.2.2:8080`

#### Step 3: Run on Physical Device
Determine your computer's LAN IP (e.g., `192.168.1.10`):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

**Important:** 
- Computer and phone must be on the same WiFi network
- Update `.env` on backend: `REVERB_PUBLIC_HOST=192.168.1.10`
- Laravel must run with `--host=0.0.0.0`

---

## 🔑 Demo Credentials

### Student Demo Account
- **Email:** `demo@learnlaravel.co.tz`
- **Password:** `password123`

### Admin Owner Account
- **Username:** `rogers`
- **Password:** `roger123`

---

## 🔌 API Documentation

### Base URL
```
http://localhost:8000/api/v1
```

### Authentication
Protected endpoints require the following headers:
```
Authorization: Bearer YOUR_SANCTUM_TOKEN
Accept: application/json
Content-Type: application/json
```

### Example Protected Request
```bash
curl -H "Authorization: Bearer your_token" \
     -H "Accept: application/json" \
     http://localhost:8000/api/v1/user/profile
```

### Core Endpoints

#### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - Create new account
- `POST /auth/logout` - End session
- `GET /auth/user` - Get current user profile

#### Lessons & Topics
- `GET /topics` - List all topics (public)
- `GET /topics/{id}/lessons` - Get lessons in topic
- `GET /lessons/{id}` - Get lesson details
- `POST /lessons/{id}/progress` - Save lesson progress

#### Quizzes
- `GET /quizzes` - List available quizzes
- `GET /quizzes/{id}` - Get quiz questions
- `POST /quizzes/{id}/submit` - Submit quiz attempt

#### Chat
- `GET /messages` - Fetch chat history
- `POST /messages` - Send new message
- **WebSocket:** Connect to `ws://localhost:8080` for real-time updates

#### User Profile
- `GET /user/profile` - Current user data
- `POST /user/profile/update` - Update profile
- `POST /user/profile/avatar` - Upload profile picture
- `POST /user/language` - Update language preference (en/sw)

---

## 🗄️ Database Schema

### Core Tables

**users** - User accounts and authentication
- id, email, username, password_hash, profile_picture, language, created_at, updated_at

**topics** - Learning topics
- id, name, description, order, created_at

**lessons** - Individual lessons
- id, topic_id, title, content, duration_minutes, order, created_at

**quizzes** - Quiz collections
- id, topic_id, title, description, pass_threshold_percent, created_at

**questions** - Quiz questions
- id, quiz_id, question_text, question_type, correct_answer, created_at

**quiz_attempts** - User quiz submissions
- id, user_id, quiz_id, answers_json, score, passed, submitted_at

**lesson_progress** - User lesson tracking
- id, user_id, lesson_id, completed, progress_percent, last_viewed_at

**messages** - Chat history
- id, sender_id, recipient_id, message_text, read_at, created_at

---

## 🔧 Environment Configuration

### Key Environment Variables

**Application:**
```dotenv
APP_NAME=Laravel
APP_ENV=production or local
APP_DEBUG=false (in production)
APP_URL=http://localhost
APP_LOCALE=en
```

**Database:**
```dotenv
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=learningapp
DB_USERNAME=root
DB_PASSWORD=
```

**Authentication:**
```dotenv
SESSION_DRIVER=database
SESSION_LIFETIME=120 (minutes)
SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
```

**WebSocket (Reverb):**
```dotenv
BROADCAST_CONNECTION=reverb
REVERB_APP_ID=learn-laravel-tz
REVERB_APP_KEY=learn-laravel-key
REVERB_APP_SECRET=learn-laravel-secret-change-in-production
REVERB_HOST=127.0.0.1
REVERB_PORT=8080
REVERB_PUBLIC_HOST=10.0.2.2 (for Android emulator)
REVERB_PUBLIC_PORT=8080
REVERB_PUBLIC_SCHEME=ws
```

**File Storage:**
```dotenv
FILESYSTEM_DISK=local
# Profile photos stored in storage/app/public
# Accessible at: storage/app/public/profile-pictures/
```

---

## 🧪 Testing

### Laravel Testing
```bash
cd LearningApp
php artisan test
```

Tests are located in `tests/` directory and use:
- **Pest** - Modern testing framework (4.7+)
- **Mockery** - Mocking library (1.6+)
- **Factory Pattern** - Model factories for test data

### Flutter Testing
```bash
cd learningapk
flutter test
```

---

## 📦 Dependencies Overview

### Backend (composer.json)
```
laravel/framework       ^13.8      - Core framework
laravel/reverb         ^1.10      - WebSocket server
laravel/sanctum        ^4.3       - API authentication
laravel/tinker         ^3.0       - REPL for debugging
fakerphp/faker        ^1.23      - Test data generation
pestphp/pest          ^4.7       - Testing framework
```

### Mobile (pubspec.yaml)
```
flutter                          - SDK
flutter_localizations          - I18n support (English/Kiswahili)
http: ^1.5.0                    - HTTP client
web_socket_channel: ^3.0.3      - WebSocket client
shared_preferences: ^2.5.3      - Local storage
audioplayers: ^6.7.1            - Sound notifications
image_picker: ^1.2.2            - Photo selection
video_player: ^2.11.1           - Video playback (for tutorials)
file_picker: ^11.0.2            - File selection
url_launcher: ^6.3.2            - Open external links
```

---

## 🔌 Network Configuration

### Development (Local Machine)

**Android Emulator:**
```
API Server:    http://10.0.2.2:8000/api/v1
WebSocket:     ws://10.0.2.2:8080
```

**iOS Simulator:**
```
API Server:    http://localhost:8000/api/v1
WebSocket:     ws://localhost:8080
```

### Physical Devices

Find your computer's LAN IP:
```bash
# macOS/Linux
ifconfig | grep "inet 192"

# Windows
ipconfig
```

Example: `192.168.1.10`

**Flutter Launch:**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

**Backend Configuration (.env):**
```dotenv
REVERB_PUBLIC_HOST=192.168.1.10
```

---

## 🎓 Learning Progression

### Curriculum Structure

1. **Foundations** - Laravel basics, routing, controllers
2. **Database** - Eloquent ORM, migrations, relationships
3. **API Development** - RESTful API design, authentication
4. **Advanced Features** - Real-time messaging, file uploads, caching
5. **Deployment** - Production setup, environment configuration

---

## 🚢 Deployment

### Production Checklist

- [ ] Set `APP_ENV=production` in `.env`
- [ ] Set `APP_DEBUG=false` in `.env`
- [ ] Generate new `APP_KEY`
- [ ] Update `REVERB_APP_SECRET` to secure value
- [ ] Configure MySQL on production server
- [ ] Setup SSL/TLS certificates
- [ ] Configure email service (update MAIL_* variables)
- [ ] Run `php artisan migrate --force`
- [ ] Build Flutter app for production:
  ```bash
  flutter build apk --release    # Android
  flutter build ios --release    # iOS
  ```

---

## 🐛 Troubleshooting

### Backend Issues

**WebSocket connection fails:**
- Ensure Reverb is running: `php artisan reverb:start --host=0.0.0.0 --port=8080`
- Check firewall allows port 8080
- Verify `REVERB_PUBLIC_HOST` matches your network

**Database connection error:**
- Verify MySQL is running
- Check `.env` database credentials
- Run migrations: `php artisan migrate`

**CORS errors in Flutter:**
```dotenv
SESSION_SECURE_COOKIES=false    # in development
SANCTUM_STATEFUL_DOMAINS=localhost,192.168.1.10
```

### Mobile Issues

**App won't connect to API:**
- Verify backend is running: `php artisan serve --host=0.0.0.0 --port=8000`
- Check API URL in app (should be `http://10.0.2.2:8000/api/v1` for emulator)
- Ensure phone and computer are on same network (physical device)

**Profile picture won't upload:**
- Check file size < 5 MB
- Verify file format is JPG, PNG, or WebP
- Check storage permissions in Android/iOS settings

**Chat messages not appearing:**
- Verify WebSocket connection with: `php artisan reverb:start`
- Check browser console for connection errors
- Restart both backend services

---

## 📝 Development Workflow

### Quick Start
```bash
# Terminal 1: Backend
cd LearningApp
composer install
php artisan migrate --seed
composer run dev

# Terminal 2: Mobile
cd learningapk
flutter pub get
flutter run
```

### Common Commands

**Backend:**
```bash
php artisan migrate              # Run database migrations
php artisan tinker              # Interactive shell
php artisan make:model Lesson   # Generate model
php artisan test                # Run tests
npm run dev                     # Build frontend assets
```

**Mobile:**
```bash
flutter clean                   # Clean build
flutter pub get                 # Install dependencies
flutter run --device=<id>       # Run on specific device
flutter build apk --release     # Build APK
```

---

## 📞 Support & Contribution

- **Issues:** Report bugs via GitHub Issues
- **Discussions:** Ask questions in GitHub Discussions
- **Pull Requests:** Contributions welcome!

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙌 Acknowledgments

This project was created to make Laravel education accessible to Kiswahili-speaking developers. It demonstrates best practices in:

- Laravel API development
- Flutter mobile development
- Real-time WebSocket communication
- Token-based authentication
- Cross-platform application design

---

**Last Updated:** June 21, 2026

**Version:** 1.0.0

**Status:** Active Development

---

*Learn Laravel kwa Kiswahili - Making web development education accessible to East African developers.*
