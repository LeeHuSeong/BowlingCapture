from flask import Flask, request, jsonify
import os
from MoveNet import extract_keypoints_from_video

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.route('/extract_pose', methods=['POST'])
def extract_pose():
    if 'video' not in request.files:
        return jsonify({'error': 'No video part'}), 400

    file = request.files['video']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    # 저장 경로 구성
    video_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(video_path)

    # 키포인트 추출
    keypoints_path = extract_keypoints_from_video(video_path, OUTPUT_FOLDER)

    return jsonify({'message': 'Pose extracted', 'keypoints_path': keypoints_path})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
