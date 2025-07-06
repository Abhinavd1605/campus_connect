# Campus Connect

**A Campus Management Application with AI-Powered Smart Features**

Developed for IIITDM Kancheepuram App Development Hackathon 2025  
Individual Submission by Abhinav  
Duration: 24-Hour Hackathon Challenge  
Category: Complete Campus Solution with Advanced Features

---

## Overview

Campus Connect is a comprehensive campus management application designed to streamline communication and problem-solving within educational institutions. The app focuses on two core functionalities: an intelligent lost and found system and an anonymous issue reporting platform.

## Key Features

### AI-Powered Smart Matching System
- Advanced Levenshtein distance-based algorithm for matching lost and found items
- Multi-factor scoring system that considers name similarity, location proximity, category matching, and temporal relevance
- Real-time suggestions showing top 5 potential matches with confidence scores
- Proactive matching alerts for users

### Advanced Search and Filtering Engine
- Multi-field search across item names, descriptions, locations, and categories
- Comprehensive filtering options including category, status, ownership, and date-based filters
- Visual filter management with active filter chips
- Auto-complete and search suggestions

### Modern User Interface
- Glassmorphism design with frosted glass effects
- Smooth animations with 60fps transitions and micro-interactions
- Responsive design that adapts to all screen sizes
- Color-coded status indicators and visual feedback
- Adaptive theming system

### Enhanced Security and Privacy
- Anonymous issue reporting channel for campus problems
- Flexible privacy controls for user contact preferences
- Firebase-based authentication and user management
- End-to-end data encryption

## Core Functionality

### Lost and Found Tracker
- Multi-step form for reporting lost or found items with optional image upload
- Advanced search and filtering capabilities for browsing items
- One-click status updates for claiming or returning items
- Image support through Firebase Storage integration
- Direct communication system between users

### Anonymous Campus Issue Reporter
- Secure anonymous issue submission system
- Organized problem categorization (Maintenance, Safety, Inconvenience)
- Real-time issue resolution progress tracking
- Priority management system (High, Medium, Low)
- Campus location identification

### User Management
- Firebase Authentication with email/password
- User profiles with customizable preferences
- Flexible contact method selection
- User-controlled data sharing and privacy settings

## **SCREENSHOTS & DEMO**

### **Key Screenshots:**
- **Splash Screen**: Animated logo with glassmorphism
- **Home Dashboard**: Stats cards and quick actions
- **Lost & Found**: Advanced search and filtering
- **Item Details**: Smart matching suggestions
- **Issue Reporting**: Anonymous submission form
- **Profile**: User management and preferences

### **Demo Video**: [Link to be added]
## Technical Implementation

### Frontend
- **Framework**: Flutter 3.0+ (Cross-platform development)
- **Language**: Dart 3.0+
- **UI Framework**: Material Design 3 with custom glassmorphism components
- **State Management**: Provider Pattern
- **Navigation**: Custom animated page routes

### Backend and Services
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore (NoSQL)
- **Storage**: Firebase Storage for image handling
- **Real-time Updates**: Firestore real-time listeners
- **Hosting**: Firebase Hosting for web version

### Advanced Algorithms
- **Smart Matching**: Levenshtein distance algorithm for item matching
- **Search Engine**: Multi-field fuzzy search implementation
- **Filtering System**: Dynamic query optimization
- **Image Processing**: Automatic image compression and optimization

## Installation

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio or VS Code
- Firebase project setup

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd campus_connect
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication (Email/Password method)
   - Create Firestore database
   - Enable Storage service
   - Download `google-services.json` and place it in `android/app/`

4. **Run the Application**
   ```bash
   flutter run
   ```

### Build Release APK
```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── found_item.dart      # Found item model with contact information
│   ├── lost_item.dart       # Lost item model
│   └── issue.dart           # Issue reporting model
├── screens/                  # User interface screens
│   ├── auth/                # Authentication screens (Login/Register)
│   ├── home_screen.dart     # Dashboard with statistics
│   ├── lost_and_found/      # Lost and found features
│   ├── issues/              # Issue reporting system
│   └── profile_screen.dart  # User profile management
├── services/                 # Business logic services
│   ├── auth_service.dart    # Firebase authentication service
│   ├── database_service.dart # Firestore operations with smart matching
│   └── storage_service.dart # Firebase storage for images
├── providers/                # State management
├── utils/                    # Styles and utilities
└── test/                     # Unit and widget tests
```

## Key Innovations

### Smart Matching Algorithm
The application implements an advanced matching system using the Levenshtein distance algorithm to calculate string similarity between lost and found items. This ensures accurate matching with confidence scoring.

```dart
double _calculateStringSimilarity(String s1, String s2) {
  int distance = _levenshteinDistance(s1, s2);
  int maxLength = s1.length > s2.length ? s1.length : s2.length;
  return 1.0 - (distance / maxLength);
}
```

### Glassmorphism Design Implementation
The UI features modern glassmorphism effects with careful attention to accessibility and performance.

```dart
BoxDecoration glassmorphismBoxDecoration(BuildContext context) {
  return BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.2)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  );
}
```

### Advanced Search Implementation
Multi-field search with fuzzy matching capabilities for enhanced user experience.

```dart
items.where((item) =>
  item.itemName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
  item.description.toLowerCase().contains(_searchTerm.toLowerCase()) ||
  item.location.toLowerCase().contains(_searchTerm.toLowerCase())
).toList();
```

## Testing

The application includes comprehensive testing coverage:
- Unit tests for core algorithms and business logic
- Widget tests for UI components
- Integration tests for complete user workflows

## Performance Optimization

- Efficient image compression and caching
- Lazy loading for large datasets
- Optimized database queries
- Memory management for smooth performance

## Security Features

- Input validation and sanitization
- Secure data transmission
- User privacy protection
- Anonymous reporting capabilities

## Future Enhancements

- Push notifications for match alerts
- Advanced analytics dashboard
- Multi-language support
- Integration with campus management systems

## Developer Information

**Name**: Abhinav  
**Institution**: IIITDM Kancheepuram  
**Contact**: Abhinavreddyd2005@gmail.com  

## License

This project is developed as part of the IIITDM Kancheepuram App Development Hackathon 2025.

---

*Campus Connect - Streamlining campus communication and problem-solving through intelligent technology solutions.*
