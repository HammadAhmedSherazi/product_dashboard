# Product Dashboard

A Flutter application for managing products with a dashboard interface. This app allows users to view, add, edit, and delete products, with features like infinite scrolling, search, filtering, and user authentication.

## How to Run the Project

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Git

### Installation Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/product-dashboard.git
   cd product-dashboard
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

   For web:
   ```bash
   flutter run -d chrome
   ```

   For Android/iOS:
   ```bash
   flutter run -d android
   flutter run -d ios
   ```

## Folder Structure

```
lib/
├── core/                    # Core utilities and configurations
│   ├── app_router.dart      # GoRouter configuration for navigation
│   └── extensions.dart      # Extension methods for widgets
├── features/
│   ├── auth/                # Authentication feature
│   │   ├── presentation/
│   │   │   ├── blocs/       # Auth state management
│   │   │   ├── pages/       # Login page
│   │   │   └── widgets/     # Auth-related widgets
│   └── product/             # Product management feature
│       ├── data/            # Data layer (repositories, APIs)
│       ├── domain/          # Domain layer (use cases)
│       ├── models/          # Data models
│       └── presentation/    # Presentation layer
│           ├── blocs/       # Product state management
│           ├── pages/       # Product pages (dashboard, details, etc.)
│           └── widgets/     # Product-related widgets
├── main.dart                # App entry point
```

### Reasoning for Folder Structure
- **Feature-based organization**: Each feature (auth, product) is self-contained with its own data, domain, and presentation layers.
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers.
- **Scalability**: Easy to add new features without affecting existing code.
- **Testability**: Each layer can be tested independently.

## Libraries Used

### Core Flutter Libraries
- `flutter/material.dart`: Material Design widgets
- `flutter_bloc`: State management
- `go_router`: Declarative routing
- `shared_preferences`: Local storage for username persistence

### UI and UX Libraries
- `cached_network_image`: Image caching with shimmer loading
- `shimmer`: Loading animations

### Networking
- `http`: HTTP client for API calls

### Development Tools
- `firebase_core`: Firebase integration (if needed for future features)

## Features Implemented

### Authentication
- Login with username/password
- Username persistence (not password for security)
- Automatic logout and navigation to login screen

### Product Management
- View products in a responsive DataTable
- Add new products with validation
- Edit existing products
- Delete products
- Search products by title
- Filter by category and stock status
- Sort by ID, title, category, and price

### Infinite Scrolling
- Automatic loading of more products when scrolling near the bottom
- No manual "Load More" button
- Loading indicator during API calls

### Responsive Design
- Adaptive layout for different screen sizes
- Horizontal scrolling on small screens for DataTable
- Responsive app bar with collapsible title and search

### Error Handling
- Retry logic for failed API calls
- "Try Again" button on error states
- User-friendly error messages

### Image Handling
- CachedNetworkImage for product images
- Shimmer loading animations
- Error icons for failed image loads

### Navigation
- GoRouter for declarative routing
- Protected routes with authentication checks
- Smooth navigation between screens

## API Integration
- Uses DummyJSON API for product data
- RESTful API calls for CRUD operations
- Error handling and retry mechanisms

## State Management
- BLoC pattern for predictable state management
- Separate cubits for auth and product features
- Event-driven architecture

## Security
- Username-only persistence (passwords not stored)
- Authentication state management
- Protected routes

## Performance
- Infinite scrolling to handle large datasets
- Image caching to reduce network requests
- Debounced search to minimize API calls
- Efficient state updates with BLoC

## Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete flows

## Deployment
- Web deployment support
- Mobile app builds for Android and iOS
- CI/CD ready with GitHub Actions

## Future Enhancements
- Offline support with local database
- Push notifications
- Advanced filtering and sorting
- Product categories management
- User profiles and permissions
- Analytics integration

---

Built with ❤️ using Flutter
