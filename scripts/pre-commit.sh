#!/bin/sh
flutter analyze
if [ $? -ne 0 ]; then
  echo "Linting failed. Commit aborted."
  exit 1
fi