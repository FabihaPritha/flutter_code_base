# Flutter Code Base

A Flutter application built with **MVVM Architecture**, **Riverpod** state management, and **GoRouter** for navigation.

## Architecture

This project follows the **Model-View-ViewModel (MVVM)** architectural pattern with **Riverpod** for state management and **GoRouter** for navigation, providing a clean, scalable, and maintainable codebase.

📖 **Complete Documentation:**
- **`COMPLETE_GUIDE.md`** - Full architecture explanation and best practices

### Project Structure

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # API & app constants
│   ├── common/             # Common widgets and utilities
│   ├── models/             # Shared data models
│   ├── providers/          # Global Riverpod providers
│   ├── services/           # API services and business logic
│   ├── utils/              # Utility functions and helpers
│   └── websocketMethod/    # WebSocket implementation
├── features/               # Feature-based modules (MVVM)
│   ├── authentication/    # Authentication feature
│   │   ├── models/        # Data models
│   │   ├── repositories/  # Data operations
│   │   ├── providers/     # State management (ViewModel)
│   │   └── views/         # UI screens
│   └── splash_screen/     # Splash screen feature
├── routes/                # Application routing (GoRouter)
│   └── app_routes.dart
└── main.dart              # Application entry point
```

## Technologies Used

- **Flutter SDK**: ^3.8.1
- **Riverpod**: ^2.6.1 - Modern state management
- **GoRouter**: ^14.7.0 - Declarative routing
- **HTTP**: ^1.5.0 - API communication
- **Dio**: ^5.9.0 - Advanced HTTP client
- **Flutter ScreenUtil**: ^5.9.3 - Responsive UI design
- **Google Fonts**: ^6.3.2 - Custom fonts
- **Shared Preferences**: ^2.5.3 - Local storage
- **Image Picker**: ^1.2.0 - Image selection functionality
- **Logger**: ^2.6.1 - Logging utility
- **URL Launcher**: ^6.3.2 - Launch URLs and external apps

## Setup and Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/FabihaPritha/flutter_code_base.git
   cd flutter_code_base
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Features

- **Authentication System**: User login and registration
- **Splash Screen**: Animated startup screen
- **Responsive Design**: Adaptive UI for different screen sizes
- **Internationalization**: Multi-language support
- **WebSocket Integration**: Real-time communication
- **Image Handling**: Pick and display images
- **Local Storage**: Persistent data storage
- **Clean Architecture**: Separation of concerns with MVC pattern

## 🔧 GetX Implementation

This project leverages GetX for:

- **State Management**: Reactive state management with GetxController
- **Dependency Injection**: Service locator pattern with GetX bindings
- **Route Management**: Declarative navigation with GetX routing
- **Internationalization**: Built-in localization support

## Getting Started with Development

### Adding a New Feature

1. Create a new folder in `lib/features/`
2. Implement the MVC pattern:
   - **Model**: Data models in `core/models/`
   - **View**: UI widgets in the feature folder
   - **Controller**: Business logic with GetX controllers
3. Add route definitions in `routes/app_routes.dart`
4. Register dependencies in `core/bindings/`

### Project Guidelines

- Follow the established folder structure
- Use GetX controllers for state management
- Keep business logic separate from UI components
- Utilize the core services for API calls
- Implement proper error handling and logging

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the existing code structure and patterns
4. Ensure code quality and add tests where necessary
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

For more information about Flutter development, visit the [Flutter documentation](https://docs.flutter.dev/).
