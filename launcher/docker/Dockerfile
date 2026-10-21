# Build-only image for the launcher: JDK 17 + Android SDK 34, nothing installed on the host.
# x86_64 on purpose: AGP's aapt2 for Linux ships as x86_64 only (runs under Rosetta on Apple Silicon).
FROM --platform=linux/amd64 eclipse-temurin:17.0.12_7-jdk-jammy

ENV ANDROID_HOME=/opt/android-sdk \
    GRADLE_USER_HOME=/cache/gradle
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH

RUN apt-get update \
 && apt-get install -y --no-install-recommends unzip curl \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p $ANDROID_HOME/cmdline-tools \
 && curl -fsSL -o /tmp/tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
 && unzip -q /tmp/tools.zip -d $ANDROID_HOME/cmdline-tools \
 && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
 && rm /tmp/tools.zip \
 && yes | sdkmanager --licenses > /dev/null \
 && sdkmanager --install "platforms;android-34" "build-tools;34.0.0" "platform-tools" > /dev/null

WORKDIR /src
