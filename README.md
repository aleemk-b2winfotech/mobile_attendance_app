# Attendance Mobile App

Flutter mobile application for an attendance management system. The app connects to the Node.js attendance backend and supports employee attendance workflows, leave requests, device change requests, profile details, holidays, and administration screens.

## Repository

GitHub: https://github.com/aleemk-b2winfotech/mobile_attendance_app

## Tech Stack

- Flutter
- Dart
- GetX for state management and navigation
- Dio for API communication
- Google Sign-In
- Flutter Secure Storage
- Shared Preferences
- Geolocator
- Android ID
- URL Launcher
- Reusable feature-based UI structure

## Main Features

### Employee

- Google login integrated with backend authentication.
- Secure session storage with access token and refresh token support.
- Device ID handling for attendance/device binding.
- Dashboard with attendance status and summary data.
- Punch-in and punch-out flow connected to backend validation.
- Location-based attendance support.
- Attendance overview and record viewing.
- Leave request creation, cancellation, filtering, and thread view.
- Device change request flow.
- Holiday list.
- Profile and office location details.

### Administration

- Admin home/dashboard screens.
- Leave approval and rejection workflows.
- Leave discussion thread and proposal handling.
- Device change approval/rejection workflows.
- Team/user management screens.
- User location and device log views.
- Attendance records and regularization flows.
- Holiday management.
- Work-from-home assignment.
- Analytics and management views.

## Project Structure

```text
lib/
  app/                         App shell, binding, navigation, registry
  core/
    config/                    API and app configuration
    services/                  Shared services
    theme/                     Colors, icons, theme
    utils/                     Formatters and shared helpers
    widgets/                   Reusable app widgets
  data/
    network/                   Dio API client and API extensions
    services/                  Device ID and shared data services
  features/
    auth/                      Login, auth controller, auth repository
    employee/
      dashboard/               Employee dashboard
      attendance/              Attendance overview and records
      leaves/                  Leave requests and thread flows
      device_change/           Device change request flow
      profile/                 Profile page
      home/                    Employee home shell
    administration/
      shell/                   Admin home shell
      dashboard/               Admin dashboard
      approvals/               Leave/device approval flows
      team/                    Team and user actions
      attendance/              Attendance records and regularization
      holidays/                Holiday management
      work_from_home/          WFH management
      analytics/               Analytics screens
      management/              Shared management views
test/                          Unit tests
```

## Backend API

The app expects the attendance backend API root URL.

Current config file:

```text
lib/core/config/app_config.dart
```

The app uses:

```text
API_ROOT_URL/mobile
API_ROOT_URL/web
```

For local development, pass the backend URL with `--dart-define`:

```bash
flutter run --dart-define=API_ROOT_URL=http://10.0.2.2:3000/api/v1
```

Use `10.0.2.2` for Android emulator access to a backend running on your machine. For a physical device, use your computer's local network IP.

For Railway/testing deployment:

```bash
flutter run --dart-define=API_ROOT_URL=https://your-api-domain/api/v1
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android emulator or physical device
- Running attendance backend API
- Google OAuth/Firebase configuration for Google Sign-In

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run --dart-define=API_ROOT_URL=http://10.0.2.2:3000/api/v1
```

### Analyze Code

```bash
flutter analyze
```

## Configuration Notes

- Update `API_ROOT_URL` for local, staging, or Railway environments.
- Google Sign-In requires valid OAuth/Firebase configuration.
- Android builds require the correct package/signing configuration for Google login.
- Do not commit production secrets or private credentials.

## API Integration

The app uses a shared Dio client in:

```text
lib/data/network/api_client.dart
```

The client handles:

- base URL switching between employee and admin APIs
- bearer token attachment
- device ID header attachment
- token refresh retry flow
- retry handling for transient connection errors
- consistent response parsing

## Notes for Reviewers

This app demonstrates Flutter API integration, session handling, feature-based architecture, role-based user flows, location-aware attendance, reusable widgets, and controller/repository separation.
