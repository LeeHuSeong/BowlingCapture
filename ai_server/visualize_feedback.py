# visualize_feedback.py
import numpy as np
import cv2

JOINT_FEEDBACK_MAP = {
    5: "왼팔의 움직임이 불안정합니다.",
    6: "오른팔의 움직임이 불안정합니다.",
    7: "왼쪽 팔꿈치를 더 고정할 필요가 있습니다.",
    8: "오른쪽 팔꿈치를 더 고정할 필요가 있습니다.",
    9: "왼손의 흔들림이 큽니다.",
    10: "오른손의 흔들림이 큽니다.",
    11: "왼쪽 엉덩이의 움직임을 안정시켜야 합니다.",
    12: "오른쪽 엉덩이의 흔들림이 큽니다.",
    13: "왼무릎을 고정해서 안정적인 자세를 유지하세요.",
    14: "오른무릎의 위치를 일정하게 유지하세요.",
    15: "왼발의 흔들림이 큽니다.",
    16: "오른발의 흔들림을 줄이세요."
}

def visualize_pose_feedback(ref, test, labels, save_path, source_video):
    cap = cv2.VideoCapture(source_video)
    fps = cap.get(cv2.CAP_PROP_FPS) or 30
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    out = cv2.VideoWriter(save_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (width, height))

    frame_idx = 0
    for i in range(min(len(ref), len(test), len(labels))):
        ret, frame = cap.read()
        if not ret:
            print(f"⚠️ 프레임 {frame_idx} 읽기 실패")
            break

        for j in range(17):
            x1, y1, c1 = ref[i][j]
            x2, y2, c2 = test[i][j]

            # 정규화된 좌표 → 픽셀 좌표
            x1 = int(x1 * width) if x1 <= 1 else int(x1)
            y1 = int(y1 * height) if y1 <= 1 else int(y1)
            x2 = int(x2 * width) if x2 <= 1 else int(x2)
            y2 = int(y2 * height) if y2 <= 1 else int(y2)

            if c1 > 0.3 and c2 > 0.3:
                color = (0, 255, 0) if labels[i] == 0 else (0, 0, 255)
                cv2.line(frame, (x1, y1), (x2, y2), color, 2)

        out.write(frame)
        frame_idx += 1

    cap.release()
    out.release()
    print(f"📼 시각화 저장 완료: {save_path}, 길이: {frame_idx}, fps: {fps}")

def summarize_top_joints(diff_seq, labels, top_k=2):
    joint_error_sum = np.zeros(17)

    for i, label in enumerate(labels):
        if label == 1:
            diffs = diff_seq[i].reshape(17, 2)
            mags = np.linalg.norm(diffs, axis=1)
            joint_error_sum += mags

    top_joint_indices = np.argsort(joint_error_sum)[-top_k:][::-1]  # 큰 순서로
    return list(top_joint_indices)
