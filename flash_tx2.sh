#!/bin/bash

docker run -it --rm --privileged \
    -v /home/fandavid/Desktop/jetson_sdk_manager/:/jetson_sdk_manager \
    -v /home/fandavid/Desktop/jetson_image/:/jetson_image \
    -v /dev/bus/usb:/dev/bus/usb \
    sdkmanager \
    --cli install \
    --logintype devzone \
    --product Jetson \
    --version 4.6.2 \
    --targetos Linux \
    --host \
    --target JETSON_TX2_TARGETS \
    --flash all \
    --additionalsdk DeepStream \
    --license accept \
    --staylogin true \
    --exitonfinish \
    --targetimagefolder /jetson_image \
    --downloadfolder /jetson_sdk_manager
