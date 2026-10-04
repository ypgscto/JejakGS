import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (!keystorePropertiesFile.exists()) {
    throw GradleException("File key.properties tidak ditemukan di: ${keystorePropertiesFile.absolutePath}")
}

keystoreProperties.load(FileInputStream(keystorePropertiesFile))

fun keystoreProp(name: String): String {
    return keystoreProperties.getProperty(name)
        ?: throw GradleException("Property '$name' tidak ditemukan di key.properties")
}

android {
    namespace = "id.ac.stikesgs.jejakgs"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

	signingConfigs {
		create("release") {
			keyAlias = keystoreProp("keyAlias")
			keyPassword = keystoreProp("keyPassword")
			storeFile = file(keystoreProp("storeFile"))
			storePassword = keystoreProp("storePassword")
		}
	}

	buildTypes {
		release {
			signingConfig = signingConfigs.getByName("release")
			isMinifyEnabled = false
			isShrinkResources = false
		}
	}
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "id.ac.stikesgs.jejakgs"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
