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

def visualize_pose_feedback(ref, test, labels, save_path, source_video, rotation=0):
    import numpy as np
    import cv2

    def is_normalized(val):
        return 0.0 <= val <= 1.0

    def rotate_keypoints_normalized(keypoints, angle):
        rotated = []
        for x, y, c in keypoints:
            if angle == 90:
                new_x = 1.0 - y
                new_y = x
            elif angle == 180:
                new_x = 1.0 - x
                new_y = 1.0 - y
            elif angle == 270:
                new_x = y
                new_y = 1.0 - x
            else:
                new_x, new_y = x, y
            rotated.append((new_x, new_y, c))
        return np.array(rotated)

    print(f"🔎 test length: {len(test)}, labels: {len(labels)}")

    cap = cv2.VideoCapture(source_video)
    fps = cap.get(cv2.CAP_PROP_FPS)

    POSE_PAIRS = [
        (0, 1), (1, 3), (0, 2), (2, 4),
        (5, 7), (7, 9),
        (6, 8), (8, 10),
        (5, 6),
        (5, 11), (6, 12),
        (11, 12),
        (11, 13), (13, 15),
        (12, 14), (14, 16)
    ]

    ret, first_frame = cap.read()
    if not ret:
        print("❌ 첫 프레임 읽기 실패")
        return
    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)

    frame_height, frame_width = first_frame.shape[:2]
    PADDING = 40
    canvas_height = frame_height + PADDING * 2
    canvas_width = frame_width

    if rotation in [90, 270]:
        output_size = (canvas_height, canvas_width)
    else:
        output_size = (canvas_width, canvas_height)

    out = cv2.VideoWriter(save_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, output_size)

    for i in range(min(len(test), len(labels))):
        ret, frame = cap.read()
        if not ret:
            print(f"⚠️ 프레임 {i} 읽기 실패")
            break

        canvas = np.full((canvas_height, canvas_width, 3), 255, dtype=np.uint8)
        y_offset = PADDING
        canvas[y_offset:y_offset + frame_height, 0:frame_width] = frame

        # ✅ 정규화 좌표 회전
        rotated_kpts = rotate_keypoints_normalized(test[i], rotation)

        label = int(labels[i])
        color = (0, 255, 0) if label == 0 else (0, 0, 255)

        for j in range(17):
            x, y, c = rotated_kpts[j]
            if c < 0.3:
                continue
            x = int(x * frame_width)
            y = int(y * frame_height) + y_offset
            cv2.circle(canvas, (x, y), 4, color, -1)

        for a, b in POSE_PAIRS:
            x1, y1, c1 = rotated_kpts[a]
            x2, y2, c2 = rotated_kpts[b]
            if c1 > 0.3 and c2 > 0.3:
                x1 = int(x1 * frame_width)
                y1 = int(y1 * frame_height) + y_offset
                x2 = int(x2 * frame_width)
                y2 = int(y2 * frame_height) + y_offset
                cv2.line(canvas, (x1, y1), (x2, y2), color, 2)

        if rotation == 90:
            canvas = cv2.rotate(canvas, cv2.ROTATE_90_CLOCKWISE)
        elif rotation == 180:
            canvas = cv2.rotate(canvas, cv2.ROTATE_180)
        elif rotation == 270:
            canvas = cv2.rotate(canvas, cv2.ROTATE_90_COUNTERCLOCKWISE)

        out.write(canvas)

    cap.release()
    out.release()
    print(f"🎬 시각화 저장 완료: {save_path} (fps: {fps})")


def summarize_top_joints(diff_seq, labels, top_k=2):
    joint_error_sum = np.zeros(17)
    for i, label in enumerate(labels):
        if label == 1:
            diffs = diff_seq[i].reshape(17, 2)
            mags = np.linalg.norm(diffs, axis=1)
            joint_error_sum += mags
    return list(np.argsort(joint_error_sum)[-top_k:][::-1])