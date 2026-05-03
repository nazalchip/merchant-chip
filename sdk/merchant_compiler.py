import numpy as np
import os, sys, struct, argparse
from pathlib import Path

MERCHANT_ROWS = 16
MERCHANT_COLS = 16
MERCHANT_FILE_MAGIC = b"MRCH"
MERCHANT_VERSION = 1

class Quantizer:
    def __init__(self):
        self.scale = 1.0
    def quantize(self, w):
        w = np.array(w, dtype=np.float32)
        max_val = np.max(np.abs(w))
        if max_val == 0:
            return np.zeros_like(w, dtype=np.int8)
        self.scale = max_val / 127.0
        q = np.clip(np.round(w / self.scale), -128, 127)
        print(f"  [QUANTIZER] Scale: {self.scale:.6f} | INT8 range: [{q.min():.0f}, {q.max():.0f}]")
        return q.astype(np.int8)

class WeightMapper:
    def map_weights(self, weights, name="layer"):
        w = np.array(weights)
        if w.ndim == 1:
            w = w.reshape(1, -1)
        elif w.ndim > 2:
            w = w.reshape(w.shape[0], -1)
        mapped = np.zeros((16, 16), dtype=np.float32)
        r = min(w.shape[0], 16)
        c = min(w.shape[1], 16)
        mapped[:r, :c] = w[:r, :c]
        print(f"  [MAPPER] {name}: {w.shape} → using {r}x{c} of 16x16 ({r*c/256*100:.1f}% utilised)")
        return mapped.flatten().astype(np.float32)

class MerchantFileWriter:
    def write(self, filepath, layers, model_name="model"):
        with open(filepath, "wb") as f:
            f.write(MERCHANT_FILE_MAGIC)
            f.write(struct.pack("<I", MERCHANT_VERSION))
            f.write(struct.pack("<I", len(layers)))
            nb = model_name.encode("utf-8")
            f.write(struct.pack("<I", len(nb)))
            f.write(nb)
            for layer in layers:
                f.write(struct.pack("<I", layer["type"]))
                f.write(struct.pack("<f", layer["scale"]))
                w = layer["weights"].flatten()[:256]
                if len(w) < 256:
                    w = np.pad(w, (0, 256-len(w)))
                f.write(w.astype(np.int8).tobytes())
                b = layer["biases"].flatten()[:16]
                if len(b) < 16:
                    b = np.pad(b, (0, 16-len(b)))
                f.write(b.astype(np.int32).tobytes())
        print(f"  [WRITER] Saved: {filepath} ({os.path.getsize(filepath)} bytes)")

class MerchantFileReader:
    def read(self, filepath):
        with open(filepath, "rb") as f:
            magic = f.read(4)
            if magic != MERCHANT_FILE_MAGIC:
                raise ValueError("Not a valid .merchant file")
            f.read(4); num_layers = struct.unpack("<I", f.read(4))[0]
            name_len = struct.unpack("<I", f.read(4))[0]
            model_name = f.read(name_len).decode("utf-8")
            layers = []
            for _ in range(num_layers):
                lt = struct.unpack("<I", f.read(4))[0]
                sc = struct.unpack("<f", f.read(4))[0]
                w  = np.frombuffer(f.read(256), dtype=np.int8).copy()
                b  = np.frombuffer(f.read(64),  dtype=np.int32).copy()
                layers.append({"type":lt,"scale":sc,"weights":w,"biases":b})
        return {"name": model_name, "layers": layers}

class MerchantCompiler:
    def __init__(self):
        self.quantizer = Quantizer()
        self.mapper    = WeightMapper()
        self.writer    = MerchantFileWriter()
        self.reader    = MerchantFileReader()

    def compile_array(self, weights, output_path, model_name="model", biases=None):
        print(f"\n{'='*52}\n  MERCHANT COMPILER v1\n  Compiling: {model_name}\n{'='*52}")
        mapped = self.mapper.map_weights(weights, model_name)
        if np.array(weights).dtype in [np.float32, np.float64]:
            q_weights = self.quantizer.quantize(mapped)
            scale = float(self.quantizer.scale)
        else:
            q_weights = mapped.astype(np.int8)
            scale = 1.0
        q_biases = np.zeros(16, dtype=np.int32) if biases is None else np.array(biases, dtype=np.int32).flatten()[:16]
        layers = [{"type":0,"scale":scale,"weights":q_weights,"biases":q_biases}]
        self.writer.write(output_path, layers, model_name)
        sparsity = np.sum(q_weights == 0) / 256 * 100
        print(f"\n  Sparsity: {sparsity:.1f}% | Output: {output_path}\n")
        return {"model_name":model_name,"num_layers":1,"total_weights":256,"sparsity":sparsity,"output_file":output_path}

    def load(self, path):
        data = self.reader.read(path)
        print(f"  [COMPILER] Loaded: {data['name']} ({len(data['layers'])} layers)")
        return data
