import numpy as np

sample = np.load("Data/lstm_dataset/twohand/twohand_001_diff.npy")
print("sample shape:", sample.shape)
print("max:", np.max(sample))
print("min:", np.min(sample))
print("mean:", np.mean(sample))