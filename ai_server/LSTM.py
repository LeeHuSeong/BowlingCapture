import os
import sys
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Masking
from tensorflow.keras.preprocessing.sequence import pad_sequences

from tensorflow.keras.layers import TimeDistributed


# 구질 인자 입력 받기
if len(sys.argv) < 2:
    print("❗ 사용법: python LSTM.py twohand")
    sys.exit()

pitch_type = sys.argv[1].lower()
dataset_dir = os.path.join("Data/lstm_dataset", pitch_type)
model_path = f"lstm_{pitch_type}.h5"

def load_lstm_dataset(folder):
    X, y = [], []
    for filename in os.listdir(folder):
        if filename.endswith("_diff.npy"):
            diff_path = os.path.join(folder, filename)
            label_path = diff_path.replace("_diff.npy", "_label.npy")
            
            try:
                diff_seq = np.load(diff_path)
                label_seq = np.load(label_path)

                X.append(diff_seq)
                y.append(label_seq)
            except Exception as e:
                print(f"⚠️ 오류: {filename} → {e}")
    return X, y



def build_model(input_shape):
    model = Sequential([
        Masking(mask_value=0.0, input_shape=input_shape),
        LSTM(64, return_sequences=True),  # 시퀀스 유지
        LSTM(64, return_sequences=True),  # 🔁 두 번째 LSTM도 시퀀스 유지해야 함
        TimeDistributed(Dense(64, activation='relu')),
        TimeDistributed(Dense(1, activation='sigmoid'))  # ✅ 프레임별 이진 분류
    ])
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    return model

# 데이터 로딩 및 전처리
X, y = load_lstm_dataset(dataset_dir)
if len(X) < 3:
    print(f"❌ 데이터가 너무 적습니다: {len(X)}개")
    sys.exit()

print(f"📂 {pitch_type} 데이터 개수: {len(X)}")

X = pad_sequences(X, padding='post', dtype='float32')         # (batch, maxlen, 34)
y = pad_sequences(y, padding='post', dtype='float32')         # (batch, maxlen, 1)

print("✅ X shape:", X.shape)
print("✅ y shape:", y.shape)
print("✅ y unique:", np.unique(y))
print("✅ X max:", np.max(X))
print("✅ X min:", np.min(X))
print("✅ X mean:", np.mean(X))

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

model = build_model(input_shape=X_train.shape[1:])
model.summary()

model.fit(X_train, y_train, epochs=30, validation_data=(X_test, y_test))

model.save(model_path)
print(f"✅ 모델 저장 완료: {model_path}")
