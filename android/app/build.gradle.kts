import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mrtechbd.lifeos"
    
    // 🟢 FIXED: Forced compileSdk to 34 to resolve lStar resource error
    compileSdk = 34 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.mrtechbd.lifeos"
        minSdk = flutter.minSdkVersion
        
        // 🟢 FIXED: Forced targetSdk to 34 to match compileSdk
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters.add("armeabi-v7a")
            abiFilters.add("arm64-v8a")
            abiFilters.add("x86_64")
        }
    }

    packaging {
        jniLibs {
            pickFirsts.add("lib/x86/libisar.so")
            pickFirsts.add("lib/x86_64/libisar.so")
            pickFirsts.add("lib/armeabi-v7a/libisar.so")
            pickFirsts.add("lib/arm64-v8a/libisar.so")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = System.getenv("KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
            keyPassword = System.getenv("KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")
            storePassword = System.getenv("KEYSTORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")
            
            val storeFilePath = keystoreProperties.getProperty("storeFile")
            storeFile = if (System.getenv("GITHUB_ACTIONS") == "true") {
                file("release-key.jks")
            } else if (storeFilePath != null) {
                file(storeFilePath)
            } else {
                null
            }
        }
    }

    buildTypes {
        // 🟢 FIXED: Kotlin DSL standard for existing build types
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}