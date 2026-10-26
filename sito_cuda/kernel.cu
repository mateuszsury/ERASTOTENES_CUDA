#include <cuda_runtime.h>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#define CUDA_CHECK(call) do { const cudaError_t status = (call); \
    if (status != cudaSuccess) throw std::runtime_error(cudaGetErrorString(status)); } while (false)

// For one prime, every thread marks a disjoint arithmetic subsequence.
// Kernels for successive base primes run serially in the default stream.
__global__ void mark_composites(unsigned char* flags, std::uint64_t limit, std::uint64_t prime) {
    const std::uint64_t tid = blockIdx.x * static_cast<std::uint64_t>(blockDim.x) + threadIdx.x;
    const std::uint64_t stride = gridDim.x * static_cast<std::uint64_t>(blockDim.x);
    for (std::uint64_t value = prime * prime + tid * prime; value <= limit; value += stride * prime)
        flags[value] = 0;
}

int main(int argc, char** argv) {
    unsigned char* device = nullptr;
    cudaEvent_t start = nullptr, stop = nullptr;
    try {
        std::size_t consumed = 0;
        const std::string text = argc > 1 ? argv[1] : "1000000";
        const std::uint64_t limit = std::stoull(text, &consumed);
        if (argc > 2 || consumed != text.size() || limit < 2 || limit > 1000000000ULL)
            throw std::invalid_argument("Usage: sieve_cuda [inclusive-limit: 2..1000000000]");

        std::vector<unsigned char> flags(limit + 1, 1);
        flags[0] = flags[1] = 0;
        const auto root = static_cast<std::uint64_t>(std::sqrt(static_cast<double>(limit)));
        std::vector<unsigned char> bases(root + 1, 1);
        std::vector<std::uint64_t> primes;
        for (std::uint64_t p = 2; p <= root; ++p) {
            if (!bases[p]) continue;
            primes.push_back(p);
            for (std::uint64_t multiple = p * p; multiple <= root; multiple += p)
                bases[multiple] = 0;
        }

        CUDA_CHECK(cudaMalloc(reinterpret_cast<void**>(&device), flags.size()));
        CUDA_CHECK(cudaMemcpy(device, flags.data(), flags.size(), cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaEventCreate(&start));
        CUDA_CHECK(cudaEventCreate(&stop));
        CUDA_CHECK(cudaEventRecord(start));
        for (auto prime : primes) {
            mark_composites<<<256, 256>>>(device, limit, prime);
            CUDA_CHECK(cudaGetLastError());
        }
        CUDA_CHECK(cudaEventRecord(stop));
        CUDA_CHECK(cudaEventSynchronize(stop));
        CUDA_CHECK(cudaMemcpy(flags.data(), device, flags.size(), cudaMemcpyDeviceToHost));
        float elapsed = 0;
        CUDA_CHECK(cudaEventElapsedTime(&elapsed, start, stop));
        std::uint64_t sum = 0, count = 0;
        for (std::uint64_t i = 2; i <= limit; ++i) {
            if (flags[i]) { sum += i; ++count; }
        }
        std::cout << "Inclusive limit: " << limit << " Count: " << count << " Sum: " << sum
                  << " Kernel milliseconds (excluding transfers): " << elapsed << '\n';
        CUDA_CHECK(cudaFree(device)); device = nullptr;
        CUDA_CHECK(cudaEventDestroy(start)); start = nullptr;
        CUDA_CHECK(cudaEventDestroy(stop)); stop = nullptr;
        return 0;
    } catch (const std::exception& error) {
        if (device) cudaFree(device);
        if (start) cudaEventDestroy(start);
        if (stop) cudaEventDestroy(stop);
        std::cerr << error.what() << '\n';
        return 1;
    }
}
