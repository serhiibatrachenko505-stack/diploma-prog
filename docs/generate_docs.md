# Documentation Generation Guide

## 1. General Information

This document describes how code documentation is generated for the Diploma Work Prog project.

The project is implemented in Flutter/Dart, so code documentation is based on Dart documentation comments written with the `///` format. The generated documentation is created automatically from public API elements such as classes, constructors, methods, fields, and enums that contain proper documentation comments.

The project uses the standard Dart documentation tool:

```bash
dart doc
```

This tool generates HTML documentation from source code comments and makes it possible to browse project APIs in a structured format.

---

## 2. Documentation Standard Used in the Project

The project follows the standard Dart documentation approach.

Main rules:
- public classes, methods, constructors, fields, enums, and enum values should be documented with `///`;
- each documentation block should begin with a short summary sentence;
- important return values, side effects, and usage notes should be described when needed;
- references to other code elements may use Dart doc references such as `[AuthService]`, `[UserDao]`, or `[NutritionResult]`.

This approach ensures that the code remains understandable for current and future contributors and supports automatic documentation generation.

---

## 3. Tool Used for Automatic Documentation Generation

The selected tool for automatic documentation generation is `dart doc`.

It was chosen because:
- it is the standard solution for Dart projects;
- it works directly with Dart documentation comments;
- it integrates naturally with Flutter/Dart code structure;
- it generates structured HTML documentation for browsing code interfaces.

No external third-party documentation generator is required for this project because the standard Dart toolchain already provides the necessary functionality.

---

## 4. How to Generate Documentation

To generate the documentation for this project, follow these steps:

1. Open a terminal in the project root directory.
2. Make sure project dependencies are installed:
```bash
flutter pub get
```

3. Run the documentation generator:
```bash
dart doc
```

4. Wait until the generation process completes successfully.

If the source code contains proper documentation comments, the tool will generate HTML pages for public API elements of the project.

---

## 5. Output Location

By default, generated documentation is placed in the following directory:

```text
doc/api
```

This folder contains the generated HTML documentation and related assets.

To view the generated documentation:
1. open the `doc/api` directory;
2. locate the main HTML entry file;
3. open it in a web browser.

This allows the generated API documentation to be browsed locally.

---

## 6. When Documentation Should Be Regenerated

Documentation should be regenerated whenever:
- public classes are added or changed;
- public methods, constructors, or fields are modified;
- existing documentation comments are updated;
- new modules are introduced into the project;
- API structure changes in a way that affects generated documentation.

Keeping generated documentation up to date helps maintain consistency between source code and project documentation.

---

## 7. Documentation Quality Requirements

Before generating documentation, the source code should pass analyzer checks related to documentation quality.

In this project, documentation quality is supported through analyzer rules configured in `analysis_options.yaml`, including rules that require documentation for public members.

This means the recommended workflow is:
1. update code documentation comments;
2. run:
```bash
flutter analyze
```

3. make sure documentation-related issues are resolved;
4. generate HTML documentation with:
```bash
dart doc
```

This approach reduces the risk of generating incomplete or inconsistent API documentation.

---

## 8. Archiving the Generated Documentation

After the documentation has been generated, the resulting `doc/api` directory can be archived for submission.

Recommended steps:
1. open the project folder;
2. locate the `doc/api` directory;
3. compress the directory into a `.zip` archive;
4. name the archive clearly, for example:
```text
api_docs.zip
```

The archive can then be attached to the lab submission as proof that the documentation was generated successfully.

---

## 9. Recommended Workflow for Contributors

To keep project documentation consistent, contributors should follow this workflow whenever public code is added or changed:

1. write or update `///` documentation comments in the source code;
2. run:
```bash
flutter analyze
```

3. resolve documentation-related issues if they are reported;
4. regenerate API documentation:
```bash
dart doc
```

5. verify that the generated documentation reflects the current state of the code.

This process helps ensure that documentation remains synchronized with the implementation.

---

## 10. Summary

The Diploma Work Prog project uses Dart documentation comments and the standard `dart doc` tool to generate automatic API documentation from source code.

The documentation generation process includes:
- maintaining `///` comments for public API elements;
- checking documentation quality through analyzer rules;
- generating HTML documentation with `dart doc`;
- storing the result in `doc/api`;
- archiving the generated documentation for submission when required.

This workflow makes project documentation easier to maintain, improves readability for contributors, and provides a practical way to keep technical documentation up to date with the code base.