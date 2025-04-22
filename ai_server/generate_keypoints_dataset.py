# generate_keypoints_dataset.py
import os
from glob import glob
from MoveNet import extract_keypoints_from_video

# ✅ 경로 설정
base_path = os.path.dirname(os.path.abspath(__file__))
input_folder = os.path.join(base_path, "Data", "Learning")
output_folder = os.path.join(base_path, "Data", "keypoints")
os.makedirs(output_folder, exist_ok=True)

# ✅ .MOV 등 확장자 필터링
video_files = glob(os.path.join(input_folder, "*", "*"))
video_files = [vf for vf in video_files if vf.lower().endswith(('.mov', '.mp4', '.avi', '.mkv'))]
print(f"🎞️ 총 {len(video_files)}개 영상 처리 시작...")

# ✅ 추출 실행
for video_path in video_files:
    extract_keypoints_from_video(video_path, output_folder)

print("✅ 모든 영상 처리 완료.")
