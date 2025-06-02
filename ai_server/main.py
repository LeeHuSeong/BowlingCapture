#main.py
# 표준 라이브러리
import os
import uuid

# 외부 라이브러리
import numpy as np
import cv2
import subprocess
import json
from flask import Flask, request, jsonify, send_from_directory
from flask import send_file
from tensorflow.keras.models import load_model  
from tensorflow.keras.preprocessing.sequence import pad_sequences

# 사용자 정의 모듈
from DTW import compare_poses, compute_diff_sequence
from MoveNet import extract_keypoints_from_video
from visualize_feedback import visualize_pose_feedback, summarize_top_joints, JOINT_FEEDBACK_MAP



app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
OUTPUT_FOLDER = 'outputs'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)


EXPECTED_LEN = {
    "cranker": 365,
    "twohand": 305,
    "thumbless": 262,
    "stroker": 300  #예상
}

@app.route('/extract_pose', methods=['POST'])
def extract_pose():
    if 'video' not in request.files:
        return jsonify({'error': 'No video part'}), 400

    file = request.files['video']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    start = float(request.form.get('start', 0))
    end = float(request.form.get('end', 0))

    video_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(video_path)

    trimmed_path = os.path.join(OUTPUT_FOLDER, f"trimmed_{file.filename}")
    trim_video_opencv(video_path, trimmed_path, start, end)

    keypoints_path = extract_keypoints_from_video(trimmed_path, OUTPUT_FOLDER)

    return jsonify({
    'message': 'Pose extracted',
    'keypoints_path': keypoints_path.replace('\\', '/'),
    'trimmed_video': trimmed_path.replace('\\', '/')  # ✅ 추가
})

def predict_framewise_labels(diff_seq, model_path):
    pitch_type = os.path.basename(model_path).replace("lstm_", "").replace(".h5", "")
    maxlen = EXPECTED_LEN.get(pitch_type, 278)  # 기본값 278

    model = load_model(model_path)
    padded = pad_sequences([diff_seq], padding='post', maxlen=maxlen)

    preds = model.predict(padded)  # shape: (1, T, 1)
    framewise = np.squeeze(preds[0])

    if framewise.ndim == 0:
        framewise = np.array([framewise])

    labels = (framewise > 0.5).astype(int).tolist()[:len(diff_seq)]
    confidence = float(np.mean(framewise[:len(diff_seq)]))

    print(f"✅ preds shape: {preds.shape}")
    print(f"🎯 labels 생성됨: {len(labels)}개, confidence: {confidence:.2f}")

    return labels, confidence



@app.route('/analyze_pose', methods=['POST'])
def analyze_pose():
    try:
        test_filename = request.json.get('test_keypoints')
        pitch_type = request.json.get('pitch_type')

        #디버깅 로그
        print("✅ analyze_pose 요청 수신")
        print(f"📩 받은 test_keypoints: {test_filename}")
        print(f"📩 받은 pitch_type: {pitch_type}")

        if not test_filename or not pitch_type:
            return jsonify({'error': 'test_keypoints 또는 pitch_type 누락'}), 400
        
        # 한글 → 영문 pitch_type 매핑
        type_map = {'스트로커':'stroker','투핸드': 'twohand', '덤리스': 'thumbless', '크랭커':'cranker'}
        mapped_type = type_map.get(pitch_type.strip(), pitch_type.strip())  # 매핑 없으면 그대로 사용
        print(f"📂 pitch_type 매핑 결과: {mapped_type}")

        # 경로 정규화
        test_path = os.path.normpath(test_filename)
        test_path = os.path.abspath(test_path)
        print(f"📂 최종 정규화된 경로: {test_path}, 존재 여부: {os.path.exists(test_path)}")
        
        reference_path = os.path.abspath("Data/keypoints/twohand/twohand_001.npy")
        model_path = os.path.abspath(f"lstm_{mapped_type}.h5")

        # 경로 존재 여부 체크 (로깅 포함)
        print(f"📂 test_path: {test_path}, exists: {os.path.exists(test_path)}")
        print(f"📂 reference_path: {reference_path}, exists: {os.path.exists(reference_path)}")
        print(f"📂 model_path: {model_path}, exists: {os.path.exists(model_path)}")

        if not os.path.exists(reference_path) or not os.path.exists(test_path) or not os.path.exists(model_path):
            return jsonify({'error': '파일 경로가 잘못되었거나 모델이 없습니다.'}), 400

        distance, ref, test, path = compare_poses(reference_path, test_path)
        diff_seq = compute_diff_sequence(ref, test, path)

        #프레임별 예측
        labels, confidence = predict_framewise_labels(diff_seq, model_path)
        score = round(confidence * 100, 2)

        #labels 체크
        if len(labels) < 2:
            print("⚠️ 시각화용 labels가 너무 적습니다. 비교 영상 생략")
            return jsonify({
                'feedback': '분석할 수 있는 자세 정보가 부족합니다.',
                'distance': round(distance, 2),
                'score': 0.0,
                'pitch_type': pitch_type,
                'comparison_video': None
            })

        # 비교 영상 생성 (여기로 이동)
        comparison_filename = f"comparison_{uuid.uuid4().hex}.mp4"
        comparison_path = os.path.join("outputs", comparison_filename)

        #동영상 위에 선그리기
        source_video = request.json.get('source_video')
        if not source_video or not os.path.exists(source_video):
            return jsonify({'error': '원본 trimmed 영상 경로 누락 또는 존재하지 않음'}), 400

        top_joints = summarize_top_joints(diff_seq, labels, top_k=4)
        visualize_pose_feedback(ref, test, labels, diff_seq, top_joints, comparison_path, source_video=source_video)

        
        # 정량적 기준 재조정
        wrong_ratio = sum(labels) / len(labels)

        if score >= 80 and wrong_ratio < 0.1:
            feedback_text = "자세가 매우 적절합니다!"
        elif score >= 60:
            feedback_text = "전반적으로 양호하나 약간의 보완이 필요합니다."
        else:
            feedback_lines = []
            for j in top_joints:
                if j in JOINT_FEEDBACK_MAP:
                    feedback_lines.append(JOINT_FEEDBACK_MAP[j])
                else:
                    continue  # 설명 없는 관절은 생략하거나 필요 시 매핑 추가

            feedback_text = (
                "💡 참고: 영상에서 '빨간 선'은 LSTM 모델이 이상하다고 판단한 프레임 중\n"
                "'주요 관절'에 해당하는 부위를 강조한 것입니다.\n\n"
                "다음 부위의 보완이 필요합니다:\n- " + "\n- ".join(feedback_lines)
            )

        return jsonify({
            'feedback': feedback_text,
            'distance': round(distance, 2),
            'score': score,
            'pitch_type': pitch_type,
            'comparison_video': comparison_filename
        })

    except Exception as e:
        print(f"❌ 서버 내부 오류: {e}")
        return jsonify({'error': '서버 오류 발생', 'detail': str(e)}), 500


#스트리밍 mp4
@app.route('/video/<filename>')
def serve_video(filename):
    path = os.path.join('outputs', filename)
    if not os.path.exists(path):
        return jsonify({'error': '비교 영상이 존재하지 않습니다.'}), 404

    print(f"📤 영상 전송 시작: {filename}")
    return send_file(path, mimetype='video/mp4', as_attachment=False)


def rotate_frame_if_needed(frame):
    h, w = frame.shape[:2]
    if w > h:
        return cv2.rotate(frame, cv2.ROTATE_90_CLOCKWISE)
    return frame

def trim_video_opencv(input_path, output_path, start_time, end_time):
    cap = cv2.VideoCapture(input_path)
    if not cap.isOpened():
        print("❌ 원본 영상 열기 실패")
        return

    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    if fps == 0 or total_frames == 0:
        cap.release()
        print("❌ FPS 또는 총 프레임 수가 0입니다.")
        return

    start_frame = int(start_time * fps)
    end_frame = min(int(end_time * fps), total_frames - 1)

    # ✅ 첫 프레임 읽기
    ret, first_frame = cap.read()
    if not ret:
        cap.release()
        print("❌ 첫 프레임 읽기 실패")
        return

    rotated_first_frame = rotate_frame_if_needed(first_frame)
    height, width = rotated_first_frame.shape[:2]
    print(f"🎥 Trim된 영상 해상도: {width}x{height} (가로x세로)")

    # 다시 시작 위치로 이동
    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)

    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

    frame_idx = 0
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret or frame_idx > end_frame:
            break

        if start_frame <= frame_idx <= end_frame:
            frame = rotate_frame_if_needed(frame)
            out.write(frame)

        frame_idx += 1

    cap.release()
    out.release()
    print(f"✅ 저장 완료: {output_path}")


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
