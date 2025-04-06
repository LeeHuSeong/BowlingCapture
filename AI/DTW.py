import numpy as np
from scipy.spatial.distance import euclidean
from fastdtw import fastdtw
import os

def load_keypoints(file_path):
    return np.load(file_path)

def compare_poses(reference_path, test_path):
    ref = load_keypoints(reference_path)
    test = load_keypoints(test_path)

    # DTW 비교 (프레임마다 17개 관절 * (x, y) 좌표)
    ref_seq = [kp[:, :2].flatten() for kp in ref]  # (17, 2) → (34,)
    test_seq = [kp[:, :2].flatten() for kp in test]

    distance, path = fastdtw(ref_seq, test_seq, dist=euclidean)
    print(f"DTW 거리: {distance:.2f}")
    return distance

if __name__ == "__main__":
    # 예시 경로
    reference_file = os.path.join("AI", "output", "Pro_Player.npy")  # 기준 자세
    test_file = os.path.join("AI", "output", "Test_Me.npy")          # 사용자 자세

    compare_poses(reference_file, test_file)
