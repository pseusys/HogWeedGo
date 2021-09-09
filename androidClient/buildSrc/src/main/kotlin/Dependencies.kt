object Dependencies {

    object Plugins {
        const val buildGradle = "com.android.tools.build:gradle:${Versions.buildGradle}"
        const val buildKotlin = "org.jetbrains.kotlin:kotlin-gradle-plugin:${Versions.kt}"
        const val googlePlay = "com.google.gms:google-services:${Versions.googleServices}"
        const val safeArgs = "androidx.navigation:navigation-safe-args-gradle-plugin:${Versions.safeArgs}"
        const val kotlin = "kotlin"
        const val ktlint = "org.jlleitschuh.gradle.ktlint"
        const val ktlintClasspath = "org.jlleitschuh.gradle:ktlint-gradle:${Versions.ktlint}"
    }

    object App {
        const val id = "com.ekdorn.hogweedgo"
        const val minSdk = 23
        const val compileSdk = 30
        const val targetSdk = 30
        const val buildTools = "30.0.0"
        const val versionCode = 4
        const val versionName = "0.0.3"
    }

    object Kt {
        const val stdLib = "org.jetbrains.kotlin:kotlin-stdlib:${Versions.kt}"
        const val stdJdk = "org.jetbrains.kotlin:kotlin-stdlib-jdk7:${Versions.kt}"
        const val serialize = "org.jetbrains.kotlinx:kotlinx-serialization-json:${Versions.serialize}"
    }

    object Androidx {
        const val coreKtx = "androidx.core:core-ktx:${Versions.ktxCore}"
        const val appCompat = "androidx.appcompat:appcompat:${Versions.appcompat}"
        const val activity = "androidx.activity:activity-ktx:${Versions.activity}"
        const val fragment = "androidx.fragment:fragment-ktx:${Versions.fragment}"
        const val constraint = "androidx.constraintlayout:constraintlayout:${Versions.constraint}"

        const val navFragment = "androidx.navigation:navigation-fragment-ktx:${Versions.navFragment}"
        const val navUiKtx = "androidx.navigation:navigation-ui-ktx:${Versions.navUiKtx}"

        const val lifecycleViewModel = "androidx.lifecycle:lifecycle-viewmodel-ktx:${Versions.lifecycle}"
        const val lifecycleLiveData = "androidx.lifecycle:lifecycle-livedata-ktx:${Versions.lifecycle}"

        const val roomRuntime = "androidx.room:room-runtime:${Versions.room}"
        const val roomCompiler = "androidx.room:room-compiler:${Versions.room}"
        const val roomKt = "androidx.room:room-ktx:${Versions.room}"
    }

    object Common {
        val fileTree = mapOf("dir" to "libs", "include" to listOf("*.jar"))
        const val timber = "com.jakewharton.timber:timber:${Versions.timber}"
    }

    object Room {
        const val roomRuntime = "androidx.room:room-runtime:${Versions.room}"
        const val room = "androidx.room:room-ktx:${Versions.room}"
        const val roomCompiler = "androidx.room:room-compiler:${Versions.room}"
    }

    object Firebase {
        const val firebaseAnalytics = "com.google.firebase:firebase-analytics-ktx:${Versions.analytics}"
        const val firebaseDatabase = "com.google.firebase:firebase-database-ktx:${Versions.database}"
        const val firebaseStorage = "com.google.firebase:firebase-storage-ktx:${Versions.store}"
    }

    object Network {
        const val retrofit = "com.squareup.retrofit2:retrofit:${Versions.retrofit}"
        const val gson = "com.squareup.retrofit2:converter-gson:${Versions.retrofit}"
        const val ohttp = "com.squareup.okhttp3:okhttp:${Versions.okhttp}"
        const val loggingInterceptor = "com.squareup.okhttp3:logging-interceptor:${Versions.loggingInterceptor}"
    }

    object Google {
        const val material = "com.google.android.material:material:${Versions.material}"
        const val maps = "com.google.android.libraries.maps:maps:${Versions.maps}"
        const val location = "com.google.android.gms:play-services-location:${Versions.play}"
    }

    object Outer {
        const val glide = "com.github.bumptech.glide:glide:${Versions.glide}"
    }

    object Test {
        const val JUnit4 = "junit:junit:${Versions.junit}"
        const val extJunit = "androidx.test.ext:junit:${Versions.extJunit}"
        const val espresso = "androidx.test.espresso:espresso-core:${Versions.espresso}"
        const val archCore = "androidx.arch.core:core-testing:${Versions.archCore}"
        const val robolectric = "org.robolectric:robolectric:${Versions.robolectric}"
    }
}
