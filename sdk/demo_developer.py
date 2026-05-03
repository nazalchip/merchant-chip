import numpy as np
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import merchant

print("\n" + "═"*50)
print("  MERCHANT CHIP — Developer Demo")
print("═"*50 + "\n")

# Demo 1 — basic inference
print("── DEMO 1: Basic Inference ──\n")
chip = merchant.Chip()
weights = np.full(256, 3, dtype=np.int8)
inputs  = np.full(16, 2, dtype=np.int8)
result  = chip.infer(inputs=inputs, weights=weights)
print(f"Result: {result}")
print(f"Expected: 96 per channel (clamped to 127)\n")

# Demo 2 — model class
print("── DEMO 2: Model Class ──\n")
random_weights = np.random.randint(-8, 8, 256, dtype=np.int8)
model = merchant.Model.from_weights(random_weights, name="robot_v1")
model.summary()
chip2 = merchant.Chip()
chip2.load_weights(model.weights)
camera_input = np.array([10,5,3,-2,8,1,0,4,7,-1,6,2,9,3,1,5], dtype=np.int8)
result2 = chip2.infer(inputs=camera_input)
chip2.print_outputs()

# Demo 3 — robot loop
print("── DEMO 3: Robot Obstacle Detection ──\n")
robot_chip = merchant.Chip()
robot_chip.load_weights(np.random.randint(-5,5,256,dtype=np.int8))
for i in range(5):
    frame      = np.random.randint(-10, 10, 16, dtype=np.int8)
    detection  = robot_chip.infer(inputs=frame)
    strongest  = np.argmax(np.abs(detection))
    strength   = abs(int(detection[strongest]))
    action     = "STOP" if strength > 50 else "SLOW" if strength > 20 else "GO"
    print(f"Frame {i+1}: channel={strongest} value={detection[strongest]} → {action}")

robot_chip.status()
print("═"*50)
print("  MERCHANT SDK Layer 2 complete!")
print("═"*50 + "\n")
