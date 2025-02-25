# Akro - Daily Checklist & Verification App

Akro is a Flutter application designed to help people manage and verify important daily checks. The app allows users to create templates for common routines (like home security checks before leaving) and verify these items with photo evidence to provide peace of mind.

## Purpose and Problem Statement

Many people experience anxiety wondering if they've properly turned off appliances, locked doors, or secured their home when leaving. This "did I remember to...?" worry can be distracting during work or travel. Akro solves this problem by:

1. Providing a structured checklist system
2. Enabling optional photo verification for visual proof
3. Organizing checklists into templates for different scenarios (home, office, etc.)
4. Automatically clearing verifications after 24 hours for the next day's use

## Technical Implementation

### Architecture

Akro is built using:

- **Flutter** for cross-platform UI
- **Riverpod** for state management
- **ObjectBox** for local database storage
- **Image Picker** for camera integration
- **Permission Handler** for permission management

The app follows a feature-first architecture with the following structure:

```
lib/
  ├── core/
  │   ├── router/        # App navigation
  │   ├── services/      # Core services (storage, permissions)
  │   ├── constants/     # App-wide constants
  │   └── themes/        # Styling
  └── features/
      ├── checklist/
      │   ├── models/    # Data models
      │   ├── providers/ # State providers
      │   └── screens/   # UI screens
      └── home/
          └── screens/   # Home screen UI
```

### Key Features

#### Templates Management

- Create named templates with customizable icons
- Define items to check within each template
- Templates persist across app restarts

#### Daily Checks

- View all items from a template
- Mark items as completed with or without photo verification
- Add descriptions to items for more details
- Automatic 24-hour reset of checks

#### Photo Verification

- Take photos directly in the app (optional feature)
- Photos are stored locally on device
- Visual confirmation provides peace of mind

#### Clean UI

- Modern, intuitive interface
- Clear visual status indicators
- Progress tracking per template

### Data Models

#### ChecklistTemplate

Represents a category of checks (e.g., "Morning Routine"):

- name: String
- icon: String (iconCode)
- items: List<String> (check items)

#### DailyCheck

Represents a specific item being checked:

- templateId: int
- itemTitle: String
- description: String?
- photoPath: String?
- isCompleted: bool
- createdAt: DateTime
- completedAt: DateTime?

## Current Status

### Completed Features

- [x] Template creation with custom icons
- [x] Checklist item management
- [x] Photo verification (optional)
- [x] Local database persistence
- [x] Modern UI implementation
- [x] Daily check status tracking
- [x] Permission handling (camera)
- [x] Marking items as complete without requiring photos
- [x] Progress indicators showing completion status

### Pending Features & Improvements

- [ ] User settings (dark mode, notification preferences)
- [ ] Geolocation-based reminders
- [ ] Cloud backup and sync
- [ ] Sharing templates with others
- [ ] Statistics and analytics on completion patterns
- [ ] Scheduled reminders for specific checks
- [ ] Widget for home screen quick access
- [ ] Push notifications for uncompleted critical items
- [ ] Export functionality for logs

## Setup and Development

### Prerequisites

- Flutter SDK (3.7.0 or later)
- Android Studio / VS Code with Flutter plugins
- Git for version control

### Getting Started

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/akro.git
   cd akro
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Generate ObjectBox code:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Key Packages Used

- **flutter_riverpod**: State management
- **objectbox**: Local database storage
- **image_picker**: Camera integration
- **path_provider**: File storage management
- **intl**: Internationalization and formatting
- **permission_handler**: Permission management

## Future Directions

### Short-term Improvements

- Add notifications system for daily reminders
- Implement better UI animations and transitions
- Add swipe actions for quick completion

### Long-term Vision

- Social features for sharing templates
- Integration with smart home devices for automated verification
- AI-powered suggestions for commonly forgotten items
- Advanced analytics to identify patterns in user behavior

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open issues for bugs and feature requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
