import os
import numpy as np
from DTW import compare_poses, compute_diff_sequence

keypoint_dir = "Data/keypoints"
base_output_dir = "Data/lstm_dataset"
label_map = {"cranker": 0, "twohand": 1, "stroker": 2}

# 키포인트 파일 반복
for root, dirs, files in os.walk(keypoint_dir):
    for filename in files:
        print(f"처리 중: {filename}")

        if not filename.endswith(".npy"):
            continue

        label_name = filename.split("_")[0].lower()
        if label_name not in label_map:
            print(f"라벨 없음 또는 무시: {label_name}")
            continue

        file_path = os.path.join(root, filename)
        output_dir = os.path.join(base_output_dir, label_name)
        os.makedirs(output_dir, exist_ok=True)

        try:
            distance, ref, test, path = compare_poses(file_path, file_path)
            diff_seq = compute_diff_sequence(ref, test, path)

            base_name = filename.replace(".npy", "")
            np.save(os.path.join(output_dir, f"{base_name}_diff.npy"), diff_seq)

            with open(os.path.join(output_dir, f"{base_name}_label.txt"), "w") as f:
                f.write("0")  # 이 라벨은 현재 필요 없음 (모두 같은 클래스이기 때문)

            print(f"✅ 저장됨: {label_name}/{base_name}")
        except Exception as e:
            print(f"⚠️ 실패: {filename} → {e}")
