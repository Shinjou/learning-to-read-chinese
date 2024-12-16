#!/bin/bash

echo "🧹 Starting deep cleanup of Flutter and iOS build..."

echo "📂 Cleaning up build and Pods..."
cd ios
rm -rf Pods/
rm -rf .symlinks/
rm -rf Podfile.lock
rm -rf ~/.pub-cache/git/
cd ..
rm -rf build/

echo "🔄 Cleaning Flutter..."
flutter clean
flutter pub get

echo "♻️ Resetting iOS..."
cd ios
pod deintegrate
pod cache clean --all
pod setup
pod install --repo-update
cd ..

echo "✅ Deep cleanup complete!"