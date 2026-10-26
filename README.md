# Sieve of Eratosthenes: Python and CUDA

Educational CPU/GPU comparison maintained by Mateusz Sury. The historical
repository name is retained for existing links.

* `sito_sekwencyjne/main.py`: sequential Python reference (small input by default).
* `sito_cuda/kernel.cu`: CUDA sieve and elapsed-time measurement.

## Run

```sh
python sito_sekwencyjne/main.py
cmake -S . -B build
cmake --build build --parallel
./build/sieve_cuda 1000000
```

The CUDA build requires CMake 3.18+, a compatible NVIDIA CUDA toolkit, C++17 and
an NVIDIA GPU. Windows executable paths may differ. CI validates the Python
reference and compiles the CUDA program; it does not claim GPU execution. Compare the prime sum against the CPU
reference before using larger limits. Record GPU, driver, toolkit, range and
whether transfer time is included when publishing benchmarks.

Source code is MIT licensed. There is no established release/performance promise.
