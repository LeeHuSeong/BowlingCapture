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


def visualize_keypoint_diff(ref, test, save_path, width=640, height=480):
    fps = 30
    out = cv2.VideoWriter(save_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))

    for i in range(min(len(ref), len(test))):
        # 배경 프레임 (검정)
        canvas = np.zeros((height, width, 3), dtype=np.uint8)

        for j in range(17):
            x1, y1, c1 = ref[i][j]
            x2, y2, c2 = test[i][j]

            # 🔧 정규화된 좌표라면 해상도에 맞게 변환
            if x1 < 1 and y1 < 1:
                x1, y1 = int(x1 * width), int(y1 * height)
            else:
                x1, y1 = int(x1), int(y1)

            if x2 < 1 and y2 < 1:
                x2, y2 = int(x2 * width), int(y2 * height)
            else:
                x2, y2 = int(x2), int(y2)

            # 🔧 confidence threshold 설정
            if c1 > 0.3:
                cv2.circle(canvas, (x1, y1), 4, (0, 255, 0), -1)
            if c2 > 0.3:
                cv2.circle(canvas, (x2, y2), 4, (0, 0, 255), -1)
            if c1 > 0.3 and c2 > 0.3:
                cv2.line(canvas, (x1, y1), (x2, y2), (255, 255, 0), 2)

        # ✅ 필요하면 회전 (옆으로 누운 경우)
        canvas = cv2.rotate(canvas, cv2.ROTATE_90_CLOCKWISE)

        out.write(canvas)

    out.release()
    print(f"📼 비교 영상 저장 완료: {save_path}")
    
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
