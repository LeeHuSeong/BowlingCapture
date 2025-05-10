#import tensorflow as tf
#
#print("TensorFlow 버전:", tf.__version__)
#print("GPU 사용 가능:", tf.config.list_physical_devices('GPU'))

import cv2

video_path = "Data/Learning/twohand/twohand_001.MOV"
cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print("❌ 영상 열기 실패")
else:
    print("✅ 영상 열기 성공")
    count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        count += 1
    print(f"🎞️ 총 {count} 프레임 읽음")
cap.release()
