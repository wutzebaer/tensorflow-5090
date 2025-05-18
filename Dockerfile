# https://docs.nvidia.com/deeplearning/frameworks/tensorflow-release-notes/rel-25-02.html
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

RUN apt update && apt install -y wget git software-properties-common lsb-release




RUN mkdir /workspace
WORKDIR /workspace

RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 20 all
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-20 100

RUN git clone https://github.com/tensorflow/tensorflow.git
WORKDIR /workspace/tensorflow
# RUN git remote add maludwig http://github.com/maludwig/tensorflow.git
# RUN git fetch --all
# RUN git checkout ml/attempting_build_rtx5090
# RUN git pull maludwig ml/attempting_build_rtx5090

RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64 -O /usr/bin/bazel
RUN chmod +x /usr/bin/bazel
RUN bazel version

COPY .tf_configure.bazelrc .

# ENV HERMETIC_CUDA_VERSION=12.8.1
# ENV HERMETIC_CUDNN_VERSION=9.8.0
# ENV HERMETIC_CUDA_COMPUTE_CAPABILITIES=compute_120
# ENV LOCAL_CUDA_PATH=/usr/local/cuda-12.8
# ENV LOCAL_NCCL_PATH=/usr/lib/x86_64-linux-gnu/libnccl.so.2.25.1
# ENV TF_NEED_CUDA=1   
# ENV CLANG_CUDA_COMPILER_PATH=/usr/bin/clang
# ENV CUDA_TOOLKIT_PATH=/usr/local/cuda-12.8
# COPY .tf_configure.bazelrc .
# RUN python configure.py



RUN bazel build //tensorflow/tools/pip_package:wheel --repo_env=USE_PYWRAP_RULES=1 --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel
# RUN pip install bazel-bin/tensorflow/tools/pip_package/wheel_house/tensorflow-version-tags.whl


# RUN bazel build //tensorflow/tools/pip_package:wheel --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel --copt=-Wno-gnu-offsetof-extensions --copt=-Wno-error --copt=-Wno-c23-extensions --verbose_failures --copt=-Wno-macro-redefined
# RUN bazel build //tensorflow/tools/pip_package:wheel --repo_env=USE_PYWRAP_RULES=1 --repo_env=WHEEL_NAME=tensorflow --config=cuda --config=cuda_wheel --define=with_xla_support=false



# RUN python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
# docker run -it --rm --gpus all $(docker build -q .)
# docker build --progress=plain .
# nvcc --version
# nvidia-smi
# python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"