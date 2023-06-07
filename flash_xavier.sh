#!/bin/bash

docker run -it --rm --privileged \
    -v /home/fandavid/Desktop/jetson_sdk_manager/:/jetson_sdk_manager \
    -v /home/fandavid/Desktop/jetson_image/:/jetson_image \
    -v /dev/bus/usb:/dev/bus/usb \
    sdkmanager:1.8.1.10392-Ubuntu_20.04 \
    --cli install \
    --logintype devzone \
    --product Jetson \
    --version 5.0.2 \
    --targetos Linux \
    --host \
    --target JETSON_AGX_XAVIER_TARGETS \
    --flash all \
    --additionalsdk DeepStream \
    --license accept \
    --staylogin true \
    --exitonfinish \
    --targetimagefolder /jetson_image \
    --downloadfolder /jetson_sdk_manager
