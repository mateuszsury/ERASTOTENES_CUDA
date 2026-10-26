import unittest
from sito_sekwencyjne.main import sito

class SieveTests(unittest.TestCase):
    def test_small_inclusive_limits(self):
        self.assertEqual(sito(0), [])
        self.assertEqual(sito(1), [])
        self.assertEqual(sito(2), [2])
        self.assertEqual(sito(11), [2,3,5,7,11])

    def test_known_sum(self):
        self.assertEqual(sum(sito(100)), 1060)

if __name__ == '__main__': unittest.main()
