import onnx
import numpy as np
import struct
import argparse
import os

MAGIC = b'MRCH'
VERSION = 2

def quantize_to_int8(weights):
    max_val = np.max(np.abs(weights))
    if max_val == 0:
        return np.zeros_like(weights, dtype=np.int8), 1.0
    scale = 127.0 / max_val
    quantized = np.clip(np.round(weights * scale), -128, 127)
    return quantized.astype(np.int8), scale

def sparse_schedule(weights_2d):
    rows = weights_2d.shape[0]
    density = np.array([np.sum(weights_2d[r] != 0) for r in range(rows)])
    schedule_map = np.argsort(-density)
    return weights_2d[schedule_map], schedule_map

def extract_layers(onnx_model):
    layers = []
    initializers = {}
    for init in onnx_model.graph.initializer:
        arr = onnx.numpy_helper.to_array(init)
        initializers[init.name] = arr
    for node in onnx_model.graph.node:
        op_type = node.op_type
        if op_type == 'Conv':
            layer = {'type': 'Conv', 'name': node.name or op_type}
            if len(node.input) >= 2:
                w_name = node.input[1]
                if w_name in initializers:
                    w = initializers[w_name]
                    layer['weights'] = w
                    layer['shape'] = w.shape
                    print(f"  Found Conv: {layer['name']} shape={w.shape}")
            if len(node.input) >= 3:
                b_name = node.input[2]
                if b_name in initializers:
                    layer['bias'] = initializers[b_name]
            if 'weights' in layer:
                layers.append(layer)
        elif op_type in ['Gemm', 'MatMul']:
            layer = {'type': 'Linear', 'name': node.name or op_type}
            if len(node.input) >= 2:
                w_name = node.input[1]
                if w_name in initializers:
                    w = initializers[w_name]
                    layer['weights'] = w
                    layer['shape'] = w.shape
                    print(f"  Found Linear: {layer['name']} shape={w.shape}")
            if len(node.input) >= 3:
                b_name = node.input[2]
                if b_name in initializers:
                    layer['bias'] = initializers[b_name]
            if 'weights' in layer:
                layers.append(layer)
    return layers

def compile_layer(layer):
    weights = layer['weights']
    original_shape = weights.shape
    w_flat = weights.reshape(weights.shape[0], -1)
    cols = w_flat.shape[1]
    if cols < 32:
        pad = np.zeros((w_flat.shape[0], 32 - cols), dtype=np.float32)
        w_flat = np.concatenate([w_flat, pad], axis=1)
    elif cols > 32:
        w_flat = w_flat[:, :32]
    rows = w_flat.shape[0]
    if rows < 32:
        pad = np.zeros((32 - rows, 32), dtype=np.float32)
        w_flat = np.concatenate([w_flat, pad], axis=0)
    elif rows > 32:
        w_flat = w_flat[:32, :]
    w_int8, scale = quantize_to_int8(w_flat)
    w_scheduled, schedule_map = sparse_schedule(w_int8)
    total = w_scheduled.size
    zeros = np.sum(w_scheduled == 0)
    sparsity = zeros / total * 100
    bias = np.zeros(32, dtype=np.int32)
    if 'bias' in layer:
        b = layer['bias'].flatten()
        b_len = min(len(b), 32)
        bias[:b_len] = (b[:b_len] * scale).astype(np.int32)
    return {
        'name': layer['name'],
        'type': layer['type'],
        'weights_int8': w_scheduled,
        'bias_int32': bias,
        'scale': scale,
        'sparsity': sparsity,
        'original_shape': original_shape
    }

def write_merchant_file(compiled_layers, output_path, model_name):
    with open(output_path, 'wb') as f:
        f.write(MAGIC)
        f.write(struct.pack('B', VERSION))
        f.write(struct.pack('I', len(compiled_layers)))
        name_bytes = model_name.encode('utf-8')[:63]
        name_padded = name_bytes + b'\x00' * (64 - len(name_bytes))
        f.write(name_padded)
        for layer in compiled_layers:
            layer_type = 1 if layer['type'] == 'Conv' else 2
            f.write(struct.pack('B', layer_type))
            lname = layer['name'].encode('utf-8')[:31]
            lname_padded = lname + b'\x00' * (32 - len(lname))
            f.write(lname_padded)
            f.write(struct.pack('f', layer['scale']))
            f.write(struct.pack('f', layer['sparsity']))
            weights_flat = layer['weights_int8'].flatten()[:1024]
            if len(weights_flat) < 1024:
                weights_flat = np.pad(weights_flat, (0, 1024 - len(weights_flat)))
            f.write(weights_flat.astype(np.int8).tobytes())
            f.write(layer['bias_int32'].astype(np.int32).tobytes())

def compile_onnx(onnx_path, output_path=None):
    print(f"\n  MERCHANT ONNX Compiler")
    print(f"  Input:  {onnx_path}")
    if output_path is None:
        output_path = onnx_path.replace('.onnx', '.merchant')
    print(f"  Output: {output_path}")
    print(f"\n  Loading ONNX model...")
    model = onnx.load(onnx_path)
    onnx.checker.check_model(model)
    print(f"  Model valid")
    model_name = os.path.basename(onnx_path).replace('.onnx', '')
    print(f"\n  Extracting layers...")
    layers = extract_layers(model)
    print(f"  Found {len(layers)} weight layers")
    if len(layers) == 0:
        print(f"  WARNING: No layers found")
        return None
    print(f"\n  Compiling layers...")
    compiled = []
    total_sparsity = 0
    for i, layer in enumerate(layers):
        print(f"\n  Layer {i+1}/{len(layers)}: {layer['name']}")
        print(f"    Shape: {layer['shape']}")
        c = compile_layer(layer)
        compiled.append(c)
        total_sparsity += c['sparsity']
        print(f"    Sparsity: {c['sparsity']:.1f}%")
        print(f"    Scale: {c['scale']:.4f}")
    avg_sparsity = total_sparsity / len(compiled)
    print(f"\n  Writing .merchant file...")
    write_merchant_file(compiled, output_path, model_name)
    file_size = os.path.getsize(output_path)
    print(f"\n  COMPILATION COMPLETE")
    print(f"  Layers compiled : {len(compiled)}")
    print(f"  Avg sparsity    : {avg_sparsity:.1f}%")
    print(f"  Output file     : {output_path}")
    print(f"  File size       : {file_size} bytes\n")
    return output_path

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='MERCHANT ONNX Compiler')
    parser.add_argument('onnx_file', help='Input ONNX model file')
    parser.add_argument('--output', '-o', help='Output .merchant file path')
    args = parser.parse_args()
    if not os.path.exists(args.onnx_file):
        print(f"Error: File not found: {args.onnx_file}")
        exit(1)
    result = compile_onnx(args.onnx_file, args.output)
    if result:
        print(f"Success: {result}")
    else:
        print("Compilation failed")
        exit(1)
