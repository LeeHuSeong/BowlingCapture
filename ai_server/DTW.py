# DTW.py
import numpy as np
from scipy.spatial.distance import euclidean
from fastdtw import fastdtw

def load_keypoints(file_path):
    return np.load(file_path)

def compare_poses(reference_path, test_path):
    ref = load_keypoints(reference_path)
    test = load_keypoints(test_path)

    ref_seq = [kp[:, :2].flatten() for kp in ref]
    test_seq = [kp[:, :2].flatten() for kp in test]

    distance, path = fastdtw(ref_seq, test_seq, dist=euclidean)
    print(f"DTW 거리: {distance:.2f}")
    return distance, ref, test, path

def compute_diff_sequence(ref, test, path):
    ref_seq = [r[:, :2].flatten() for r in ref]
    test_seq = [t[:, :2].flatten() for t in test]

    diff_seq = [test_seq[j] - ref_seq[i] for i, j in path]
    return np.array(diff_seq)
