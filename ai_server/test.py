#import tensorflow as tf
#
#print("TensorFlow 버전:", tf.__version__)
#print("GPU 사용 가능:", tf.config.list_physical_devices('GPU'))
import cv2

# 절대 경로 (Windows 스타일로 \ 대신 / 사용하거나 문자열 앞에 r 추가)
video_path = r"C:\Users\admin\Desktop\BowlingCapture\twohand_001.MOV"

cap = cv2.VideoCapture(video_path)

if not cap.isOpened():
    print(f"❌ 영상 열기 실패: {video_path}")
else:
    print(f"✅ 영상 열기 성공: {video_path}")
    frame_count = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame_count += 1

        # 첫 프레임 출력
        if frame_count == 1:
            cv2.imshow('첫 프레임', frame)
            cv2.waitKey(0)
            cv2.destroyAllWindows()

    print(f"🎞️ 총 {frame_count} 프레임 읽음")

cap.release()
