plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "com.bindlab.shared"
    compileSdk = 35
    defaultConfig { minSdk = 30 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    buildFeatures { compose = true }
}

dependencies {
    // Compile against the same runtime the apps ship (local AAR if present, else Maven): the Java API
    // differs between versions (e.g. Module.loadMethod returns int in 1.0.0, void in 1.5.1).
    val aar = rootProject.extra["executorchAar"] as File?
    if (aar != null) compileOnly(files(aar)) else compileOnly(rootProject.extra["executorchMaven"] as String)

    api("com.squareup.okhttp3:okhttp:4.12.0")
    api("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    api(platform("androidx.compose:compose-bom:2024.12.01"))
    api("androidx.compose.material3:material3")
    api("androidx.compose.ui:ui")
    api("androidx.compose.ui:ui-tooling-preview")
    api("androidx.activity:activity-compose:1.9.3")
    api("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    api("androidx.lifecycle:lifecycle-runtime-compose:2.8.7")
    api("androidx.camera:camera-core:1.4.1")
    api("androidx.camera:camera-camera2:1.4.1")
    api("androidx.camera:camera-lifecycle:1.4.1")
    api("androidx.camera:camera-view:1.4.1")
}
