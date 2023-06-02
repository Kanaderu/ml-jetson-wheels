#!/bin/bash

# downgrade pip
pip install protobuf==3.20.0

# copy setup to mounted space
cp -r /app/tensorflow /output
cd /output/tensorflow
./configure
