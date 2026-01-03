# MaklaApp

This is a Flutter application for **MaklaApp**. This guide will help you set up your environment from scratch and run the app, even if Flutter, Android Studio, or any other tools are not installed yet.

---

## ⚙️ Environment Setup

Before running the app, you need to set up your environment variables:

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file** and add your actual API keys:
   ```env
   AI_API_KEY=your_openai_api_key_here
   AI_BASE_URL=https://api.openai.com/v1/
   AI_MODEL=gpt-4o
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

3. **Never commit the `.env` file** to version control - it's already added to `.gitignore`

---

## 1️⃣ Prerequisites

Before running the app, make sure you have:

- **Windows 10 or 11**
- **Git** installed (to clone the repository)  
  Download: https://git-scm.com/downloads
- **Flutter SDK**  
  Download: https://docs.flutter.dev/install/with-vs-code
- **Android Studio** (for Android SDK and emulator)  
  Download: https://developer.android.com/studio
- **JDK 17** (Java Development Kit)  
  Download: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html

> **Note:** If you only want to run on Web (Chrome/Edge), you **don't need Android Studio or JDK**.

---

## 2️⃣ Clone the Repository

Open **PowerShell**, **CMD**, or **Git Bash**:

```bash
git clone https://github.com/LuchoAquino/makla_app.git
cd makla_app
```

---

## 3️⃣ Set up Flutter

### Add Flutter to your PATH

Add Flutter to your PATH (so you can run `flutter` from terminal):

Suppose you installed Flutter at `C:\Users\<YourName>\flutter\bin`:

1. Right-click **This PC** → **Properties** → **Advanced system settings** → **Environment Variables**
2. Under **User variables**, edit **Path**
3. Add:
   ```
   C:\Users\<YourName>\flutter\bin
   ```

### Verify Flutter is working

```bash
flutter doctor
```

---

## 4️⃣ Set up Android (if you want to run on Android devices/emulator)

1. Open **Android Studio** → **More Actions** → **SDK Manager**
2. Note the **Android SDK Location**, e.g.:
   ```
   C:\Users\<YourName>\AppData\Local\Android\Sdk
   ```

3. Install:
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
   - Android Emulator
   - Command-line tools
   - At least one system image (e.g., Pixel 6 API 36)

4. Set Android SDK path for Flutter:
   ```bash
   flutter config --android-sdk "C:\Users\<YourName>\AppData\Local\Android\Sdk"
   ```

5. Add these to **Path** in Environment Variables:
   ```
   C:\Users\<YourName>\AppData\Local\Android\Sdk\platform-tools
   C:\Users\<YourName>\AppData\Local\Android\Sdk\emulator
   ```

---

## 5️⃣ Set up JDK

1. Install **JDK 17**
2. Set **JAVA_HOME** environment variable:
   ```
   JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17
   ```
3. Add `JAVA_HOME\bin` to **Path**
4. Verify:
   ```bash
   java -version
   ```

---

## 6️⃣ Install Dependencies

In your project folder:

```bash
flutter pub get
```

This will download all packages required by the project.

---

## 7️⃣ Run the App

### Option A: Web (Chrome / Edge)

```bash
flutter run -d chrome
```

or

```bash
flutter run -d edge
```

### Option B: Android Emulator

1. List available emulators:
   ```bash
   flutter emulators
   ```

2. Launch an emulator:
   ```bash
   flutter emulators --launch <emulator_id>
   ```

3. Run the app on emulator:
   ```bash
   flutter run
   ```

### Option C: Physical Android Device

1. Enable **USB Debugging** on your phone
2. Connect via USB
3. Run:
   ```bash
   flutter devices
   flutter run
   ```

---

## 8️⃣ Useful Commands

| Command | Description |
|---------|-------------|
| `flutter emulators` | List available emulators |
| `flutter doctor -v` | Check Flutter setup (verbose) |
| `flutter clean` | Clean project build files |
| `flutter build apk --release` | Build release APK for Android |
| `flutter pub get` | Install/update dependencies |
| `flutter pub upgrade` | Upgrade all dependencies |

---

## 9️⃣ Project Structure

```
makla_app/
├── assets/                      # Static files (images, icons, logos)
│   ├── images/                  # Large images (backgrounds, food placeholders)
│   └── icons/                   # Small SVGs or PNG icons (camera icon, menu icon)
│
├── lib/                         # Main Application Code
│   ├── main.dart                # The entry point of the app (App start)
│   │
│   ├── models/                  # Data Blueprints (No logic, just data structure)
│   │   ├── user_model.dart      # Defines what a "User" looks like (name, goal, weight)
│   │   └── meal_model.dart      # Defines what a "Meal" looks like (calories, ingredients)
│   │
│   ├── providers/               # State Management & Data Fetching
│   │   ├── auth_provider.dart   # Handles Firebase Login/Sign-up logic
│   │   └── gemini_service.dart  # Connects the app to the AI (Gemini/Backend)
│   │
│   ├── screens/                 # The Visual Pages of the App
│   │   │   ├── login_screen.dart
│   │   │   ├── user_info_form.dart
│   │   │   ├── home_screen.dart    # Daily summary & progress
│   │   │   ├── camera_screen.dart  # Viewfinder to take photos
│   │   │   └── result_screen.dart  # Shows the AI analysis results
│   │
│   └── widgets/                 # Reusable UI Components (Building blocks)
│       ├── bottom_nav.dart      
│       └── progress_bar.dart    # The visual bar for daily calorie goals
│
└── pubspec.yaml                 # List of external libraries (plugins) used in the app
```

---

## 🔟 Notes

- Make sure **Flutter**, **Android SDK**, and **JDK** are added to your **PATH**.
- **Restart terminal / VS Code** after installing tools.
- For **Windows desktop builds**, you will also need **Visual Studio 2022** with "Desktop development with C++" workload.
- Run `flutter doctor` regularly to check for any missing dependencies or configuration issues.

---

