#DTW.py
import numpy as np
import cv2
from scipy.spatial.distance import euclidean
from fastdtw import fastdtw
import os

def load_keypoints(file_path):
    return np.load(file_path)

def compare_poses(reference_path, test_path):
    ref = load_keypoints(reference_path)
    test = load_keypoints(test_path)

    # DTW 거리 계산용 flatten
    ref_seq = [kp[:, :2].flatten() for kp in ref]
    test_seq = [kp[:, :2].flatten() for kp in test]
    
    distance, path = fastdtw(ref_seq, test_seq, dist=euclidean)
    print(f"DTW 거리: {distance:.2f}")
    return distance, ref, test, path

def visualize_keypoint_diff(ref, test, save_path='comparison.mp4', threshold=0.1):
    height, width = 256, 256
    out = cv2.VideoWriter(save_path, cv2.VideoWriter_fourcc(*'mp4v'), 10, (width, height))

    for i in range(min(len(ref), len(test))):
        canvas = np.ones((height, width, 3), dtype=np.uint8) * 255

        for j in range(17):
            x_ref, y_ref = ref[i][j][:2]
            x_test, y_test = test[i][j][:2]
            dist = np.linalg.norm([x_ref - x_test, y_ref - y_test])

            color = (0, 255, 0) if dist < threshold else (0, 0, 255)
            cv2.circle(canvas, (int(x_test * width), int(y_test * height)), 4, color, -1)

        out.write(canvas)

    out.release()
    print(f"시각화 저장 완료: {save_path}")

def compute_diff_sequence(ref, test, path):
    # ref, test: (frames, 17, 3)
    ref_seq = [r[:, :2].flatten() for r in ref]
    test_seq = [t[:, :2].flatten() for t in test]

    diff_seq = [test_seq[j] - ref_seq[i] for i, j in path]  # (N, 34)
    return np.array(diff_seq)


if __name__ == "__main__":
    reference_file = os.path.join("AI", "output", "Pro_Player.npy")
    test_file = os.path.join("AI", "output", "Test_Me.npy")

    distance, ref, test = compare_poses(reference_file, test_file)
    visualize_keypoint_diff(ref, test)
