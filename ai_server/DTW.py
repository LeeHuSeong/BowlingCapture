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

    # 관절 연결 정보 (MoveNet 기준)
    connections = [
        (0, 1), (1, 2), (2, 3), (3, 4),       # 오른팔
        (0, 5), (5, 6), (6, 7), (7, 8),       # 왼팔
        (9, 10),                              # 엉덩이
        (11, 12), (11, 13), (13, 15),         # 왼다리
        (12, 14), (14, 16)                    # 오른다리
    ]

    for i in range(min(len(ref), len(test))):
        canvas = np.ones((height, width, 3), dtype=np.uint8) * 255

        # 관절 점 위치 계산
        points = []
        for j in range(17):
            x, y = test[i][j][:2]
            points.append((int(x * width), int(y * height)))

        # 선 그리기 (거리 차이로 색상 구분)
        for (j1, j2) in connections:
            x1, y1 = test[i][j1][:2]
            x2, y2 = test[i][j2][:2]
            dist1 = np.linalg.norm(ref[i][j1][:2] - test[i][j1][:2])
            dist2 = np.linalg.norm(ref[i][j2][:2] - test[i][j2][:2])
            avg_dist = (dist1 + dist2) / 2

            color = (0, 255, 0) if avg_dist < threshold else (0, 0, 255)
            pt1 = points[j1]
            pt2 = points[j2]
            cv2.line(canvas, pt1, pt2, color, 2)

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
