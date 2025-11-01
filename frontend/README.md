# AI Image Editor - Frontend

Flutter Web application for AI-powered image editing.

## Features

- ✅ Image upload (drag & drop or file picker)
- ✅ Text prompt input for editing instructions
- ✅ Real-time processing status
- ✅ Result image display
- ✅ Download edited image
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Clean, modern UI

## Tech Stack

- **Framework:** Flutter Web
- **State Management:** Provider
- **HTTP Client:** http package
- **File Picker:** file_picker package
- **Deployment:** Firebase Hosting / Vercel

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── job.dart                   # Job data model
├── services/
│   └── api_service.dart          # Backend API communication
├── providers/
│   └── image_editor_provider.dart # State management
├── screens/
│   └── home_screen.dart          # Main screen
└── widgets/
    ├── image_upload_area.dart    # Image upload component
    ├── prompt_input.dart         # Prompt input component
    └── result_display.dart       # Result display component
```

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Web browser (Chrome recommended for development)

## Local Development

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/services/api_service.dart` and update the `baseUrl`:

```dart
static const String baseUrl = 'http://localhost:8000';  // Local development
// static const String baseUrl = 'https://your-backend-url.com';  // Production
```

### 3. Run the Application

```bash
flutter run -d chrome
```

The app will open in Chrome at `http://localhost:PORT`

### 4. Build for Production

```bash
flutter build web --release
```

Build output will be in `build/web/` directory.

## Deployment

### Option 1: Firebase Hosting

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Login to Firebase:**
```bash
firebase login
```

3. **Initialize Firebase (first time only):**
```bash
firebase init hosting
```
- Select "Use an existing project" or create a new one
- Set public directory to: `build/web`
- Configure as single-page app: `Yes`
- Don't overwrite index.html: `No`

4. **Build and Deploy:**
```bash
flutter build web --release
firebase deploy
```

Your app will be live at: `https://your-project.web.app`

### Option 2: Vercel

1. **Install Vercel CLI:**
```bash
npm install -g vercel
```

2. **Build the App:**
```bash
flutter build web --release
```

3. **Deploy:**
```bash
cd build/web
vercel --prod
```

Or connect your GitHub repository to Vercel for automatic deployments.

## Environment Configuration

Before deployment, update the backend URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-deployed-backend.onrender.com';
```

## Features Overview

### Image Upload
- Click to browse or drag & drop
- Supports PNG, JPG formats
- Preview before processing
- Clear/reset functionality

### Prompt Input
- Text area with character limit (1000)
- Real-time validation
- Examples provided
- Keyboard submit support (Enter)

### Result Display
- Loading states with spinner
- Success state with image
- Error state with message
- Download button for completed images
- Status badges (pending, processing, completed, failed)

### Responsive Design
- Wide layout (> 800px): Side-by-side columns
- Narrow layout (< 800px): Stacked vertical layout
- Mobile-friendly touch interactions

## Development Notes

### State Management
The app uses Provider for state management with a single `ImageEditorProvider` that handles:
- Image selection
- Job creation
- Loading states
- Error handling
- Job history (future feature)

### API Communication
The `ApiService` class handles all backend communication:
- `createJob()` - Upload image and prompt
- `getJob()` - Get job status
- `listJobs()` - Get job history

### Error Handling
- Network errors show user-friendly messages
- Invalid inputs are validated before submission
- Loading states prevent multiple submissions
- Snackbar notifications for feedback

## Browser Compatibility

- ✅ Chrome/Edge (recommended)
- ✅ Firefox
- ✅ Safari
- ⚠️ Mobile browsers (limited file picker support)

## Performance Optimization

The production build includes:
- Code minification
- Tree shaking
- Asset optimization
- CanvasKit rendering for better graphics

## Known Issues

- File picker may have limited functionality in some mobile browsers
- Large images (>10MB) may take longer to upload
- Internet Explorer is not supported

## Future Enhancements

- [ ] Before/After image slider
- [ ] Job history panel
- [ ] Multiple image editing
- [ ] Custom presets
- [ ] Dark mode
- [ ] Internationalization (i18n)

## Troubleshooting

### CORS Errors
Ensure your backend has CORS enabled for your frontend domain.

### Image Upload Fails
Check:
- File size limit
- File format (PNG/JPG only)
- Backend connection
- Network connectivity

### Build Errors
```bash
flutter clean
flutter pub get
flutter build web --release
```

## License

This project is part of a technical assignment.
