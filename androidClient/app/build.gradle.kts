plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("kotlin-kapt")
    id("androidx.navigation.safeargs.kotlin")
    id("kotlin-parcelize")
}

android {
    compileSdkVersion(Dependencies.App.compileSdk)
    buildToolsVersion(Dependencies.App.buildTools)

    compileOptions {
        sourceCompatibility(JavaVersion.VERSION_1_8)
        targetCompatibility(JavaVersion.VERSION_1_8)
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = Dependencies.App.id
        minSdkVersion(Dependencies.App.minSdk)
        targetSdkVersion(Dependencies.App.targetSdk)
        versionCode = Dependencies.App.versionCode
        versionName = Dependencies.App.versionName

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildFeatures {
        viewBinding = true
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))

    implementation(Dependencies.Kt.stdLib)
    //implementation(Dependencies.Kt.stdJdk)
    //implementation(Dependencies.Kt.serialize)

    implementation(Dependencies.Common.timber)

    implementation(Dependencies.Androidx.coreKtx)
    implementation(Dependencies.Androidx.appCompat)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.4.1")

    implementation(Dependencies.Androidx.activity)
    implementation(Dependencies.Androidx.fragment)
    implementation(Dependencies.Androidx.constraint)
    implementation("androidx.preference:preference-ktx:1.1.1")

    implementation(Dependencies.Androidx.lifecycleViewModel)
    implementation(Dependencies.Androidx.lifecycleLiveData)

    implementation(Dependencies.Androidx.navFragment)
    implementation(Dependencies.Androidx.navUiKtx)

    implementation(Dependencies.Firebase.firebaseAnalytics)
    implementation(Dependencies.Firebase.firebaseDatabase)
    implementation(Dependencies.Firebase.firebaseStorage)

    //implementation(Dependencies.Androidx.roomKt)
    //implementation(Dependencies.Room.roomRuntime)
    //implementation(Dependencies.Room.room)
    //implementation(Dependencies.Room.roomCompiler)

    //implementation(Dependencies.Network.retrofit)
    //implementation(Dependencies.Network.gson)
    //implementation(Dependencies.Network.ohttp)
    //implementation(Dependencies.Network.loggingInterceptor)

    implementation(Dependencies.Google.material)
    implementation(Dependencies.Google.maps)
    implementation(Dependencies.Google.location)

    implementation(Dependencies.Outer.glide)

    kapt("com.github.bumptech.glide:compiler:4.12.0")

    testImplementation(Dependencies.Test.JUnit4)
    testImplementation(Dependencies.Test.robolectric)
    testImplementation(Dependencies.Test.extJunit)
    androidTestImplementation(Dependencies.Test.espresso)
    androidTestImplementation(Dependencies.Test.archCore)
    implementation(kotlin("reflect"))
}
