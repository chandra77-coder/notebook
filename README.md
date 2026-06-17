# ShopBook - Flutter Android App

A complete production-ready Flutter Android application for managing earnings, expenses, and profits with full offline support.

## Features

- **Offline First**: Fully functional without internet connection using SQLite database
- **Bottom Navigation**: 6 main tabs - Home, History, Summary, Due, People, Settings
- **Entry Management**: Add, edit, delete entries with undo functionality
- **Payment Types**: Support for Cash, Online, and Due payments
- **Analytics**: Weekly and monthly summaries with charts and statistics
- **Dark Mode**: Toggle between light and dark themes
- **Data Export/Import**: Backup and restore data as JSON
- **People Management**: Add and manage people with custom quick-add buttons
- **Due Tracking**: Monitor and mark due payments as received
- **Auto-Build**: GitHub Actions workflow for automatic APK generation

## Project Structure

```
shopbook/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── models/
│   │   ├── entry.dart           # Entry data model
│   │   └── person.dart          # Person data model
│   ├── screens/
│   │   ├── home_screen.dart     # Home tab with today's entries
│   │   ├── history_screen.dart  # History with search and filters
│   │   ├── summary_screen.dart  # Analytics and charts
│   │   ├── due_screen.dart      # Due payments management
│   │   ├── people_screen.dart   # People management
│   │   ├── settings_screen.dart # Settings and preferences
│   │   └── add_entry_screen.dart # Add/Edit entry form
│   ├── providers/
│   │   ├── data_provider.dart   # Data management with Provider
│   │   └── theme_provider.dart  # Theme management
│   ├── utils/
│   │   └── database_helper.dart # SQLite database operations
│   └── widgets/                 # Reusable widgets
├── .github/
│   └── workflows/
│       └── build.yml            # GitHub Actions workflow
├── pubspec.yaml                 # Flutter dependencies
└── README.md                    # This file
```

## Getting Started

### Prerequisites

- Flutter SDK (3.16.0 or higher)
- Android SDK (API level 21 or higher)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/chandra77-coder/notebook.git
   cd notebook
   ```

2. **Get Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## GitHub Setup & Auto-Build

### Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the **+** icon in the top right and select **New repository**
3. Name it `notebook`
4. Choose **Public** or **Private**
5. Click **Create repository**

### Step 2: Upload Files to GitHub

1. **Clone the empty repository** (if you haven't already)
   ```bash
   git clone https://github.com/YOUR_USERNAME/notebook.git
   cd notebook
   ```

2. **Copy all ShopBook files** into the repository directory

3. **Initialize Git and commit**
   ```bash
   git add .
   git commit -m "Initial commit: Add ShopBook Flutter app"
   ```

4. **Push to main branch**
   ```bash
   git branch -M main
   git push -u origin main
   ```

### Step 3: Download APK from GitHub Actions

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Select the latest workflow run (should show "Build and Release APK")
4. Wait for the build to complete (usually 5-10 minutes)
5. Once complete, scroll down to **Artifacts** section
6. Download **shopbook-release** (contains app-release.apk)
7. Transfer the APK to your Android device and install it

### Automatic Builds

Every time you push to the `main` branch:
- GitHub Actions automatically triggers the build workflow
- Flutter builds the release APK
- APK is available as an artifact for download
- A GitHub Release is created with the APK attached

## File Structure Details

### Models

**Entry** - Represents a transaction entry
- `id`: Unique identifier
- `serviceType`: Type of service/work
- `customerName`: Customer name
- `amount`: Transaction amount
- `note`: Optional notes
- `paymentType`: Cash, Online, or Due
- `personId`: Associated person
- `date`: Transaction date and time
- `dayName`: Day name (Monday, Tuesday, etc.)
- `isDeleted`: Soft delete flag

**Person** - Represents a person/employee
- `id`: Unique identifier
- `name`: Person's name
- `avatarColor`: Avatar color hex code
- `quickAddButtons`: List of quick-add buttons with labels and default amounts

### Screens

**Home Screen**
- Header with app name and current date
- Today's total earnings display
- Floating stat cards (Earned, Spent, Profit)
- Due payment alert banner
- Quick-add buttons for fast entry creation
- Today's entries list with edit/delete/mark paid options

**History Screen**
- Search bar for customer/service names
- Filter pills (Today, This Week, This Month, Cash, Online, Due)
- Entries grouped by date with full day names
- Edit, delete, and mark paid buttons per entry

**Summary Screen**
- Period toggle (This Week, This Month, Last Month)
- 4 stat cards (Total Earned, Total Spent, Net Profit, Total Entries)
- Bar chart showing daily earned vs spent
- Service type breakdown with progress bars

**Due Screen**
- Header showing total due amount
- List of all unpaid entries
- Quick buttons to mark as Cash or Online received

**People Screen**
- Add person button
- List of all people with their stats
- Edit and delete buttons per person
- Shows entry count, earned, spent, and profit per person

**Settings Screen**
- Editable shop name
- Dark mode toggle
- Export data as JSON to Downloads
- Import/restore from JSON file
- App version information

### Database

Uses **SQLite** with **sqflite** package:
- `entries` table: Stores all transaction entries
- `people` table: Stores person information and quick-add buttons

### State Management

Uses **Provider** package for:
- `DataProvider`: Manages all entry and person data
- `ThemeProvider`: Manages dark/light mode preference with SharedPreferences

## Dependencies

- **sqflite**: Local SQLite database
- **shared_preferences**: Persistent settings storage
- **provider**: State management
- **intl**: Date and time formatting
- **fl_chart**: Charts and graphs
- **uuid**: Unique ID generation
- **file_picker**: File selection for import
- **path_provider**: File system paths

## Building for Release

### Manual Build

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### GitHub Actions Build

Simply push to the `main` branch and GitHub Actions will automatically:
1. Build the release APK
2. Create a GitHub Release
3. Upload the APK as an artifact

## Color Scheme

- **Primary Color**: #0F6E56 (Deep Forest Green)
- **Earned**: Green (#4CAF50)
- **Spent**: Red (#F44336)
- **Profit**: Blue (#2196F3)
- **Due**: Orange (#FF9800)

## Design Guidelines

- Clean, flat design with no gradients or shadows
- Cards have thin borders and 12px radius
- Bottom navigation with active green dot indicator
- Quick-add buttons in horizontal scrollable row
- Entry cards have colored left dot indicator
- Payment badges are color-coded

## Troubleshooting

### APK Build Fails
- Ensure Java 11+ is installed
- Run `flutter clean` and try again
- Check that all dependencies are installed: `flutter pub get`

### GitHub Actions Build Fails
- Check the Actions tab for error logs
- Ensure `.github/workflows/build.yml` is in the repository
- Verify all files are properly committed and pushed

### App Crashes on Launch
- Clear app data: `flutter clean`
- Reinstall dependencies: `flutter pub get`
- Check device logs: `flutter logs`

## Contributing

Feel free to fork this project and submit pull requests for any improvements.

## License

This project is open source and available under the MIT License.

## Support

For issues or questions, please create an issue on the GitHub repository.

---

**Version**: 1.0.0  
**Last Updated**: 2026  
**Author**: ShopBook Team
