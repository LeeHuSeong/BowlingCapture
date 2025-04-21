from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
import os
from MoveNet import extract_keypoints_from_video
from flask import send_from_directory

app = Flask(__name__)

# 업로드 경로 설정
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

@app.route('/extract_pose', methods=['POST'])
def extract_pose():
    if 'video' not in request.files:
        return jsonify({'error': 'No video file uploaded'}), 400

    video = request.files['video']
    filename = secure_filename(video.filename)
    video_path = os.path.join(UPLOAD_FOLDER, filename)
    video.save(video_path)

    try:
        result_path = extract_keypoints_from_video(video_path, OUTPUT_FOLDER)
        return jsonify({
            'message': 'Pose extraction successful',
            'npy_path': result_path
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    

@app.route('/get_comparison_video', methods=['GET'])
def get_comparison_video():
    video_path = os.path.join(os.getcwd(), 'comparison.mp4')
    if os.path.exists(video_path):
        return send_from_directory(directory=os.getcwd(), path='comparison.mp4', as_attachment=False)
    return jsonify({'error': 'Comparison video not found'}), 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
