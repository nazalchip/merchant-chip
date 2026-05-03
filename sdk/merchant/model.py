import numpy as np

class Model:
    def __init__(self):
        self.weights  = np.zeros(256, dtype=np.int8)
        self.biases   = np.zeros(16,  dtype=np.int32)
        self.name     = "unnamed"

    @classmethod
    def from_weights(cls, weights, biases=None, name="model"):
        m = cls()
        m.weights = np.array(weights, dtype=np.int8).flatten()
        if biases is not None:
            m.biases = np.array(biases, dtype=np.int32)
        m.name = name
        return m

    def summary(self):
        print(f"\n  Model: {self.name}")
        print(f"  Weights: {len(self.weights)} INT8 values")
        print(f"  Range: [{self.weights.min()}, {self.weights.max()}]\n")
