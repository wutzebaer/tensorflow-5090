### Utility commands

```
docker run -it --rm --gpus all $(docker build -q .)
docker build --progress=plain .
nvcc --version
nvidia-smi
python -c "import tensorflow as tf; print(tf.reduce_sum(tf.random.normal([1000, 1000])))"
```
