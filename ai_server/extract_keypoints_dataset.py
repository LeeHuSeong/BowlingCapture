import os
import numpy as np
import cv2
import tensorflow as tf
import tensorflow_hub as hub
from glob import glob

# ✅ GPU 설정
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print(f"✅ GPU 사용 설정 완료: {len(gpus)}개 GPU 감지됨")
    except RuntimeError as e:
        print(f"❌ GPU 설정 오류: {e}")
else:
    print("⚠️ GPU 사용 불가. CPU로 실행됩니다.")

# ✅ MoveNet 모델 로딩
movenet = hub.load("https://tfhub.dev/google/movenet/singlepose/thunder/4").signatures['serving_default']

def detect_pose(image):
    input_image = tf.image.resize_with_pad(image, 256, 256)
    input_image = tf.expand_dims(input_image, axis=0)
    input_image = tf.cast(input_image, dtype=tf.int32)
    outputs = movenet(input_image)
    keypoints = outputs['output_0'].numpy()[0, 0, :, :]  # (17, 3)
    return keypoints

def extract_keypoints_from_video(video_path, output_folder):
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    output_path = os.path.join(output_folder, f"{video_name}.npy")

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"❌ 영상 열기 실패: {video_path}")
        return None

    all_keypoints = []
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image_tensor = tf.convert_to_tensor(image_rgb)
        keypoints = detect_pose(image_tensor)
        all_keypoints.append(keypoints)

    cap.release()
    all_keypoints = np.array(all_keypoints)
    np.save(output_path, all_keypoints)
    print(f"✅ 키포인트 저장 완료: {output_path} (shape: {all_keypoints.shape})")
    return output_path

# ✅ 폴더 설정
input_folder = os.path.join("AI", "Data", "Learning")
output_folder = os.path.join("AI", "Data", "output_npy")
os.makedirs(output_folder, exist_ok=True)

# ✅ 모든 .MOV 파일 처리
video_files = glob(os.path.join(input_folder, "*.MOV"))
print(f"🎞️ 총 {len(video_files)}개 영상 처리 시작...")

for video_path in video_files:
    extract_keypoints_from_video(video_path, output_folder)

print("✅ 모든 영상 처리 완료")
