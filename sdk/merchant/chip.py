import numpy as np

class Chip:
    NUM_MACS    = 256
    NUM_ROWS    = 16
    NUM_COLS    = 16
    NUM_WEIGHTS = 256
    NUM_OUTPUTS = 16

    def __init__(self):
        self._weights    = np.zeros(256, dtype=np.int8)
        self._inputs     = np.zeros(16,  dtype=np.int8)
        self._biases     = np.zeros(16,  dtype=np.int32)
        self._outputs    = np.zeros(16,  dtype=np.int8)
        self._skip_count = 0
        self._done       = False
        print("╔══════════════════════════════════════╗")
        print("║   MERCHANT Chip SDK v0.1.0           ║")
        print("║   256 MACs | 16x16 Systolic Array    ║")
        print("║   Simulation mode — laptop ready     ║")
        print("╚══════════════════════════════════════╝")

    def load_weights(self, weights):
        weights = np.array(weights, dtype=np.int8).flatten()
        if len(weights) != 256:
            raise ValueError(f"Need 256 weights, got {len(weights)}")
        self._weights = weights.copy()
        print(f"[MERCHANT] Loaded {len(weights)} weights")
        return self

    def load_inputs(self, inputs):
        inputs = np.array(inputs, dtype=np.int8).flatten()
        if len(inputs) != 16:
            raise ValueError(f"Need 16 inputs, got {len(inputs)}")
        self._inputs = inputs.copy()
        return self

    def load_biases(self, biases):
        self._biases = np.array(biases, dtype=np.int32).flatten()
        return self

    def infer(self, inputs=None, weights=None):
        if weights is not None:
            self.load_weights(weights)
        if inputs is not None:
            self.load_inputs(inputs)
        W = self._weights.reshape(16, 16).astype(np.int32)
        x = self._inputs.astype(np.int32)
        result = np.zeros(16, dtype=np.int32)
        skip_count = 0
        for row in range(16):
            acc = int(self._biases[row])
            for col in range(16):
                w = int(W[row, col])
                if w == 0:
                    skip_count += 1
                    continue
                acc += w * int(x[col])
            acc = max(0, acc)
            acc = max(-128, min(127, acc))
            result[row] = acc
        self._skip_count = skip_count
        self._outputs    = result.astype(np.int8)
        self._done       = True
        print(f"[MERCHANT] Inference complete — {skip_count} ops skipped")
        return self._outputs.copy()

    def print_outputs(self):
        print("\n  MERCHANT outputs:")
        for i, val in enumerate(self._outputs):
            bar = "█" * max(0, int(val) // 8)
            print(f"  channel[{i:2d}] = {val:5d}  {bar}")
        print()

    def status(self):
        print(f"\n  Mode: simulation | MACs: {self.NUM_MACS} | Done: {self._done} | Skips: {self._skip_count}\n")

    @property
    def skip_count(self):
        return self._skip_count
