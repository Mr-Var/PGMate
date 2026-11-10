import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.pgmate.pg_manager"
    // flutter_local_notifications needs SDK 37 to compile against.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.pgmate.pg_manager"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // One fixed key for every build, so a new APK installs as an update
    // instead of failing with "App not installed". The key is supplied by
    // GitHub Actions secrets (or a local, git-ignored signing.properties).
    val local = Properties().apply {
        val f = file("signing.properties")
        if (f.exists()) f.inputStream().use { load(it) }
    }
    val storePath = System.getenv("PGM_KEYSTORE_PATH") ?: local.getProperty("storeFile")
    val storePass = System.getenv("PGM_SIGNING_PASSWORD") ?: local.getProperty("storePassword")
    val hasFixedKey = storePath != null && storePass != null && file(storePath).exists()
    signingConfigs {
        if (hasFixedKey) {
            create("fixed") {
                storeFile = file(storePath!!)
                storePassword = storePass
                keyAlias = System.getenv("PGM_KEY_ALIAS") ?: local.getProperty("keyAlias", "pgmanager")
                keyPassword = storePass
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasFixedKey) "fixed" else "debug")
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.core:core-ktx:1.17.0")
}
