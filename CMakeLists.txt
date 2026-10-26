cmake_minimum_required(VERSION 3.18)
project(eratosthenes LANGUAGES CXX CUDA)
add_executable(sieve_cuda sito_cuda/kernel.cu)
set_target_properties(sieve_cuda PROPERTIES CXX_STANDARD 17 CUDA_STANDARD 17)
