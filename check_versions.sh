#!/bin/bash -e

# -----------------------------------------------------------------------------
# Function to check and print important environment variables
# -----------------------------------------------------------------------------
check_env_vars() {
  echo "Environment Variables:"

  if [ -z "$JAVA_HOME" ]; then
    echo "  JAVA_HOME not set"
  else
    echo "  JAVA_HOME: $JAVA_HOME"
  fi

  if [ -z "$ANDROID_SDK_ROOT" ]; then
    echo "  ANDROID_SDK_ROOT not set"
  else
    echo "  ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
  fi

  if [ -z "$ANDROID_HOME" ]; then
    echo "  ANDROID_HOME not set"
  else
    echo "  ANDROID_HOME: $ANDROID_HOME"
  fi
}

# -----------------------------------------------------------------------------
# Function to get the Java version
# -----------------------------------------------------------------------------
get_java_version() {
  if command -v java &>/dev/null; then
    java -version 2>&1 | awk -F '"' '/version/ {print $2}' || echo "Java version not detectable"
  else
    echo "Java not found"
  fi
}

# -----------------------------------------------------------------------------
# Function to get the Gradle version (via gradlew)
# -----------------------------------------------------------------------------
get_gradle_version() {
  if [ -f android/gradlew ]; then
    (cd android && ./gradlew -v) | grep "Gradle " | awk '{print $2}' || echo "Gradle version not detectable"
  else
    echo "gradlew not found. Run 'flutter build apk' once to generate it."
  fi
}

# -----------------------------------------------------------------------------
# Function to get the Android Gradle Plugin (AGP) version
# -----------------------------------------------------------------------------
get_agp_version() {
  if [ -f android/build.gradle ]; then
    awk -F ':' '/com.android.tools.build:gradle:/ {
      gsub(/[",]/, "", $3);
      print $3
    }' android/build.gradle || echo "AGP version not found in build.gradle"
  else
    echo "android/build.gradle not found."
  fi
}

# -----------------------------------------------------------------------------
# Function to resolve SDK versions from gradle.properties or directly in build.gradle
# -----------------------------------------------------------------------------
resolve_sdk_version() {
  local version_key=$1
  local build_gradle=$2
  local version=""

  # Check gradle.properties if the key is defined there
  if [ -f android/gradle.properties ]; then
    version=$(awk -F '=' -v key="$version_key" '$1 == key {gsub(/[[:space:]]/, "", $2); print $2}' android/gradle.properties)
  fi

  # Fall back to checking build.gradle if not found in gradle.properties
  if [ -z "$version" ]; then
    version=$(awk -F '[ :]' -v key="$version_key" '
      $1 == key || $2 == key {gsub(/["]/, "", $NF); print $NF}
    ' "$build_gradle")
  fi

  echo "${version:-Not found}"
}

# -----------------------------------------------------------------------------
# Function to get Android SDK versions from app's build.gradle
# -----------------------------------------------------------------------------
get_android_sdk_versions() {
  local build_gradle="android/app/build.gradle"
  if [ -f "$build_gradle" ]; then
    compileSdkVersion=$(resolve_sdk_version "compileSdkVersion" "$build_gradle")
    minSdkVersion=$(resolve_sdk_version "minSdkVersion" "$build_gradle")
    targetSdkVersion=$(resolve_sdk_version "targetSdkVersion" "$build_gradle")
    buildToolsVersion=$(resolve_sdk_version "buildToolsVersion" "$build_gradle")

    echo "compileSdkVersion: $compileSdkVersion"
    echo "minSdkVersion: $minSdkVersion"
    echo "targetSdkVersion: $targetSdkVersion"
    echo "buildToolsVersion: $buildToolsVersion"
  else
    echo "android/app/build.gradle not found."
  fi
}

# -----------------------------------------------------------------------------
# Main script execution
# -----------------------------------------------------------------------------

# 1) Print environment variables
check_env_vars
echo ""

# 2) Java
echo "Java Version:"
get_java_version
echo ""

# 3) Gradle
echo "Gradle Version:"
get_gradle_version
echo ""

# 4) AGP
echo "Android Gradle Plugin (AGP) Version:"
get_agp_version
echo ""

# 5) Android SDK Versions
echo "Android SDK Versions:"
get_android_sdk_versions
echo ""

# 6) Flutter Doctor
echo "Flutter Doctor:"
flutter doctor -v
echo ""

exit 0


