# Flutter BLoC MVVM Base App

![Flutter](https://img.shields.io/badge/Flutter-3.24.3-blue.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

A scalable and maintainable **Flutter base project** combining the **BLoC (Business Logic Component)** and **MVVM (Model-View-ViewModel)** architectures. Designed for clean code structure, testability, and ease of feature addition.

---

## 🌟 Features

- **Architecture**: MVVM + BLoC with separation of concerns.
- **Scalability**: Easily extendable for new features.
- **State Management**: `flutter_bloc` package for state management.
- **Dependency Injection**: Supports modular dependency injection.
- **Network Handling**: Configured for API calls using the `Dio` package.
- **Error Handling**: Centralized and consistent error handling mechanism.
- **Theming**: Dynamic light and dark themes.
- **Testing**: Includes unit and widget testing boilerplate.

---

## 🛠 Tech Stack

- **Dart**: Language for Flutter development.
- **Flutter**: Framework for building cross-platform apps.
- **flutter_bloc**: State management.
- **Dio**: HTTP client for API integration.
- **GetIt**: Dependency injection.

---

## 🚀 Getting Started

### Prerequisites
Ensure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK
- IDE: [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)



## 📂 Project Structure

```plaintext
lib/
├── core/                 # Core utilities and constants  
├── features/             # Feature-specific modules
│   ├── auth/             # Authentication feature
│   │   ├── cubit/        # BLoC or Cubit for auth-related logic
│   │   ├── models/       # Data models for authentication
│   │   ├── repo/         # Repository layer for authentication data
│   │   ├── view/         # UI screens related to authentication
│   │   ├── widgets/      # Reusable widgets for authentication




### Installation

1. **Clone the repository:**
   ```bash  
   git clone https://github.com/yourusername/flutter_bloc_mvvm_base_app.git  
   cd flutter_bloc_mvvm_base_app  
