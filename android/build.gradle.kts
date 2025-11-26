// Top-level build file
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Latest stable (November 2025)
        classpath("com.android.tools.build:gradle:8.13.0")
      //  classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.20")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.20")

        
        classpath("com.google.gms:google-services:4.4.4")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: move build folder outside android/ (common in Flutter)
val customBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(customBuildDir)

subprojects {
    project.layout.buildDirectory.value(customBuildDir.dir(project.name))
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

