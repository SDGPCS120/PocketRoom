pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

// Include Unity export module only when present so normal Flutter builds still work.
val unityLibraryDir = file("unityLibrary")
if (unityLibraryDir.exists()) {
    include(":unityLibrary")
    project(":unityLibrary").projectDir = unityLibraryDir

    val xrManifestDir = file("unityLibrary/xrmanifest.androidlib")
    if (xrManifestDir.exists()) {
        include(":unityLibrary:xrmanifest.androidlib")
        project(":unityLibrary:xrmanifest.androidlib").projectDir = xrManifestDir
    }

    val firebaseAppDir = file("unityLibrary/FirebaseApp.androidlib")
    if (firebaseAppDir.exists()) {
        include(":unityLibrary:FirebaseApp.androidlib")
        project(":unityLibrary:FirebaseApp.androidlib").projectDir = firebaseAppDir
    }
} else {
    include(":unityLibrary")
    project(":unityLibrary").projectDir =
        file("../../../backend/src/modules/unityLibrary-stub")
}
