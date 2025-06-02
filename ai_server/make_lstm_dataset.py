# make_lstm_dataset.py
import os
import numpy as np
from DTW import compare_poses, compute_diff_sequence

# Data Augmentation

def jitter_sequence(seq, std=0.015):
    noise = np.random.normal(0, std, seq.shape)
    return seq + noise

def time_warp_sequence(seq, factor):
    from scipy.interpolate import interp1d
    t = np.linspace(0, 1, len(seq))
    t_new = np.linspace(0, 1, int(len(seq) * factor))
    interpolator = interp1d(t, seq, axis=0, kind='linear', fill_value='extrapolate')
    return interpolator(t_new)

def save_augmented(diff_seq, is_wrong, base_name, output_dir, suffix):
    label_seq = np.ones((diff_seq.shape[0], 1)) if is_wrong else np.zeros((diff_seq.shape[0], 1))
    np.save(os.path.join(output_dir, f"{base_name}_{suffix}_diff.npy"), diff_seq)
    np.save(os.path.join(output_dir, f"{base_name}_{suffix}_label.npy"), label_seq)
    print(f"📈 증강 저장: {base_name}_{suffix} (shape: {diff_seq.shape})")

keypoint_dir = "Data/keypoints"
base_output_dir = "Data/lstm_dataset"
label_map = {"cranker": 0, "twohand": 1, "stroker": 2, "thumbless":3}

reference_path = "Data/keypoints/twohand/twohand_001.npy"  # 기준 자세

threshold = 0.01

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

            mean_diff = np.mean(np.abs(diff_seq))  # 전체 평균 차이
            is_wrong = mean_diff >= threshold

            label_seq = np.ones((diff_seq.shape[0], 1)) if is_wrong else np.zeros((diff_seq.shape[0], 1))

            base_name = filename.replace(".npy", "")
            # 1. 원본 저장
            np.save(os.path.join(output_dir, f"{base_name}_diff.npy"), diff_seq)
            np.save(os.path.join(output_dir, f"{base_name}_label.npy"), label_seq)

            # 2. 증강: Jitter
            aug1 = jitter_sequence(diff_seq)
            save_augmented(aug1, is_wrong, base_name, output_dir, "jitter")

            # 3. 증강: Time Stretch (느리게)
            aug2 = time_warp_sequence(diff_seq, factor=1.1)
            save_augmented(aug2, is_wrong, base_name, output_dir, "stretch")

            # 4. 증강: Time Compress (빠르게)
            aug3 = time_warp_sequence(diff_seq, factor=0.9)
            save_augmented(aug3, is_wrong, base_name, output_dir, "compress")

            print(f"✅ 저장됨: {label_name}/{base_name} (mean_diff={mean_diff:.4f}, label={'1' if is_wrong else '0'})")

        except Exception as e:
            print(f"⚠️ 실패: {filename} → {e}")
