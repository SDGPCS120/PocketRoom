allprojects {
    repositories {
        google()
        mavenCentral()
<<<<<<< HEAD
        maven {
            url = uri("${rootDir}/../unity/pocketroom/Assets/GeneratedLocalRepo/Firebase/m2repository")
        }
        // Unity export keeps local AAR/JAR artifacts here (unity-classes, ARCore bridge, etc.).
        flatDir {
            dirs("${rootDir}/unityLibrary/libs")
        }
=======
>>>>>>> ai-search
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
