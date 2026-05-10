# ═══════════════════════════════════════════════════════
#  MERCHANT — Full Pipeline Demo
#  demo_onnx.py
#
#  Shows complete flow:
#  1. Load ONNX model
#  2. Compile to .merchant format
#  3. Run inference on MERCHANT chip simulator
#  4. Show results
# ═══════════════════════════════════════════════════════

import numpy as np
import struct
import os
from onnx_compiler import compile_onnx

def load_merchant_file(merchant_path):
    """Load a compiled .merchant file"""
    layers = []
    with open(merchant_path, 'rb') as f:
        magic = f.read(4)
        version = struct.unpack('B', f.read(1))[0]
        num_layers = struct.unpack('I', f.read(4))[0]
        model_name = f.read(64).decode('utf-8').rstrip('\x00')

        for i in range(num_layers):
            layer_type = struct.unpack('B', f.read(1))[0]
            name = f.read(32).decode('utf-8').rstrip('\x00')
            scale = struct.unpack('f', f.read(4))[0]
            sparsity = struct.unpack('f', f.read(4))[0]
            weights = np.frombuffer(f.read(1024), dtype=np.int8).copy()
            bias = np.frombuffer(f.read(128), dtype=np.int32).copy()

            layers.append({
                'name': name,
                'type': layer_type,
                'scale': scale,
                'sparsity': sparsity,
                'weights': weights.reshape(32, 32),
                'bias': bias
            })

    return model_name, layers

def simulate_inference(layers, input_data):
    """
    Simulate MERCHANT chip inference
    Uses same logic as the chip hardware:
    - Load weights into MAC array
    - Apply activations
    - Zero-skip optimization
    - Accumulate results
    - Apply ReLU
    """
    print(f"\n  Running inference on MERCHANT simulator...")
    print(f"  Input shape: {input_data.shape}")

    # quantize input to INT8
    max_val = np.max(np.abs(input_data))
    if max_val > 0:
        act = np.clip(input_data / max_val * 127, -128, 127).astype(np.int8)
    else:
        act = np.zeros(32, dtype=np.int8)

    # pad or truncate to 32 values
    act_flat = act.flatten()
    if len(act_flat) >= 32:
        activations = act_flat[:32]
    else:
        activations = np.pad(act_flat, (0, 32 - len(act_flat)))

    total_ops = 0
    total_skips = 0

    # run through each layer
    for i, layer in enumerate(layers[:5]):  # first 5 layers for demo
        weights = layer['weights']  # 32x32
        bias = layer['bias'][:32]

        # simulate MAC array — same as your Verilog
        output = np.zeros(32, dtype=np.int32)
        layer_ops = 0
        layer_skips = 0

        for row in range(32):
            acc = 0
            for col in range(32):
                w = int(weights[row, col])
                a = int(activations[col % len(activations)])

                # zero-skip — same as mac_unit_v6.v
                if w == 0 or a == 0:
                    layer_skips += 1
                    continue

                acc += w * a
                layer_ops += 1

            output[row] = acc + int(bias[row])

        total_ops += layer_ops
        total_skips += layer_skips

        # ReLU
        output = np.maximum(output, 0)

        # scale back to INT8 for next layer
        max_out = np.max(np.abs(output))
        if max_out > 0:
            activations = np.clip(output / max_out * 127,
                                  -128, 127).astype(np.int8)
        else:
            activations = np.zeros(32, dtype=np.int8)

    skip_rate = total_skips / (total_ops + total_skips) * 100

    print(f"  Layers processed : 5 of {len(layers)}")
    print(f"  MAC operations   : {total_ops:,}")
    print(f"  Zero skips       : {total_skips:,} ({skip_rate:.1f}% saved)")
    print(f"  Output sample    : {activations[:8]}")

    return activations

def main():
    print("\n" + "="*50)
    print("  MERCHANT Full Pipeline Demo")
    print("="*50)

    # step 1 — compile ONNX model
    onnx_path = "mobilenetv2.onnx"
    merchant_path = "mobilenetv2.merchant"

    if not os.path.exists(merchant_path):
        print("\nStep 1: Compiling ONNX model...")
        compile_onnx(onnx_path, merchant_path)
    else:
        print(f"\nStep 1: Using existing {merchant_path}")

    # step 2 — load compiled model
    print("\nStep 2: Loading compiled model...")
    model_name, layers = load_merchant_file(merchant_path)
    print(f"  Model: {model_name}")
    print(f"  Layers: {len(layers)}")

    # print layer summary
    print(f"\n  Layer summary (first 5):")
    for i, layer in enumerate(layers[:5]):
        print(f"  {i+1}. {layer['name']:20s} "
              f"sparsity={layer['sparsity']:.0f}%")

    # step 3 — simulate inference
    print("\nStep 3: Running inference...")

    # create fake camera input — 32 pixel values
    # in real use this would be a camera frame
    np.random.seed(42)
    camera_input = np.random.randint(0, 255, 32).astype(np.float32)
    camera_input = camera_input / 255.0  # normalise to 0-1

    result = simulate_inference(layers, camera_input)

    # step 4 — interpret result
    print("\nStep 4: Result interpretation...")
    max_idx = np.argmax(result)
    confidence = int(result[max_idx])

    print(f"  Top prediction channel : {max_idx}")
    print(f"  Confidence score       : {confidence}")
    print(f"  Output vector          : {result[:8]}")

    print("\n" + "="*50)
    print("  Pipeline complete")
    print("  ONNX -> .merchant -> inference -> result")
    print("="*50 + "\n")

if __name__ == "__main__":
    main()
