# Update Guide

## 1. General Information

This document describes the step-by-step update procedure for the Flutter mobile application with a local SQLite database.

An update may include:
- source code changes;
- dependency changes;
- changes in the local database structure;
- regeneration of the Android release build;
- reinstallation of the application on a test or production device.

---

## 2. When an Update Is Required

An update is required in the following cases:
- adding new functionality;
- fixing bugs;
- changing the user interface;
- updating dependencies in `pubspec.yaml`;
- changing the database schema or seed data;
- preparing a new release version of the application.

---

## 3. Preparation for Update

Before starting the update process, the release engineer / DevOps engineer should:

1. get the latest version of the source code:
```bash
git pull
```

2. check the current branch:
```bash
git branch
```

3. verify that the build environment is working correctly:
```bash
flutter doctor
```

4. review whether the following files or directories were changed:
- `pubspec.yaml`
- `android/`
- `lib/data/db/app_db.dart`
- `lib/data/db/db_seeder.dart`
- DAO classes
- services
- screens

---

## 4. Update Scope Assessment

Before performing the update, it is important to determine what exactly is being changed.

Possible update scopes:
- code-only update;
- dependency update;
- UI-only update;
- database-related update;
- release configuration update.

This assessment is important because database or configuration changes may require additional compatibility checks and backup steps.

---

## 5. Backup Before Update

Before any update, it is strongly recommended to create backups of the current working version.

The following items should be backed up:
- the current stable APK or AAB;
- the current source code state;
- local build configuration, if it contains important release settings;
- the local database of the test device, if it contains valuable test data.

Recommended actions:
1. save the previous APK/AAB in a separate archive folder, for example:
```text
releases/archive/
```

2. create a Git tag for the current stable version:
```bash
git tag v1.0.0
git push origin v1.0.0
```

3. if necessary, export or preserve the local test data before installing the new version.

---

## 6. Compatibility Check

Before updating the application, verify:
- whether Flutter/Dart dependencies have changed;
- whether the new version is compatible with the current Android SDK;
- whether the required JDK version has changed;
- whether the SQLite schema has changed;
- whether the new code remains compatible with existing local data.

If the database schema changes, the following actions are required:
- increase the database version in `AppDb`;
- implement a migration or a safe recreation strategy;
- test the update on a device where the previous version of the app is already installed.

---

## 7. Downtime Planning

For this project, long downtime is usually not required because it is a mobile application and not a centrally hosted web system.

However, during update on a particular device, the following temporary interruption may occur:
- closing the previous version of the application;
- uninstalling or reinstalling the app;
- short-term unavailability during installation.

If the update affects the local database, it is recommended to:
- back up the data before starting;
- first test the update on a test device;
- update the main working device only after successful verification.

---

## 8. Stopping the Required Services

Because this project does not use backend servers or system services, there are no Nginx, Apache, Docker, or database services that need to be stopped.

Instead, before the update, the following practical steps should be performed:
1. close the application on the target device;
2. make sure the previous APK is not actively running during reinstallation;
3. if needed, restart the emulator before installing the updated build.

---

## 9. Update Process

### 9.1. Get the Latest Source Code
```bash
git pull
```

### 9.2. Update Project Dependencies
```bash
flutter pub get
```

### 9.3. Clean Previous Build Artifacts
```bash
flutter clean
flutter pub get
```

### 9.4. Verify the Project Before Rebuilding
```bash
flutter analyze
flutter test
```

### 9.5. Build the Updated Release Version

#### APK
```bash
flutter build apk --release
```

#### Android App Bundle
```bash
flutter build appbundle
```

---

## 10. Data Migration

In this project, data migration is only required when the local SQLite schema changes.

### If the Database Schema Has Not Changed
- the new application version can be installed over the previous one.

### If the Database Schema Has Changed
The following actions are required:
1. update the database version;
2. implement migration logic;
3. verify that old data remains readable and valid;
4. test the migration on a device where the old version is already installed.

### If Safe Migration Is Not Implemented
The following fallback approach may be used:
- remove the old application version;
- install the new version;
- allow the database to be created again from scratch.

Important note:
- this approach may lead to loss of local data;
- therefore, it should only be used after backup and clear documentation of the risk.

---

## 11. Updating Configurations

During an update, the following project parts may need to be reviewed:
- `pubspec.yaml`
- Android build configuration
- signing configuration
- local build scripts
- release notes or deployment records

The release engineer should verify:
1. whether any new secrets or variables are required;
2. whether signing configuration has changed;
3. whether the Flutter SDK version requirements have changed;
4. whether the output paths for build artifacts remain the same.

---

## 12. Post-Update Verification

After the updated build is installed, the following checks should be performed:

1. the application starts successfully;
2. no startup or initialization errors occur;
3. registration works correctly;
4. login works correctly;
5. food search works in the macro calculator;
6. Kcal / Proteins / Fats / Carbohydrates calculations work correctly;
7. vitamin calculation for a single product works correctly;
8. daily vitamin calculation works correctly;
9. the cabinet/profile screen opens correctly;
10. profile data update works correctly;
11. password change works correctly.

If the update included database changes, it is additionally necessary to verify that:
- old data is still accessible;
- the updated schema works correctly;
- seeded reference data remains available.

---

## 13. Rollback Plan

If the updated version does not work correctly, the following rollback procedure should be used:

1. remove the problematic version from the device;
2. reinstall the previous stable APK;
3. if necessary, restore the previous local data backup;
4. return to the previous stable Git tag or commit in the repository.

Recommended rollback preparation:
- always keep at least one previously working APK/AAB;
- always document the last stable version number or Git tag;
- always verify that backups are available before performing a risky update.

---

## 14. Update Checklist

### Before the Update
- [ ] current stable version identified
- [ ] backup created
- [ ] latest source code pulled
- [ ] compatibility checked
- [ ] database impact assessed

### During the Update
- [ ] application closed on the target device
- [ ] dependencies updated
- [ ] build artifacts cleaned
- [ ] analysis completed successfully
- [ ] tests completed successfully
- [ ] new APK/AAB built successfully

### After the Update
- [ ] updated version installed
- [ ] application launches successfully
- [ ] local database works correctly
- [ ] main user scenarios verified
- [ ] rollback option remains available