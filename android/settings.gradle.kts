pluginManagement {
    val flutterSdkPath: String = run {
        val properties = java.util.Properties()
        val localPropertiesFile = file("local.properties")

        require(localPropertiesFile.exists()) {
            "local.properties file not found. Please make sure it exists in the project root."
        }

        localPropertiesFile.inputStream().use { properties.load(it) }

        val sdkPath = properties.getProperty("flutter.sdk")
        require(!sdkPath.isNullOrEmpty()) {
            "flutter.sdk not set in local.properties"
        }

        sdkPath
    }

    // Include Flutter tools for plugin support
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Plugins for the project
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.10.0" apply false
    id("org.jetbrains.kotlin.android") version "2.1.21" apply false
}

// Include the app module
include(":app")
