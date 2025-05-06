# DermAssist - Skin Disease Detection & Management App

A comprehensive Flutter application for skin disease detection, management, and dermatology consultation. 

## 📱 Features

- **AI-Powered Skin Disease Detection**: Upload photos of skin conditions for instant analysis
- **Virtual Dermatologist Consultations**: Book and manage appointments with dermatologists
- **Interactive Chatbot**: Get quick answers to skin health questions
- **Informative Articles**: Access a library of skin health and disease information
- **User Profiles**: Track your skin health history and manage personal information

## 🏗️ Architecture

This application follows a structured architecture:

- **Flutter UI**: Material Design-based user interface with responsive layouts
- **Provider State Management**: Centralized and reactive state management
- **Firebase Backend**: Authentication, database, storage, and hosting
- **ML Model Integration**: TensorFlow Lite for on-device machine learning
- **RESTful API**: For chatbot and external service integrations

## 📂 Project Structure

```
lib/
│
├── main.dart              # Entry point
├── screens/               # UI screens/pages
├── widgets/               # Reusable UI components
├── services/              # Business logic and API services
├── models/                # Data models
└── utils/                 # Utilities and common functions
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest stable version)
- Android Studio or VS Code with Flutter extensions
- Firebase account
- An Android or iOS device/emulator

### Setup Instructions

1. **Clone the repository**
   ```
   git clone <repository-url>
   cd skin_disease_app
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Firebase Configuration**
   - Create a new Firebase project
   - Configure Firebase for Android/iOS
   - Add the Firebase configuration files (`google-services.json` or `GoogleService-Info.plist`)
   - Enable Firebase services: Authentication, Firestore, Storage

4. **Run the application**
   ```
   flutter run
   ```

## 🔥 Firebase Integration

This app uses the following Firebase services:

- **Authentication**: Email/password user authentication
- **Firestore**: Store user profiles, dermatologist data, articles, and appointment information
- **Storage**: Store skin images, doctor profiles, and article thumbnails
- **ML Kit** (optional): For advanced image processing

## 🧠 ML Model Integration

The skin disease detection uses a TensorFlow Lite model:

1. Train a TensorFlow model for skin disease classification
2. Convert it to TensorFlow Lite format
3. Add the model to the `/assets/ml/` directory
4. The app uses the TFLite Flutter plugin to run inference on-device

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 📞 Contact

For questions and support, please contact the development team.
