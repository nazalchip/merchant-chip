import numpy as np

class SparseScheduler:
    def __init__(self, verbose=True):
        self.verbose = verbose

    def schedule(self, weights):
        weights = np.array(weights, dtype=np.int8)
        original_shape = weights.shape
        if weights.ndim == 1:
            weights_2d = weights.reshape(32, 32)
        else:
            weights_2d = weights.reshape(-1, 32)[:32]
        rows = weights_2d.shape[0]
        density = np.array([np.sum(weights_2d[r] != 0) for r in range(rows)])
        schedule_map = np.argsort(-density)
        reordered = weights_2d[schedule_map]
        if self.verbose:
            total_nonzero = np.sum(density)
            sparsity = (1 - total_nonzero / (rows * 32)) * 100
            print(f"  [SCHEDULER] Sparsity: {sparsity:.1f}%")
            print(f"  [SCHEDULER] Dense rows scheduled first")
        if weights.ndim == 1:
            return reordered.flatten(), schedule_map
        else:
            return reordered, schedule_map

    def analyse(self, weights):
        weights = np.array(weights, dtype=np.int8).reshape(32, 32)
        total = 32 * 32
        zeros = np.sum(weights == 0)
        sparsity = zeros / total * 100
        print(f"  Total weights  : {total}")
        print(f"  Zero weights   : {zeros} ({sparsity:.1f}%)")
        print(f"  Non-zero       : {total-zeros} ({100-sparsity:.1f}%)")
        return {"total": total, "zeros": int(zeros), "sparsity": float(sparsity)}
