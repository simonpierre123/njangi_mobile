allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        val androidLibrary = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        if (androidLibrary != null && androidLibrary.namespace.isNullOrBlank()) {
            androidLibrary.namespace = when (project.name) {
                "contacts_service" -> "flutter.plugins.contactsservice.contactsservice"
                else -> "com.example.${project.name}"
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
