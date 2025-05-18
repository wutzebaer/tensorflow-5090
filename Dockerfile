FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

RUN apt update && \
    apt install -y libpq-dev wget software-properties-common lsb-release git python3 python3-venv python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /workspace
WORKDIR /workspace

# Install LLVM/Clang 20
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 20 all && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100 && \
    rm llvm.sh

# Clone TensorFlow
RUN git clone https://github.com/tensorflow/tensorflow.git
WORKDIR /workspace/tensorflow

# Install Bazelisk (Bazel wrapper)
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64 -O /usr/bin/bazel && \
    chmod +x /usr/bin/bazel && \
    bazel version

# Copy Bazel config
COPY .tf_configure.bazelrc .

# Build TensorFlow wheel
RUN bazel build //tensorflow/tools/pip_package:wheel --repo_env=USE_PYWRAP_RULES=1 --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel

# Set up Python virtual environment and install built wheel
WORKDIR /workspace
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install tensorflow/bazel-bin/tensorflow/tools/pip_package/wheel_house/tensorflow-2.20.0.dev0+selfbuilt-cp312-cp312-linux_x86_64.whl

ENV VIRTUAL_ENV=/workspace/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
