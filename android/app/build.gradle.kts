import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Clé de signature release : android/key.properties (ignoré par git, voir
// android/.gitignore). Sans ce fichier, une build release échoue au lieu
// d'être signée silencieusement avec la clé de debug.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { load(it) }
    }
}
val hasReleaseKey = keystorePropertiesFile.exists()

android {
    namespace = "com.embedforge.academy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.embedforge.academy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKey) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
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

// Refuse de produire un APK/AAB release sans vraie clé.
gradle.taskGraph.whenReady {
    val wantsRelease = allTasks.any {
        it.name.contains("Release") &&
            (it.name.startsWith("assemble") || it.name.startsWith("bundle") ||
                it.name.startsWith("package"))
    }
    if (wantsRelease && !hasReleaseKey) {
        throw GradleException(
            "android/key.properties introuvable : impossible de signer la release. " +
                "Voir README.md, section « Signature »."
        )
    }
}
