from flask import Flask, request, jsonify
import numpy as np
import os
import tensorflow as tf

app = Flask(__name__)

# 예시로 LSTM 모델 불러오기 (학습 후 저장된 경로 필요)
LSTM_MODEL_PATH = 'lstm_model.h5'
if os.path.exists(LSTM_MODEL_PATH):
    lstm_model = tf.keras.models.load_model(LSTM_MODEL_PATH)
else:
    lstm_model = None
    print("⚠️ LSTM 모델을 찾을 수 없습니다!")

@app.route('/get_feedback', methods=['POST'])
def get_feedback():
    data = request.json
    npy_path = data.get('npy_path')

    if not npy_path or not os.path.exists(npy_path):
        return jsonify({'error': 'Keypoint 파일이 존재하지 않습니다.'}), 400

    try:
        keypoints = np.load(npy_path)
        keypoints = keypoints.reshape((1, keypoints.shape[0], keypoints.shape[1] * keypoints.shape[2]))

        if lstm_model is None:
            return jsonify({'error': 'LSTM 모델이 로드되지 않았습니다.'}), 500

        prediction = lstm_model.predict(keypoints)
        feedback = decode_prediction(prediction[0])  # 커스텀 함수로 예측 해석

        return jsonify({'feedback': feedback})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def decode_prediction(pred):
    # 예시: 가장 높은 softmax 확률의 인덱스를 문장으로 매핑
    classes = ["균형 좋아요!", "팔이 너무 빨라요!", "허리가 처졌어요!", "좋은 자세입니다!"]
    idx = int(np.argmax(pred))
    return classes[idx]

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
