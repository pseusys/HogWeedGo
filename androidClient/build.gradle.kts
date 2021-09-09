import org.jlleitschuh.gradle.ktlint.reporter.ReporterType

tasks.withType<Wrapper> {
    gradleVersion = "7.1.1"
    distributionType = Wrapper.DistributionType.ALL
}

buildscript {
    repositories {
        google()
        jcenter()
        maven("https://plugins.gradle.org/m2/")
        maven("https://jitpack.io")
    }

    dependencies {
        classpath(Dependencies.Plugins.buildGradle)
        classpath(Dependencies.Plugins.buildKotlin)
        classpath(Dependencies.Plugins.googlePlay)
        classpath(Dependencies.Plugins.ktlintClasspath)
        classpath("androidx.navigation:navigation-safe-args-gradle-plugin:${Versions.safeArgs}")
        classpath("com.android.tools.build:gradle:4.2.1")
    }
}

allprojects {
    repositories {
        google()
        jcenter()
    }
}

tasks.register("clean").configure {
    delete("build")
}

apply(plugin = Dependencies.Plugins.ktlint)

configure<org.jlleitschuh.gradle.ktlint.KtlintExtension> {
    version.set("0.22.0")
    // Prints the name of failed rules
    verbose.set(true)
    debug.set(true)
    outputToConsole.set(true)
    ignoreFailures.set(true)

    // Default "plain" reporter is actually harder to read.
    reporters {
        reporter(ReporterType.JSON)
        reporter(ReporterType.PLAIN)
        reporter(ReporterType.CHECKSTYLE)
    }
}
