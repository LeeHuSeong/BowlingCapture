#main.py
from flask import Flask, request, jsonify
import os
from MoveNet import extract_keypoints_from_video
from DTW import compare_poses, compute_diff_sequence
from LSTM import predict_feedback

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


@app.route('/analyze_pose', methods=['POST'])
def analyze_pose():
    reference_path = 'Data/keypoints/twohand_001.npy'
    test_filename = request.json.get('test_keypoints')  # 예: outputs/uploaded_001.npy
    test_path = os.path.join(OUTPUT_FOLDER, os.path.basename(test_filename))

    if not os.path.exists(reference_path) or not os.path.exists(test_path):
        return jsonify({'error': '파일 경로가 잘못되었습니다.'}), 400

    distance, ref, test,path = compare_poses(reference_path, test_path)
    diff_seq = compute_diff_sequence(ref, test, path=path )  

    feedback_text = predict_feedback(diff_seq)

    return jsonify({
        'feedback': feedback_text,
        'distance': round(distance, 2)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
