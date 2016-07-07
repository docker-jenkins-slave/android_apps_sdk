# Docker based build machine with Android SDK for Jenkins CI

## Jenkins usage
This image is intended to use as vm which is triggered only for the duration of the build and then discarded. 
From the job perspective, it looks like it's an ordinary slave. All the hard work is done by the Jenkins docker plugin:
https://wiki.jenkins-ci.org/display/JENKINS/Docker+Plugin
also the image requires environment variables injection plugin for ANDROID_HOME and PATH configuration
https://wiki.jenkins-ci.org/display/JENKINS/EnvInject+Plugin

Because jenkins creates new instance of the VM for each build, there is no need to have some machines running in advance. 
This comes with (positive) side-effect that all dependencies are always freshly downloaded, so you won't end in situation
where you have somehow cached dependency and you can't build elsewhere. To speed build up, you can use https://archiva.apache.org/index.cgi as local caching proxy.

The build is run under user **jenkins** who has password **jenkins**.

### Latest environment
```
jenkins@96c59182c5e7:~$ java -version
openjdk version "1.8.0_91"
OpenJDK Runtime Environment (build 1.8.0_91-8u91-b14-0ubuntu4~16.04.1-b14)
OpenJDK 64-Bit Server VM (build 25.91-b14, mixed mode)
```

```
jenkins@96c59182c5e7:~$ android list target
Available Android targets:
id: 1 or "android-24"
     Name: Android N
     Type: Platform
     API level: 24
     Revision: 1

build-tools: 24.0.0
```

### Jenkins configuration
1. Install the plugins
  * Docker
  * EnvInject
  * Gradle
  * Git, etc.
2. Navigate to Jenkins > Manage Jenkins
3. In Section Cloud > Docker configure connection to a docker machine / set of machines
  * Example:
    * Name: `Open docker`
    * Host: `http://192.168.0.5:4243`
    * and configure credentials (if needed)
  * Test the connection
4. In Section Cloud > Docker press "Add Docker Template" and configure it
  * Example: 
    * Docker Image: `jenkinsslave/android_apps_sdk:android-24-build-tools-24.0.0`
      (note image can be specified exactly to a tag, or you can leave it to use latest)
    * Remote Filing System Root: `/home/jenkins`
    * Labels: `android_apps`
      (this label is then used in the job configuration, as if it was any other slave)
    * Launch method: Docker SSH computer launcher
    * Credentials: configure jenkins/jenkins
    * Pull strategy: Pull once and update latest
  also set instance capacity, to keep reasonable concurrent jobs running
  
### Jenkins job (pipeline) configuration
1. Tick "Restrict where this project can be run"
2. Fill in label expression with label specified earlier:
  * Label Expression: `android_apps`
3. In Build Environemnt section, tick Inject environment variables to the build process
4. Configure Properties File Path to `/home/jenkins/android-sdk.env`

now it only needs git and gradle configured to install required version

## Explore image
on your docker machine `me@docker01:~$` run
```
docker run -it jenkinsslave/android_apps_sdk /bin/bash
```
which will bring latest, or you can specify older version:
```
docker run -it jenkinsslave/android_apps_sdk:android-24-build-tools-24.0.0 /bin/bash
docker run -it jenkinsslave/android_apps_sdk:android-23-build-tools-23.0.3 /bin/bash
```
You can find the full list on https://hub.docker.com/r/jenkinsslave/android_apps_sdk/tags/


Once image is running `root@cf79a127b169:/#` get same shell as jenkins using `su - jenkins`

### Pull image
```
docker pull -it jenkinsslave/android_apps_sdk /bin/bash
```

## Extend and create customised image
in your `Dockerfile`
```
FROM jenkinsslave/android_apps_sdk

RUN ...
```
