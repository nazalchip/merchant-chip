import numpy as np
from .model import Model

def compile_weights(weights, biases=None, name="model", output_path=None):
    print(f"\n[MERCHANT COMPILER] Compiling: {name}")
    model = Model.from_weights(weights, biases, name)
    zero_count = np.sum(model.weights == 0)
    sparsity   = zero_count / 256 * 100
    print(f"[MERCHANT COMPILER] Sparsity: {sparsity:.1f}% — {zero_count} zeros")
    print(f"[MERCHANT COMPILER] Done\n")
    return model
