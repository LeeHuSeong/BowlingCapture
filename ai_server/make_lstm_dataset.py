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
            #distance, ref, test, path = compare_poses(file_path, file_path)
            reference_path = "Data/keypoints/twohand/twohand_001.npy"  # 기준자세 (twohand 중 하나)
            test_path = file_path
            distance, ref, test, path = compare_poses(reference_path, test_path)
            diff_seq = compute_diff_sequence(ref, test, path)

            # 고쳐야 됨, 학습 데이터에 틀린거 없어서 임시방편.# 그 다음에 라벨 생성
            if label_name == "twohand":
                label_seq = np.zeros((diff_seq.shape[0], 1))  # 정상
            else:
                label_seq = np.ones((diff_seq.shape[0], 1))   # 틀린 동작

            base_name = filename.replace(".npy", "")
            np.save(os.path.join(output_dir, f"{base_name}_diff.npy"), diff_seq)
            np.save(os.path.join(output_dir, f"{base_name}_label.npy"), label_seq) 

            print(f"✅ 저장됨: {label_name}/{base_name} (diff + label)")
        except Exception as e:
            print(f"⚠️ 실패: {filename} → {e}")
