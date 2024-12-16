#!/bin/bash

echo "🧹 Cleaning iOS build..."
cd ios
rm -rf Pods Podfile.lock
echo "🗑️  Removed Pods and Podfile.lock"

echo "🔄 Running pod deintegrate..."
pod deintegrate

echo "🧼 Cleaning pod cache..."
pod cache clean --all

echo "📦 Installing pods..."
pod install --repo-update
cd ..

echo "🧹 Flutter clean..."
flutter clean

echo "📥 Flutter pub get..."
flutter pub get

echo "✅ All done!"