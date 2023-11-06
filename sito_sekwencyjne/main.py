import time
t1 = time.time()
def sito(n):
    numbers = [True for _ in range (n)]
    pierwsze = []
    for i in range(len(numbers)):
        if i <= 1:
            numbers[i] = False
        else:
            if numbers[i]:
                pierwsze.append(i)
                for j in range(i, len(numbers), i):
                    numbers[j] = False
    return pierwsze

liczby_pierwsze = sito(10)
suma_liczb_pierwszych = sum(liczby_pierwsze)
print(liczby_pierwsze)
print(suma_liczb_pierwszych)
t2 = time.time()

taken_time = t2-t1
print(taken_time)

#24739512092254535