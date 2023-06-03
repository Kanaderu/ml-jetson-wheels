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

# install cmake
ARG CMAKE_VERSION=3.20.3
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar xf cmake-${CMAKE_VERSION}.tar.gz && \
    cd cmake-${CMAKE_VERSION} && ./bootstrap && make -j$(($(nproc)-1)) install && \
    cd / && rm -rf /cmake-${CMAKE_VERSION}.tar.gz /cmake-${CMAKE_VERSION}

# install cuda development environment
RUN apt-get install -y cuda-cupti-dev-10-2 libcudnn8-dev libnvinfer-dev libnvinfer-plugin-dev libcusolver-dev-10-2 libcurand-dev-10-2 libcusparse-dev-10-2 cuda-nvml-dev-10-2 libcufft-dev-10-2

# setup python3.8
RUN unlink $(which python) && ln -s $(which python3.8) /usr/bin/python && \
    unlink $(which python3) && ln -s $(which python3.8) /usr/bin/python3 && \
    curl https://bootstrap.pypa.io/get-pip.py | python3.8 && \
    pip install setuptools wheel

# install additional pytorch dependencies
RUN apt-get install -y ninja-build clang-8 \
    libjpeg-dev libopenmpi-dev libomp-dev ccache

# install pytorch python package dependencies
RUN pip install wheel mock pillow testresources setuptools==58.3.0 scikit-build

# download pytorch
WORKDIR /app
ARG PYTORCH_VERSION=1.13.0
#RUN wget https://github.com/pytorch/pytorch/archive/refs/tags/v${PYTORCH_VERSION}.tar.gz && tar xf v${PYTORCH_VERSION}.tar.gz && rm v${PYTORCH_VERSION}.tar.gz  && mv pytorch-${PYTORCH_VERSION} pytorch
RUN git clone -b v${PYTORCH_VERSION} --depth=1 --recursive https://github.com/pytorch/pytorch.git

RUN pip install -r pytorch/requirements.txt

# download torchvision
# check compatability matrix: https://github.com/pytorch/pytorch/wiki/PyTorch-Versions
ARG PYTORCH_VISION_VERSION=0.14.0
RUN git clone -b v${PYTORCH_VISION_VERSION} --depth=1 --recursive https://github.com/pytorch/vision.git

# update default clang6 to clang8
RUN unlink /usr/bin/clang && unlink /usr/bin/clang++ && \
    ln -s /usr/bin/clang-8 /usr/bin/clang && \
    ln -s /usr/bin/clang++-8 /usr/bin/clang++

WORKDIR /app/pytorch

# jetson nano mods
RUN sed -i '34i #if defined(__clang__) ||(__GNUC__ > 8 || (__GNUC__ == 8 && __GNUC_MINOR__ > 3))' aten/src/ATen/cpu/vec/vec256/vec256_float_neon.h && \
    sed -i '831i #endif //defined(__clang__)' aten/src/ATen/cpu/vec/vec256/vec256_float_neon.h && \
    sed -i '27i device_prop.maxThreadsPerBlock = device_prop.maxThreadsPerBlock / 2;' aten/src/ATen/cuda/CUDAContext.cpp && \
    sed -i 's/constexpr int CUDA_NUM_THREADS = 1024/constexpr int CUDA_NUM_THREADS = 512/g' aten/src/ATen/cuda/detail/KernelUtils.h

ENV BUILD_CAFFE2_OPS=OFF
ENV USE_FBGEMM=OFF
ENV USE_FAKELOWP=OFF
ENV BUILD_TEST=OFF
ENV USE_MKLDNN=OFF
ENV USE_NNPACK=OFF
ENV USE_XNNPACK=OFF
ENV USE_QNNPACK=OFF
ENV USE_PYTORCH_QNNPACK=OFF
ENV USE_CUDA=ON
ENV USE_CUDNN=ON
ENV TORCH_CUDA_ARCH_LIST=5.3;6.2;7.2
ENV USE_NCCL=OFF
ENV USE_SYSTEM_NCCL=OFF
ENV USE_OPENCV=OFF
ENV MAX_JOBS=4
# set path to ccache
ENV PATH=/usr/lib/ccache:$PATH
# set clang compiler
ENV CC=clang
ENV CXX=clang++
# set cuda compiler
ENV CUDACXX=/usr/local/cuda/bin/nvcc

# build python wheel
RUN python3 setup.py bdist_wheel

# install built torch wheel for torchvision
RUN pip install dist/*.whl
WORKDIR /app/vision
RUN python setup.py bdist_wheel

CMD cp /app/torch/dist/*.whl /app/vision/dist/*.whl /output
