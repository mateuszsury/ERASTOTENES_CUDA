"""Inclusive CPU reference for the CUDA sieve."""
import argparse
from math import isqrt
from time import perf_counter

def sito(n):
    if n < 2:
        return []
    flags = bytearray(b'\x01') * (n + 1)
    flags[0:2] = b'\x00\x00'
    for prime in range(2, isqrt(n) + 1):
        if flags[prime]:
            for multiple in range(prime * prime, n + 1, prime):
                flags[multiple] = 0
    return [i for i in range(2, n + 1) if flags[i]]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--limit', type=int, default=10)
    args = parser.parse_args()
    if not 0 <= args.limit <= 1000000000:
        parser.error('--limit must be between 0 and 1000000000')
    start = perf_counter()
    primes = sito(args.limit)
    print('Count:', len(primes), 'Sum:', sum(primes))
    print('CPU seconds:', perf_counter() - start)

if __name__ == '__main__':
    main()
