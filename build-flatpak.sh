#!/bin/bash

# Build script for auvid Flatpak
# This installs the pre-built Flutter app into the Flatpak sandbox

set -e  # Exit on error
set -x  # Show commands

projectName=auvid
projectId=io.github.IshuSinghSE.auvid
executableName=auvid

# Extract portable Flutter build
mkdir -p $projectName
tar -xf $projectName-Linux-Portable.tar.gz -C $projectName

# Copy the portable app to the Flatpak location
cp -r $projectName /app/
chmod +x /app/$projectName/$executableName
mkdir -p /app/bin
ln -s /app/$projectName/$executableName /app/bin/$executableName

# Install the icon (512x512 PNG for Linux)
iconDir=/app/share/icons/hicolor/512x512/apps
mkdir -p $iconDir
cp linux/runner/resources/app_icon.png $iconDir/$projectId.png

# Also install scalable if you have SVG
# iconDirScalable=/app/share/icons/hicolor/scalable/apps
# mkdir -p $iconDirScalable
# cp assets/images/logo.svg $iconDirScalable/$projectId.svg

# Install the desktop file
desktopFileDir=/app/share/applications
mkdir -p $desktopFileDir
cp packaging/linux/$projectId.desktop $desktopFileDir/

# Install the AppStream metadata file
metadataDir=/app/share/metainfo
mkdir -p $metadataDir
cp packaging/linux/$projectId.metainfo.xml $metadataDir/
