# MoveNet.py
import numpy as np
import tensorflow as tf
import tensorflow_hub as hub
import cv2
import os

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
    label = video_name.split("_")[0]
    class_folder = os.path.join(output_folder, label)
    os.makedirs(class_folder, exist_ok=True)
    output_path = os.path.join(class_folder, f"{video_name}.npy")

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print(f"❌ 영상 열기 실패: {video_path}")
        return None

    all_keypoints = []
    frame_count = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        frame_count += 1
        if frame_count % 10 == 0:
            print(f"📸 {video_name} 프레임 {frame_count} 처리 중...")

        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image_tensor = tf.convert_to_tensor(image_rgb)
        try:
            keypoints = detect_pose(image_tensor)
            all_keypoints.append(keypoints)
        except Exception as e:
            print(f"⚠️ 키포인트 추출 오류 (프레임 {frame_count}): {e}")

    cap.release()

    if len(all_keypoints) == 0:
        print(f"❌ {video_name} 처리 실패: 키포인트 없음")
        return None

    all_keypoints = np.array(all_keypoints)
    np.save(output_path, all_keypoints)
    print(f"저장 완료: {output_path} (shape: {all_keypoints.shape})")

    if os.path.exists(output_path):
        print(f"✅ .npy 파일 저장 확인: {output_path}")
    else:
        print(f"❌ .npy 파일 저장 실패: {output_path}")

    return output_path
