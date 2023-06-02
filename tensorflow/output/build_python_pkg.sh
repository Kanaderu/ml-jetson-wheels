#!/bin/bash

cd tensorflow/

# compile
bazel build \
             --config=opt \
             --config=noaws \
             --config=nogcp \
             --config=nohdfs \
             --config=nonccl \
             --config=monolithic \
             --config=cuda \
             --config=v2 \
             --local_cpu_resources=HOST_CPUS*.9 \
             --local_ram_resources=HOST_RAM*.9 \
             --define=tflite_pip_with_flex=true \
             --copt=-ftree-vectorize \
             --copt=-funsafe-math-optimizations \
             --copt=-ftree-loop-vectorize \
             --copt=-fomit-frame-pointer \
             //tensorflow/tools/pip_package:build_pip_package

# build wheel
bazel-bin/tensorflow/tools/pip_package/build_pip_package /output/tensorflow_pkg

# package c library
bazel build \
             --config=opt \
             --config=noaws \
             --config=nogcp \
             --config=nohdfs \
             --config=nonccl \
             --config=monolithic \
             --config=v2 \
             --local_cpu_resources=HOST_CPUS*.9 \
             --local_ram_resources=HOST_RAM*.9 \
             --copt=-ftree-vectorize \
             --copt=-funsafe-math-optimizations \
             --copt=-ftree-loop-vectorize \
             --copt=-fomit-frame-pointer \
             //tensorflow/tools/lib_package:libtensorflow

# move c package
cp bazel-bin/tensorflow/tools/lib_package/libtensorflow.tar.gz  /output/tensorflow_pkg/
