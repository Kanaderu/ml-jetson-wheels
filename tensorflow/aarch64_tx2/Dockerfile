FROM nvcr.io/nvidia/l4t-cuda:10.2.460-runtime

# setup Jetson nvidia repo sources
ARG SOC=t186
ADD --chown=root:root https://repo.download.nvidia.com/jetson/jetson-ota-public.asc /etc/apt/trusted.gpg.d/jetson-ota-public.asc
RUN chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc && \
    echo "deb https://repo.download.nvidia.com/jetson/common r32.7 main" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://repo.download.nvidia.com/jetson/${SOC} r32.7 main" >> /etc/apt/sources.list.d/cuda.list
# install dependencies
RUN apt-get update -y && apt-get -y install \
    python3.8-dev build-essential git clang zip unzip curl make wget \
    libssl-dev \
    openjdk-11-jdk \
    libhdf5-dev libc-ares-dev libeigen3-dev \
    libatlas-base-dev libopenblas-dev libblas-dev \
    gfortran liblapack-dev

# install cuda development environment
RUN apt-get install -y cuda-cupti-dev-10-2 libcudnn8-dev libnvinfer-dev libnvinfer-plugin-dev

# install cmake
ARG CMAKE_VERSION=3.20.3
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar xf cmake-${CMAKE_VERSION}.tar.gz && \
    cd cmake-${CMAKE_VERSION} && ./bootstrap && make -j$(($(nproc)-1)) install && \
    cd / && rm -rf /cmake-${CMAKE_VERSION}.tar.gz /cmake-${CMAKE_VERSION}

# setup python3.8
RUN unlink $(which python) && ln -s $(which python3.8) /usr/bin/python && \
    unlink $(which python3) && ln -s $(which python3.8) /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py | python3.8 && \
    pip install setuptools wheel

# install tensorflow python package dependencies
RUN pip install keras_preprocessing keras_applications --no-deps && \
    pip install pybind11 h5py

# install bazel
ARG BAZEL_VERSION=3.7.2
RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-arm64 && mv bazel-${BAZEL_VERSION}-linux-arm64 /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel

# download tensorflow
WORKDIR /app
ARG TENSORFLOW_VERSION=2.6.5
RUN wget https://github.com/tensorflow/tensorflow/archive/refs/tags/v${TENSORFLOW_VERSION}.tar.gz && tar xf v${TENSORFLOW_VERSION}.tar.gz && rm v${TENSORFLOW_VERSION}.tar.gz && mv tensorflow-${TENSORFLOW_VERSION} tensorflow

WORKDIR /app/tensorflow

# setup python targets
ENV PYTHON_BIN_PATH=/usr/bin/python3.8
ENV PYTHON_LIB_PATH=/usr/local/lib/python3.8/dist-packages

# install pip dependencies
RUN /app/tensorflow/tensorflow/tools/ci_build/install/install_pip_packages_by_version.sh `which pip`

# setup build configuration for tensorflow version
ENV TF_NEED_OPENCL=0
ENV TF_NEED_ROCM=0
ENV TF_NEED_CUDA=1
ENV TF_NEED_TENSORRT=0
ENV TF_CUDNN_VERSION=8
ENV TF_TENSORRT_VERSION=8
ENV TF_CUDA_CLANG=0
# compute capability:
# Tegra X1, Jetson TX1, Jetson Nano: 5.3
# Jetson TX2: 6.2
# Jetson Xavier 7.2
ENV TF_CUDA_COMPUTE_CAPABILITIES=5.3,6.2,7.2
ENV TF_DOWNLOAD_CLANG=0
#ENV CLANG_CUDA_COMPILER_PATH=/usr/bin/clang-10
ENV TF_SET_ANDROID_WORKSPACE=0

## configure tensorflow
#RUN ./configure

ENV TMP=/tmp
