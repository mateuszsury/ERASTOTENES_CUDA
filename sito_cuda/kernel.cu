#include <iostream>
#include <cuda_runtime.h>

__global__ void sieve(long long* numbers, long long n, int blockSize, int numChunks) {
    int chunkId = blockIdx.x; // Identyfikator bloku w wymiarze X
    int threadId = threadIdx.x; // Identyfikator watku w wymiarze X
    long long start = chunkId * blockSize + threadId + 2; // Początkowy indeks przetwarzany przez wątek w danym bloku
    long long step = numChunks * blockSize; // Odstęp między liczbami przetwarzanymi przez dwa kolejne wątki

    for (long long index = start; index <= n; index += step) {
        if (numbers[index] != 0) {
            for (long long i = 2 * index; i <= n; i += index) {
                numbers[i] = 0;
            }
        }
    }
}

int main() {
    long long n = 1000000000;  // Liczba pierwszych do obliczenia
    int blockSize = 256;  // Rozmiar bloku wątków CUDA
    int numChunks = 8;  // Liczba fragmentów do równoczesnego przetwarzania
    int numBlocks = numChunks;
    long long* h_numbers = new long long[n + 1];  // Tablica na CPU do algorytmu sita

    // Inicjalizacja tablicy na CPU
    for (long long i = 2; i <= n; i++) {
        h_numbers[i] = i;
    }

    // Inicjalizacja timerów CUDA
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // Rozpoczęcie pomiaru czasu
    cudaEventRecord(start);

    // Alokuje pamięć na GPU
    long long* d_numbers;
    cudaMalloc((void**)&d_numbers, (n + 1) * sizeof(long long));

    // Kopiuje dane z CPU do GPU
    cudaMemcpy(d_numbers, h_numbers, (n + 1) * sizeof(long long), cudaMemcpyHostToDevice);

    // Uruchamia kernel CUDA z wieloma blokami
    sieve << <numBlocks, blockSize >> > (d_numbers, n, blockSize, numChunks);



    // Kopiuje wyniki z GPU na CPU
    cudaMemcpy(h_numbers, d_numbers, (n + 1) * sizeof(long long), cudaMemcpyDeviceToHost);

    // Zakończenie pomiaru czasu
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    // Oblicza sumę liczb pierwszych
    long long sum = 0;

    std::cout << "Liczby pierwsze: ";
    for (long long i = 2; i <= n; i++) {
        if (h_numbers[i] != 0) {
            sum += h_numbers[i];
            //std::cout << h_numbers[i] << " ";
        }
    }
    std::cout << std::endl;

    std::cout << "Suma " << n << " liczb pierwszych: " << sum << std::endl;

    // Obliczanie czasu trwania
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    std::cout << "Czas obliczen na GPU: " << milliseconds << " ms" << std::endl;

    // Zwolnienie pamięci i timerów
    delete[] h_numbers;
    cudaFree(d_numbers);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}
