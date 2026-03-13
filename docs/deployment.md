# Production Deployment Guide

## 1. General Information

This project is a Flutter mobile application for Android with a local SQLite database.

In this project there is **no**:
- web server;
- separate application server;
- server-side DBMS;
- external caching service;
- centralized file storage.

Therefore, for this project, **production deployment** means:
1. preparing a release Android build;
2. signing the build;
3. installing it on a physical device or preparing it for distribution/testing;
4. verifying that the application works correctly after installation.

---

## 2. Production Environment Overview

The production environment for this project includes:
- an Android device used as the target runtime environment;
- a build machine used by the release engineer / DevOps engineer;
- Flutter SDK;
- Android SDK and platform tools;
- Android Studio or equivalent Android build tools;
- JDK compatible with the Android toolchain;
- the project source code from the repository;
- the local SQLite database that is automatically created on the device during the first launch.

---

## 3. Hardware Requirements

### 3.1. Build Machine Requirements

Minimum recommended requirements:
- CPU: 4 logical cores;
- RAM: 8 GB;
- free disk space: at least 15 GB;
- architecture: x64.

Recommended requirements:
- CPU: 6 or more logical cores;
- RAM: 16 GB;
- SSD storage;
- stable Internet connection for downloading dependencies.

### 3.2. Target Device Requirements

Minimum recommended target device requirements:
- Android device supported by the current Flutter/Android build configuration;
- at least 200 MB of free storage;
- ability to install APK builds;
- access to the device internal storage for local database creation.

---

## 4. Required Software

The release engineer / DevOps engineer must install:

1. Git
2. Flutter SDK
3. Android Studio
4. Android SDK
5. Android platform-tools / adb
6. JDK compatible with Android build tools

To verify that the environment is configured correctly, run:

```bash
flutter doctor
```

If Android licenses are not accepted yet, run:

```bash
flutter doctor --android-licenses
```

and accept all licenses.

---

## 5. Network Configuration

This project does not require special network infrastructure because:
- the application works locally on the device;
- the database is local;
- there is no mandatory backend API in the current architecture.

However, the following network access may be required:
- access to GitHub to clone the repository;
- Internet access to download Flutter/Gradle dependencies;
- optional access to an internal testing channel or app distribution platform.

---

## 6. Server Configuration

This project does not use dedicated servers.

In this case, the role of the production host is effectively performed by:
- the Android device where the application is installed;
- the build machine where the release APK/AAB is generated.

Therefore, no Nginx, Apache, Docker container, backend host, or Linux service configuration is required for the current version of this project.

---

## 7. Database Configuration

A separate server-side DBMS is not used.

Database characteristics in this project:
- SQLite is embedded into the mobile application environment;
- the database is created locally on the Android device;
- tables are created automatically during first launch;
- initial reference data is inserted automatically via the seeding mechanism.

The release engineer does not need to install a separate database server.

---

## 8. Getting the Source Code

Clone the repository:

```bash
git clone https://github.com/serhiibatrachenko505-stack/diploma-prog.git
cd diploma-prog
```

Check the current branch and update the project:

```bash
git branch
git pull
```

---

## 9. Installing Dependencies

In the project root directory, run:

```bash
flutter pub get
```

This command installs all project dependencies listed in `pubspec.yaml`.

---

## 10. Pre-Deployment Checks

Before generating a production build, it is recommended to perform the following steps:

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
```

Purpose of these steps:
- `flutter clean` removes old generated artifacts;
- `flutter pub get` restores dependencies;
- `flutter analyze` checks the code for static analysis issues;
- `flutter test` verifies that tests pass.

If the application does not pass analysis or tests, deployment should be postponed until the issues are fixed.

---

## 11. Building the Production Version

### 11.1. APK Build

To build a release APK:

```bash
flutter build apk --release
```

This option is suitable for:
- manual installation on Android devices;
- local testing of the release version;
- direct transfer of the APK file to a tester.

### 11.2. Android App Bundle

To build an Android App Bundle:

```bash
flutter build appbundle
```

This option is suitable for:
- preparing the application for publishing through Google Play;
- generating a more production-oriented distribution artifact.

---

## 12. Build Artifact Locations

After a successful build, the generated files are typically located in:

### APK
```text
build/app/outputs/flutter-apk/app-release.apk
```

### AAB
```text
build/app/outputs/bundle/release/app-release.aab
```

---

## 13. Release Signing

For a real production deployment, the Android application must be signed with a release keystore.

The release signing procedure includes:
1. creating a keystore;
2. configuring signing settings in the Android part of the project;
3. securely storing the keystore file and passwords;
4. ensuring that secrets are not committed to the public repository.

Important notes:
- release keys must be stored securely;
- keystore files and passwords must not be published in GitHub;
- for academic demonstration, it is acceptable to mention that signing is required for real distribution, even if secrets are intentionally excluded from the public repository.

---

## 14. Installing the Release Build on a Device

Connect the Android device and verify that it is visible:

```bash
adb devices
```

Install the release APK using:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Explanation:
- `adb install` installs the application;
- `-r` reinstalls it over the existing version if needed.

If an older incompatible version causes issues, the application can be removed first and then installed again.

---

## 15. First Launch Behavior in Production

During the first application launch on the target device:
1. the local SQLite database is opened;
2. if the database file does not exist, it is created automatically;
3. all required tables are created;
4. seed data is inserted into the database.

The application automatically seeds:
- meal plans;
- vitamins list;
- foods with macro values;
- vitamin-to-food relationship records.

This means that no separate manual database deployment procedure is required.

---

## 16. Post-Deployment Verification

After installation, the release engineer should verify that the application works correctly.

### 16.1. Application Launch
Check that:
- the application starts successfully;
- no crash occurs during startup;
- the initial screen is displayed correctly.

### 16.2. Database Initialization
Check that:
- no database initialization errors occur;
- the application can access reference data;
- search and calculation functionality can use the seeded data.

### 16.3. Functional Verification
Perform the following checks:
1. register a new user;
2. log in with the created user;
3. search food items in the macro calculator;
4. calculate Kcal / Proteins / Fats / Carbohydrates for several products;
5. calculate vitamins for a single product;
6. calculate daily vitamins for a list of products;
7. open the cabinet/profile screen;
8. update user profile data;
9. change the password.

### 16.4. Success Criteria
Deployment can be considered successful if:
- the release APK/AAB is built without errors;
- the APK is installed successfully on the target device;
- the application starts normally;
- the local SQLite database is created automatically;
- the main functional scenarios work without critical errors.

---

## 17. Production Deployment Checklist

### Before Deployment
- [ ] repository cloned successfully
- [ ] latest code pulled
- [ ] dependencies installed
- [ ] `flutter analyze` completed successfully
- [ ] `flutter test` completed successfully
- [ ] release build generated

### During Deployment
- [ ] target device connected
- [ ] `adb devices` shows the device
- [ ] APK installed successfully

### After Deployment
- [ ] application launches correctly
- [ ] database is initialized
- [ ] seed data is available
- [ ] core features are verified
- [ ] deployment result is documented

---

## 18. Notes for This Project Type

Because this is a mobile Flutter application with local SQLite storage, the classic deployment model for a web system does not apply here.

Instead of deploying:
- backend services;
- web servers;
- remote databases;

the deployment process focuses on:
- preparing a production-ready Android build;
- installing it on the device;
- verifying that the mobile runtime environment works correctly.