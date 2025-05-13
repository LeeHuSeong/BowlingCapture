#main.py
from flask import Flask, request, jsonify
import os
import uuid
from MoveNet import extract_keypoints_from_video
from DTW import compare_poses, compute_diff_sequence, visualize_keypoint_diff
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences
from flask import send_from_directory

#비교 영상 생성
comparison_filename = f"comparison_{uuid.uuid4().hex}.mp4"
comparison_path = os.path.join("outputs", comparison_filename)
visualize_keypoint_diff(ref, test, save_path=comparison_path)


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
    try:
        test_filename = request.json.get('test_keypoints')
        pitch_type = request.json.get('pitch_type')  # ✅ 구질 정보도 받음

        if not test_filename or not pitch_type:
            return jsonify({'error': 'test_keypoints 또는 pitch_type 누락'}), 400

        #테스트용 path
        reference_path = os.path.abspath("Data/keypoints/twohand/twohand_001.npy")

        test_path = os.path.abspath(test_filename.replace("\\", "/"))
        model_path = f"lstm_{pitch_type}.h5"

        print(f"📂 기준 자세: {reference_path}")
        print(f"📂 테스트 파일: {test_path}")
        print(f"📂 사용 모델: {model_path}")

        if not os.path.exists(reference_path) or not os.path.exists(test_path) or not os.path.exists(model_path):
            return jsonify({'error': '파일 경로가 잘못되었거나 모델이 없습니다.'}), 400

        # DTW 비교 및 diff_seq 생성
        distance, ref, test, path = compare_poses(reference_path, test_path)
        diff_seq = compute_diff_sequence(ref, test, path)

        # LSTM 예측
        feedback_text = predict_feedback(diff_seq, model_path)

        return jsonify({
            'feedback': feedback_text,
            'distance': round(distance, 2),
            'pitch_type': pitch_type,
            'comparison_video': comparison_filename
        })

    except Exception as e:
        print(f"❌ 서버 내부 오류: {e}")
        return jsonify({'error': '서버 오류 발생', 'detail': str(e)}), 500

def predict_feedback(diff_seq, model_path):
    model = load_model(model_path)
    padded = pad_sequences([diff_seq], padding='post', maxlen=267, dtype='float32')
    pred = model.predict(padded)

    label_map = {0: "자세가 적절합니다!"}  # 단일 클래스 기준으로 메시지 설정
    predicted_label = 0 if pred[0][0] > 0.5 else 1
    return label_map.get(predicted_label, "자세가 개선이 필요합니다.")

#스트리밍 mp4
@app.route('/video/<filename>')
def serve_video(filename):
    return send_from_directory('outputs', filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
