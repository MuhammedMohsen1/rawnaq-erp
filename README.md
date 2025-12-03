# Rawnaq

**First Milestone** 🎯

Rawnaq is a comprehensive project management platform designed specifically for interior design teams and operational staff. The application provides powerful tools to streamline workflows, manage projects, coordinate team activities, and enhance collaboration between design and operational departments.

## Features

- **Project Management** - Create, track, and manage interior design projects from concept to completion
- **Team Collaboration** - Coordinate between interior design teams and operational staff seamlessly
- **Task Tracking** - Assign, monitor, and complete tasks with real-time progress updates
- **Dashboard & Reports** - Visual analytics and reports to track project performance
- **Multi-platform Support** - Available on Web, iOS, Android, Windows, macOS, and Linux

## Tech Stack

- **Framework**: Flutter 3.8+
- **State Management**: flutter_bloc, Provider
- **Navigation**: go_router
- **Network**: Dio, Retrofit
- **Storage**: SharedPreferences
- **Dependency Injection**: get_it, injectable
- **Firebase**: Analytics, Messaging, Notifications

## Getting Started

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Firebase project configured

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd rawnaq
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate required files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Core utilities, constants, services, and shared widgets
├── features/       # Feature modules (auth, dashboard, reports, etc.)
├── l10n/           # Localization files (English & Arabic)
└── main.dart       # Application entry point
```

## Localization

The app supports both English and Arabic languages with RTL support.

## License

Copyright © 2025 Rawnaq. All rights reserved.
