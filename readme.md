# TensorFlow CUDA 12.8 Build Environment for RTX 5090

This project provides a Docker-based environment for building TensorFlow from source with CUDA 12.8 and cuDNN support on Ubuntu 24.04. It automates the setup, build, and installation of a custom TensorFlow wheel with GPU acceleration.

## Features

- Builds TensorFlow from source using Bazel and Clang 20
- CUDA 12.8.1 and cuDNN 9.8 support
- Python 3 virtual environment with the built TensorFlow wheel installed
- Reproducible environment using Docker

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (with NVIDIA Container Toolkit for GPU support)
- NVIDIA GPU with compatible drivers

## Quick Start

### Build the Docker Image

```sh
docker build --progress=plain .
```

### Run the Container with GPU Access

```sh
docker run -it --rm --gpus all $(docker build -q .)
```

This will drop you into a shell inside the container, with TensorFlow built and installed in a Python virtual environment at `/workspace/venv`.

### Verify the Installation

Activate the virtual environment and test TensorFlow:

```sh
source /workspace/venv/bin/activate
python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```

You can also check CUDA and GPU status:

```sh
nvcc --version
nvidia-smi
```

## Project Structure

- `Dockerfile`: Defines the build environment and steps to build/install TensorFlow.
- `.tf_configure.bazelrc`: Bazel build configuration for CUDA, cuDNN, and Clang.
- `readme.md`: Project documentation and usage instructions.

## Customization

- To change the TensorFlow version, modify the `git clone` step in the Dockerfile.
- To adjust CUDA/cuDNN versions, update the base image and Bazel config.

## References

- [TensorFlow Build from Source Guide](https://www.tensorflow.org/install/source)
- [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)
- [Bazel Build System](https://bazel.build/)

---

### Utility Commands

```
docker run -it --rm --gpus all $(docker build -q .)
docker build --progress=plain .
nvcc --version
nvidia-smi
python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```
