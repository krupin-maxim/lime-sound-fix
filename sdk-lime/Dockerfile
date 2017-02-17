FROM debian:jessie
MAINTAINER nitrobin

ENV DEBIAN_FRONTEND noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

################################################################################
RUN apt-get clean
RUN apt-get update

RUN apt-get install -y \
     apt-utils \
     libgc-dev \
     libgl1-mesa-dev \
     libglu1-mesa-dev \
     g++ \ 
     g++-multilib \
     gcc-multilib \
     libasound2-dev \
     libx11-dev \
     libxinerama-dev \
     libxext-dev \
     libxi-dev \
     libxrandr-dev \
     wget \
     curl \
     git

RUN apt-get clean

################################################################################

# Installs i386 architecture required for running 32 bit Android tools
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y \
           libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 \
           python2.7 \
           python3.4 \
           mc && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean


################################################################################

# Neko environment variables
ENV NEKOVERSION 2.0.0
ENV NEKOURL http://nekovm.org/_media/neko-$NEKOVERSION-linux64.tar.gz
ENV NEKOPATH /opt/neko
ENV LD_LIBRARY_PATH $NEKOPATH
ENV PATH $NEKOPATH:$PATH

RUN mkdir -p $NEKOPATH

# Download Neko
RUN wget -O - $NEKOURL | tar xzf - --strip=1 -C $NEKOPATH

################################################################################

# Haxe environment variables
ENV HAXEVERSION=3.2.1
ENV HAXEURL http://haxe.org/website-content/downloads/$HAXEVERSION/downloads/haxe-$HAXEVERSION-linux64.tar.gz
ENV HAXEPATH /opt/haxe
ENV HAXE_STD_PATH $HAXEPATH/std/
ENV PATH $HAXEPATH:$PATH

RUN mkdir -p $HAXEPATH

# Download Haxe
RUN wget -O - $HAXEURL | tar xzf - --strip=1 -C $HAXEPATH

# Haxelib setup
ENV HAXELIB_PATH /opt/haxelib
RUN mkdir -p $HAXEPATH $HAXELIB_PATH

# workaround for https://github.com/HaxeFoundation/haxe/issues/3912
ENV HAXE_STD_PATH $HAXE_STD_PATH:.:/

################################################################################

# Installs Android NDK
ENV ANDROID_NDK_VERSION=10e ANDROID_NDK_PATH=/opt/android-ndk
ENV ANDROID_NDK_URL http://dl.google.com/android/ndk/android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.bin
#ENV ANDROID_NDK_URL http://exchange/install/sdk/android-ndk-r$ANDROID_NDK_VERSION-linux-x86_64.bin
RUN cd /opt \
    && wget -O android-ndk.bin $ANDROID_NDK_URL \
    && chmod a+x android-ndk.bin \
    && ./android-ndk.bin \
    && rm -f android-ndk.bin \
    && mv /opt/android-ndk-r$ANDROID_NDK_VERSION $ANDROID_NDK_PATH \
    && chmod -R a+rx $ANDROID_NDK_PATH

# Переменные из .hxcpp_config.xml
ENV ANDROID_NDK_ROOT $ANDROID_NDK_PATH
ENV ANDROID_SETUP true

################################################################################

#Install haxe libraries
RUN yes|haxelib install hxcpp 3.2.193 
RUN yes|haxelib install format 3.2.1

RUN cd $HAXELIB_PATH && \
    mkdir lime && \
    cd lime && \
    git clone https://github.com/openfl/lime && \
    cd lime && \
    git checkout 2.7.0 && \
    git submodule init && \
    git submodule update

RUN haxelib dev lime $HAXELIB_PATH/lime/lime
RUN chmod -R 777 $HAXELIB_PATH

################################################################################
ADD opt/external_interface_cpp_patch /opt/external_interface_cpp_patch
ADD opt/openalsound_cpp_patch /opt/openalsound_cpp_patch 
ADD opt/openalsound_h_patch /opt/openalsound_h_patch
ADD opt/sound_h_patch /opt/sound_h_patch

RUN patch \
        $HAXELIB_PATH/lime/lime/legacy/project/src/common/ExternalInterface.cpp \
        /opt/external_interface_cpp_patch 
RUN patch \
        $HAXELIB_PATH/lime/lime/legacy/project/src/openal/OpenALSound.cpp \
        /opt/openalsound_cpp_patch 
RUN patch \
        $HAXELIB_PATH/lime/lime/legacy/project/src/openal/OpenALSound.h \
        /opt/openalsound_h_patch 
RUN patch \
        $HAXELIB_PATH/lime/lime/legacy/project/include/Sound.h \
        /opt/sound_h_patch 

RUN haxelib run lime rebuild tools -v -clean
RUN haxelib run lime rebuild linux -64 -v -Dlegacy -clean -release
RUN haxelib run lime rebuild android -Dlegacy -v -release -clean

RUN rm -r $HAXELIB_PATH/lime/lime/project/obj

################################################################################

CMD ["/bin/bash"]
