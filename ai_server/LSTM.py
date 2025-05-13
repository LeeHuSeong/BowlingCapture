#LSTM.py
import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.sequence import pad_sequences

def predict_feedback(diff_seq, model_path="lstm_model.h5"):
    model = load_model(model_path)

    padded = pad_sequences([diff_seq], padding='post', dtype='float32')
    pred = model.predict(padded)

    # 예시 분류라면 → label decoding
    label_map = {0: "좋습니다!", 1: "왼팔이 너무 일찍 펴졌어요", 2: "무릎 굽힘이 부족해요"}
    predicted_label = np.argmax(pred)
    return label_map.get(predicted_label, "분석 결과를 해석할 수 없습니다.")

# 데이터 로드
def load_dataset(keypoint_dir):
    X, y = [], []
    label_map = {"pro": 0, "cranker": 1}  # 예시, 필요시 수정

    for filename in os.listdir(keypoint_dir):
        if filename.endswith(".npy"):
            label_prefix = filename.split('_')[0]  # "pro_001.npy" → "pro"
            label = label_map.get(label_prefix.lower())
            if label is not None:
                data = np.load(os.path.join(keypoint_dir, filename))  # shape: (N, 17, 3)
                sequence = np.array([frame[:, :2].flatten() for frame in data])  # (N, 34)
                X.append(sequence)
                y.append(label)

    return np.array(X, dtype=np.float32), np.array(y)

# 모델 정의
def build_model(input_shape, num_classes):
    model = tf.keras.Sequential([
        tf.keras.layers.Masking(mask_value=0.0, input_shape=input_shape),
        tf.keras.layers.LSTM(64, return_sequences=True),
        tf.keras.layers.LSTM(64),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(num_classes, activation='softmax')
    ])
    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])
    return model

# 학습 시작
if __name__ == "__main__":
    keypoint_dir = "data/keypoints"
    X, y = load_dataset(keypoint_dir)

    # 패딩 (모든 시퀀스를 동일 길이로)
    X = tf.keras.preprocessing.sequence.pad_sequences(X, padding='post', dtype='float32')

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

    model = build_model(input_shape=X_train.shape[1:], num_classes=len(set(y)))
    model.summary()

    model.fit(X_train, y_train, epochs=30, validation_data=(X_test, y_test))

    model.save("lstm_model.h5")
    print("✅ 모델 저장 완료: lstm_model.h5")
