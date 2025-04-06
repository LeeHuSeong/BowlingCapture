import numpy as np
import cv2
import tensorflow as tf
import tensorflow_hub as hub
import os
from glob import glob

# GPU 사용 가능하도록 설정 (가능할 경우)
gpus = tf.config.list_physical_devices('GPU')
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print(f"GPU 사용 설정 완료: {len(gpus)}개 GPU 감지됨")
    except RuntimeError as e:
        print(f"GPU 설정 중 오류 발생: {e}")
else:
    print("GPU 사용 불가. CPU로 실행됩니다.")


def load_movenet_model():
    model = hub.load("https://tfhub.dev/google/movenet/singlepose/thunder/4")
    return model.signatures['serving_default']

def detect_pose(movenet, image):
    input_image = tf.image.resize_with_pad(image, 256, 256)
    input_image = tf.expand_dims(input_image, axis=0)
    input_image = tf.cast(input_image, dtype=tf.int32)
    outputs = movenet(input_image)
    keypoints = outputs['output_0'].numpy()[0, 0, :, :]  # shape: (17, 3)
    return keypoints

# 모델 로드
movenet = load_movenet_model()

# 입력 및 출력 디렉토리 설정
video_folder = os.path.join("AI", "vid")  # 상대경로: ./AI/vid
output_folder = os.path.join("AI", "output")
os.makedirs(output_folder, exist_ok=True)

# 모든 mp4 파일 찾기
video_files = glob(os.path.join(video_folder, "*.mp4"))

# 각 영상에 대해 처리
for video_path in video_files:
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    print(f"영상 처리 중: {video_name}")

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"영상 열기 실패: {video_path}")
        continue

    all_keypoints = []
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image_tensor = tf.convert_to_tensor(image_rgb)
        keypoints = detect_pose(movenet, image_tensor)
        all_keypoints.append(keypoints)

    cap.release()

    all_keypoints = np.array(all_keypoints)
    save_path = os.path.join(output_folder, f"{video_name}.npy")
    np.save(save_path, all_keypoints)
    print(f"저장 완료: {save_path} -> shape: {all_keypoints.shape}")

print("모든 영상 처리 완료.")
