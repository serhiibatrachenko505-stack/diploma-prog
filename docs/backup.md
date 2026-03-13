# Backup Guide

## 1. General Information

This document describes the backup and recovery approach for the Flutter Android project with a local SQLite database.

Because this project does not use a centralized backend server or a server-side DBMS, backup procedures focus on:
- source code;
- release artifacts;
- build and signing configuration;
- local SQLite data on test devices;
- logs related to build and verification.

---

## 2. Backup Strategy

For this project, a combined backup strategy is recommended:
1. source code backup through Git and GitHub;
2. release artifact backup outside the repository;
3. backup of important local SQLite data from test devices;
4. backup of signing-related configuration and release notes;
5. periodic verification that recovery is actually possible.

This approach reduces the risk of losing:
- the application source code;
- a stable release version;
- important local test data;
- configuration required for rebuilding or redeploying the project.

---

## 3. Types of Backups

### 3.1. Full Backup

A full backup may include:
- the complete source code repository;
- a copy of the latest stable APK or AAB;
- important build configuration files;
- signing-related configuration stored in a secure location;
- local SQLite database copy from a test device, if needed;
- related deployment and release documentation.

### 3.2. Incremental Backup

An incremental backup includes only changes since the previous backup, for example:
- new commits;
- updated release artifacts;
- changed configuration files;
- new logs or release notes.

### 3.3. Differential Backup

A differential backup includes all changes since the last full backup.

For this project, differential backups may be useful for:
- storing recent documentation changes;
- keeping short-term release archives;
- preserving intermediate build outputs before a final release.

---

## 4. Backup Frequency

The following backup frequency is recommended:

- source code — after every logically completed work stage and before each release;
- release APK/AAB — before every distribution or testing cycle;
- build and signing configuration — after every important configuration change;
- local database from a test device — before updates that may affect the schema or local data;
- logs and verification results — after each release preparation cycle.

This frequency helps ensure that both development progress and deployable artifacts can be restored if needed.

---

## 5. Storage and Rotation Policy

It is recommended to maintain backups in at least three locations:
1. a local copy on the developer or release engineer machine;
2. a remote copy in GitHub;
3. a separate archive of release artifacts on external storage or cloud storage.

### Rotation Recommendations
- keep the last 5–10 release builds;
- keep all tagged stable releases;
- old temporary APK builds may be removed after successful testing;
- critical signing-related backups must not be deleted without a protected secondary copy.

---

## 6. What Must Be Backed Up

### 6.1. Database

In this project, the production database is local SQLite stored on the device. Therefore, backup may include:
- the database file from a test or validation device;
- local user/test data before updates that may recreate or migrate the database.

### 6.2. Configuration Files

The following should be backed up:
- `pubspec.yaml`
- Android release configuration
- build scripts
- signing configuration
- release notes and deployment notes

### 6.3. User or Test Data

If a test device contains important local data, it should be preserved. This may include:
- registered test users;
- local profile data;
- manually verified calculation scenarios;
- prepared test datasets.

### 6.4. Logs

The following logs are useful for backup:
- build logs;
- test result logs;
- verification notes;
- optional adb/logcat logs collected during release testing.

---

## 7. Backup Procedure

### 7.1. Source Code Backup

To back up the source code:

1. check the repository status:
```bash
git status
```

2. add and commit all completed changes:
```bash
git add .
git commit -m "Backup before release/update"
```

3. push the latest state to GitHub:
```bash
git push
```

4. if the current version is stable, create a tag:
```bash
git tag v1.0.0
git push origin v1.0.0
```

This ensures that the project source code can be restored to a known working state.

---

### 7.2. Release Artifact Backup

After generating a release build:

```bash
flutter build apk --release
```

or

```bash
flutter build appbundle
```

copy the generated artifact to an archive folder, for example:

```text
releases/archive/YYYY-MM-DD/
```

It is recommended to store:
- `app-release.apk` or `app-release.aab`;
- a small text note with the version number;
- the related Git commit hash or tag.

---

### 7.3. Configuration Backup

The following should be copied to a secure location:
- release keystore;
- signing settings;
- local build notes;
- important environment-specific release configuration.

Important:
- keystore files must not be stored in the public repository;
- access to signing files must be restricted;
- at least one protected duplicate copy should exist.

---

### 7.4. Local Database Backup

If local SQLite data from a test device must be preserved, the recommended procedure is:
1. connect the device;
2. identify the database location for the application;
3. copy the database file to a secure backup location;
4. label the copy with the application version and date.

For an academic project, it is acceptable to document this procedure conceptually if direct extraction depends on device/debug configuration.

---

## 8. Backup Integrity Verification

After creating a backup, the following checks should be performed:
- confirm that the file exists;
- confirm that the file is not empty;
- confirm that the APK/AAB file can be opened and identified correctly;
- confirm that the Git tag exists if one was created;
- confirm that the database backup has an expected size;
- confirm that archived files can be extracted or opened.

Recommended additional checks:
- store file hashes if needed;
- record the backup date and related version;
- periodically perform a test recovery.

---

## 9. Backup Automation

Backup can be partially automated using:
- shell scripts;
- PowerShell scripts;
- local task automation;
- CI/CD or GitHub-based workflows.

A simple automated backup flow may include:
1. checking repository status;
2. running tests;
3. generating the release artifact;
4. copying the artifact to the archive folder;
5. saving a version note or build log.

Even if full automation is not implemented, documenting a clear semi-automatic procedure is useful for release engineers and maintainers.

---

## 10. Full Recovery Procedure

A full recovery may be required if:
- the working environment is lost;
- the latest build becomes unusable;
- a previous stable version must be restored;
- important local test data must be recovered.

Recommended full recovery steps:

1. clone the repository again:
```bash
git clone https://github.com/serhiibatrachenko505-stack/diploma-prog.git
cd diploma-prog
```

2. switch to the required stable version:
```bash
git checkout v1.0.0
```

3. install dependencies:
```bash
flutter pub get
```

4. restore release/signing configuration if needed;

5. build the application again:
```bash
flutter build apk --release
```

6. install the application on the target device:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

7. if a database backup is available and needed, restore it according to the accessible device/debug procedure.

---

## 11. Selective Recovery

Selective recovery may be used when only a specific part of the project must be restored.

Examples:
- restore only the source code from a previous Git commit;
- restore only a previous stable APK or AAB;
- restore only configuration files;
- restore only a local SQLite database copy for testing.

This approach is useful when a complete rollback is unnecessary and only one damaged or outdated component must be replaced.

---

## 12. Recovery Testing

A backup is useful only if recovery actually works.

Therefore, it is recommended to periodically verify that recovery is possible by checking:
1. whether the repository can be cloned successfully;
2. whether dependencies can be installed successfully;
3. whether the APK can be rebuilt;
4. whether the APK can be installed on a device;
5. whether the application starts correctly;
6. whether a local database backup can be reused, if applicable.

Recovery testing is especially important:
- before a major release;
- after changing build configuration;
- after changing signing settings;
- after changes in the database schema.

---

## 13. Backup and Recovery Checklist

### Before Backup
- [ ] project is in a stable state
- [ ] completed changes are committed
- [ ] version number or commit is known

### During Backup
- [ ] source code backup created
- [ ] release artifact backup created
- [ ] configuration backup stored securely
- [ ] local database backup created if needed
- [ ] important logs preserved

### After Backup
- [ ] backup integrity checked
- [ ] storage location documented
- [ ] version/date recorded
- [ ] recovery possibility confirmed