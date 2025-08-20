FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS builder

RUN mkdir /workspace
WORKDIR /workspace

# Install dependencies
RUN --mount=target=/var/lib/apt/lists,type=cache,id=apt-lists \
    --mount=target=/var/cache/apt,type=cache,id=apt-cache \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt update && \
    apt install -y wget software-properties-common lsb-release git python3 python3-venv python3-pip

# Install LLVM/Clang 20
RUN --mount=target=/var/lib/apt/lists,type=cache,id=apt-lists \
    --mount=target=/var/cache/apt,type=cache,id=apt-cache \
    wget -O llvm.sh https://apt.llvm.org/llvm.sh && \
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
RUN --mount=type=cache,target=/root/.cache/bazel,id=bazel-cache \
    bazel build //tensorflow/tools/pip_package:wheel --repo_env=USE_PYWRAP_RULES=1 --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel && \
    cp /workspace/tensorflow/bazel-bin/tensorflow/tools/pip_package/wheel_house/*.whl /workspace

# Set up Python virtual environment and install built wheel
WORKDIR /workspace
RUN --mount=target=/root/.cache/pip,type=cache,id=pip-global-cache \
    python3 -m venv venv && \
    . venv/bin/activate && \
    pip install *.whl

ENV VIRTUAL_ENV=/workspace/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# docker buildx build -t wutzebaer/tensorflow-5090 .
# docker push wutzebaer/tensorflow-5090