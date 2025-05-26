import os
import numpy as np
from DTW import compare_poses, compute_diff_sequence

keypoint_dir = "Data/keypoints"
base_output_dir = "Data/lstm_dataset"
label_map = {"cranker": 0, "twohand": 1, "stroker": 2}

reference_path = "Data/keypoints/twohand/twohand_001.npy"  # 기준 자세

threshold = 0.08  # 🎯 평균 diff가 이 이상이면 '틀림'으로 간주

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
            distance, ref, test, path = compare_poses(reference_path, file_path)
            diff_seq = compute_diff_sequence(ref, test, path)

            mean_diff = np.mean(np.abs(diff_seq))  # 🎯 전체 평균 차이
            is_wrong = mean_diff >= threshold

            label_seq = np.ones((diff_seq.shape[0], 1)) if is_wrong else np.zeros((diff_seq.shape[0], 1))

            base_name = filename.replace(".npy", "")
            np.save(os.path.join(output_dir, f"{base_name}_diff.npy"), diff_seq)
            np.save(os.path.join(output_dir, f"{base_name}_label.npy"), label_seq)

            print(f"✅ 저장됨: {label_name}/{base_name} (mean_diff={mean_diff:.4f}, label={'1' if is_wrong else '0'})")

        except Exception as e:
            print(f"⚠️ 실패: {filename} → {e}")
