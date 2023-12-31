////
////  tmp.swift
////  UpgradeUpsell
////
////  Created by zahra SHAHIN on 2023-11-09.
////
//
//import SwiftUI
//
//struct tmp: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
////
//name: "Build iOS app"
//
//on:
//  workflow_dispatch:
//    branches: [main]
//
//jobs:
//  build_with_signing:
//    runs-on: macos-latest
//    steps:
//      - name: Check Xcode version
//        run: /usr/bin/xcodebuild -version
//
//      - name: Checkout repository
//        uses: actions/checkout@v3
//
//      - name: Install the Apple certificate and provisioning profile
//        env:
//          BUILD_CERTIFICATE_BASE64: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
//          P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
//          BUILD_PROVISION_PROFILE_BASE64: ${{ secrets.BUILD_PROVISION_PROFILE_BASE64 }}
//          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
//        run: |
//          CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
//          PP_PATH=$RUNNER_TEMP/build_pp.mobileprovision
//          KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
//
//          echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
//          echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode -o $PP_PATH
//
//          security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
//          security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
//          security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
//
//          security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
//          security list-keychain -d user -s $KEYCHAIN_PATH
//
//          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
//          cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles
//
//      - name: Build archive
//        run: |
//          xcodebuild -scheme "UpgradeUpsell" \
//          -archivePath $RUNNER_TEMP/UpgradeUpsell.xcarchive \
//          -sdk iphoneos \
//          -configuration Debug \
//          -destination generic/platform=iOS \
//          clean archive
//
//      - name: Update iOS Deployment Target
//        run: |
//          plutil -replace IPHONEOS_DEPLOYMENT_TARGET -string "16.0" UpgradeUpsell.xcodeproj/project.pbxproj
//
//      - name: Export IPA
//        env:
//          EXPORT_OPTIONS_PLIST: ${{ secrets.EXPORT_OPTIONS_PLIST }}
//        run: |
//          EXPORT_OPTS_PATH=$RUNNER_TEMP/ExportOptions.plist
//          echo -n "$EXPORT_OPTIONS_PLIST" | base64 --decode -o $EXPORT_OPTS_PATH
//          xcodebuild -exportArchive -archivePath $RUNNER_TEMP/UpgradeUpsell.xcarchive -exportOptionsPlist $EXPORT_OPTS_PATH -exportPath $RUNNER_TEMP/build
//
//      - name: Upload application
//        uses: actions/upload-artifact@v3
//        with:
//          name: app
//          path: ${{ runner.temp }}/build/UpgradeUpsell.ipa
//          retention-days: 3

//
//name: "Build iOS app"
//
//on:
//  workflow_dispatch:
//    branches: [main]
//
//jobs:
//  build_with_signing:
//    runs-on: macos-latest
//    steps:
//      - name: Check Xcode version
//        run: /usr/bin/xcodebuild -version
//
//      - name: Checkout repository
//        uses: actions/checkout@v3
//
//      - name: Clean Xcode project
//        run: xcodebuild clean  -scheme UpgradeUpsell
//
//      - name: Debug content of build directory
//        run: ls -R $RUNNER_TEMP
//
//
//      - name: Build archive
//        run: |
//          echo "Building archive..."
//          xcodebuild -scheme "UpgradeUpsell" \
//          -archivePath $RUNNER_TEMP/UpgradeUpsell.xcarchive \
//          -sdk iphoneos \
//          -configuration Debug \
//          clean archive \
//          -allowProvisioningUpdates
//          echo "Archive built successfully."
//
//      - name: Debug content of $RUNNER_TEMP
//        run: |
//          ls -R $RUNNER_TEMP
//
//      - name: Upload archive
//        uses: actions/upload-artifact@v3
//        with:
//          name: archive
//          path: ${{ runner.temp }}/UpgradeUpsell.xcarchive
//          retention-days: 3

//last ver
//name: "Build iOS app"
//
//on:
//  workflow_dispatch:
//    branches: [main]
//
//jobs:
//  build_with_signing:
//    runs-on: macos-latest
//    steps:
//      - name: Check Xcode version
//        run: /usr/bin/xcodebuild -version
//
//      - name: Checkout repository
//        uses: actions/checkout@v3
//
//      - name: Install the Apple certificate and provisioning profile
//        env:
//          BUILD_CERTIFICATE_BASE64: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
//          P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
//          BUILD_PROVISION_PROFILE_BASE64: ${{ secrets.BUILD_PROVISION_PROFILE_BASE64 }}
//          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
//        run: |
//          CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
//          PP_PATH=$RUNNER_TEMP/build_pp.mobileprovision
//          KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db
//
//          echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode -o $CERTIFICATE_PATH
//          echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode -o $PP_PATH
//
//          security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
//          security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
//          security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
//
//          security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
//          security list-keychain -d user -s $KEYCHAIN_PATH
//
//          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
//          cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles
//
//      - name: Debug content of build directory
//        run: ls -R $RUNNER_TEMP
//
//      - name: Build archive
//        run: |
//          echo "Building archive..."
//          xcodebuild -scheme "UpgradeUpsell" \
//          -archivePath $RUNNER_TEMP/UpgradeUpsell.xcarchive \
//          -sdk iphoneos \
//          -configuration Debug \
//          clean archive \
//          -allowProvisioningUpdates
//           -destination generic/platform=iOS \
//          echo "Archive built successfully."
//
//      - name: Update iOS Deployment Target
//        run: |
//          plutil -replace IPHONEOS_DEPLOYMENT_TARGET -string "16.0" UpgradeUpsell.xcodeproj/project.pbxproj
//
//      - name: Export IPA
//        env:
//          EXPORT_OPTIONS_PLIST: ${{ secrets.EXPORT_OPTIONS_PLIST }}
//        run: |
//          EXPORT_OPTS_PATH=$RUNNER_TEMP/ExportOptions.plist
//          echo -n "$EXPORT_OPTIONS_PLIST" | base64 --decode -o $EXPORT_OPTS_PATH
//          xcodebuild -exportArchive -archivePath $RUNNER_TEMP/UpgradeUpsell.xcarchive -exportOptionsPlist $EXPORT_OPTS_PATH -exportPath $RUNNER_TEMP/build
//
//      - name: Upload application
//        uses: actions/upload-artifact@v3
//        with:
//          name: app
//          path: ${{ runner.temp }}/build/UpgradeUpsell.ipa
//          retention-days: 3
