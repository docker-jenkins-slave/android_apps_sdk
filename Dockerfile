FROM jenkinsslave/base_jdk7

# To check which i386 dependencies are needed
# objdump -x adb | grep NEEDED

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        libc6:i386 \
        libstdc++6:i386 \
        libncurses5:i386 \
        zlib1g:i386 \
        && \
    rm -rf /var/lib/apt/lists/*

# curl, zip python unzip uuid zip yasm ant

# To list all/latest available SDK components, use:
# /opt/android-sdk-linux/tools/android list sdk --all --extended --no-ui
# /opt/android-sdk-linux/tools/android list sdk --extended --no-ui

RUN wget http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
    tar -xzvf android-sdk_r24.4.1-linux.tgz -C /opt/ && \
    echo "y" | /opt/android-sdk-linux/tools/android update sdk --no-ui -a --filter "\
      android-23, \
      tools, \
      platform-tools, \
      build-tools-23.0.2, \
      addon-google_apis-google-23, \
      extra-android-m2repository, \
      extra-android-support, \
      extra-google-google_play_services, \
      extra-google-play_apk_expansion, \
      extra-google-play_billing, \
      extra-google-play_licensing" && \
    rm -f android-sdk_r24.4.1-linux.tgz

ADD android-sdk.sh /etc/profile.d/
