# Campus Connect 🏫

A modern Flutter application designed to help campus communities connect and manage lost & found items, report issues, and build a stronger campus environment.

## 🌟 Features

### 🔍 Smart Lost & Found System
- **Intelligent Matching**: AI-powered algorithm to match lost and found items
- **Multi-field Search**: Search by item name, description, or location
- **Advanced Filtering**: Filter by category, status, and ownership
- **Contact Information**: Collect and display reporter contact details
- **Status Tracking**: Real-time status updates (Lost, Found, Claimed, Returned)

### 🎨 Modern UI/UX
- **Glassmorphism Design**: Beautiful frosted glass effects
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Responsive Layout**: Works on all screen sizes and orientations
- **Dark/Light Theme**: Adaptive theming system
- **Status Indicators**: Color-coded badges and visual feedback

### 🔧 Issue Reporting
- **Campus Issues**: Report and track campus-related problems
- **Category System**: Organized issue categorization
- **Status Management**: Track issue resolution progress

### 👤 User Management
- **Authentication**: Secure user registration and login
- **Profile Management**: User profiles with preferences
- **Contact Preferences**: Flexible contact method selection

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd campus_connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Add your `google-services.json` to `android/app/`
   - Enable Authentication, Firestore, and Storage

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── found_item.dart
│   ├── lost_item.dart
│   └── issue.dart
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── home_screen.dart      # Main dashboard
│   ├── lost_and_found/       # Lost & found features
│   ├── issues/               # Issue reporting
│   └── profile_screen.dart   # User profile
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── database_service.dart
│   └── storage_service.dart
├── providers/                # State management
├── utils/                    # Utilities and styles
└── test/                     # Test files
```

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication (Email/Password, Google Sign-in)
3. Create Firestore database
4. Enable Storage for image uploads
5. Add configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

## 🎯 Key Features Explained

### Smart Matching Algorithm
The app uses a sophisticated matching system that considers:
- **Name Similarity**: Levenshtein distance calculation
- **Location Proximity**: Geographic and textual location matching
- **Category Matching**: Item categorization
- **Time Relevance**: Temporal proximity of events

### Advanced Search & Filtering
- **Multi-field Search**: Search across item names, descriptions, and locations
- **Category Filters**: Filter by Electronics, Books, Clothing, etc.
- **Status Filters**: Filter by Lost, Found, Claimed, Returned
- **Ownership Filters**: Show only user's own items

### Modern Navigation
- **Glassmorphism Design**: Beautiful frosted glass effects
- **Smooth Animations**: Fade transitions between screens
- **Responsive Design**: Adapts to different screen sizes

## 🛠️ Technologies Used

- **Frontend**: Flutter, Dart
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Provider pattern
- **UI/UX**: Material Design 3, Glassmorphism
- **Image Handling**: Image Picker, Firebase Storage
- **Navigation**: Custom page routes with animations

## 📊 Database Schema

### Collections
- `users`: User profiles and preferences
- `lost_items`: Lost item reports
- `found_items`: Found item reports
- `issues`: Campus issue reports

### Key Fields
- **Items**: name, description, category, location, status, timestamps
- **Users**: email, name, contact preferences, profile data
- **Issues**: title, description, category, status, reporter info

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Developer

**Developed by Abhinav**

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Material Design for UI guidelines
- The campus community for inspiration

---

**Campus Connect** - Connecting campuses, one item at a time! 🏫✨
