import numpy as np
import cv2
import subprocess
import os

JOINT_FEEDBACK_MAP = {
    0: "머리 위치가 흔들리고 있습니다.",
    1: "왼쪽 어깨의 움직임을 안정시켜야 합니다.",
    2: "오른쪽 어깨의 움직임을 안정시켜야 합니다.",
    3: "왼쪽 팔꿈치를 더 고정할 필요가 있습니다.",
    4: "오른쪽 팔꿈치를 더 고정할 필요가 있습니다.",
    5: "왼팔의 움직임이 불안정합니다.",
    6: "오른팔의 움직임이 불안정합니다.",
    7: "왼쪽 손목이 많이 흔들립니다.",
    8: "오른쪽 손목이 많이 흔들립니다.",
    9: "왼손의 흔들림이 큽니다.",
    10: "오른손의 흔들림이 큽니다.",
    11: "왼쪽 엉덩이의 움직임을 안정시켜야 합니다.",
    12: "오른쪽 엉덩이의 흔들림이 큽니다.",
    13: "왼무릎을 고정해서 안정적인 자세를 유지하세요.",
    14: "오른무릎의 위치를 일정하게 유지하세요.",
    15: "왼발의 흔들림이 큽니다.",
    16: "오른발의 흔들림을 줄이세요."
}

def convert_video_with_ffmpeg(input_path, output_path):
    command = [
        'ffmpeg', '-y',
        '-i', input_path,
        '-vcodec', 'libx264',
        '-pix_fmt', 'yuv420p',
        '-vf', "scale='trunc(iw/2)*2:trunc(ih/2)*2'",
        output_path
    ]
    try:
        subprocess.run(command, check=True)
        print(f"✅ ffmpeg 변환 완료: {output_path}")
    except subprocess.CalledProcessError as e:
        print("❌ ffmpeg 변환 실패:", e)

def rotate_keypoints_90ccw(keypoints):
    return [(y, x, c) for (x, y, c) in keypoints]

def visualize_pose_feedback(ref, test, labels, diff_seq, top_joints, save_path, source_video):
    print(f"🔎 test length: {len(test)}, labels: {len(labels)}")

    cap = cv2.VideoCapture(source_video)
    fps = cap.get(cv2.CAP_PROP_FPS)

    ret, first_frame = cap.read()
    if not ret:
        print("❌ 첫 프레임 읽기 실패")
        return
    cap.set(cv2.CAP_PROP_POS_FRAMES, 0)

    frame_height, frame_width = first_frame.shape[:2]
    PADDING = 40
    canvas_height = frame_height + PADDING * 2
    canvas_width = frame_width
    output_size = (canvas_width, canvas_height)

    temp_save_path = save_path.replace(".mp4", "_temp.mp4")
    out = cv2.VideoWriter(temp_save_path, cv2.VideoWriter_fourcc(*'mp4v'), fps, output_size)

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

    frame_written = 0

    for i in range(min(len(test), len(labels))):
        ret, frame = cap.read()
        if not ret:
            print(f"⚠️ 프레임 {i} 읽기 실패")
            break

        canvas = np.full((canvas_height, canvas_width, 3), 255, dtype=np.uint8)
        y_offset = PADDING
        canvas[y_offset:y_offset + frame_height, 0:frame_width] = frame

        canvas_h, canvas_w = canvas.shape[:2]
        rotated_keypoints = rotate_keypoints_90ccw(test[i])

        # 관절 차이 크기 계산
        diffs = diff_seq[i].reshape(17, 2)
        mags = np.linalg.norm(diffs, axis=1)
        threshold = np.percentile(mags, 75)  # 상위 25% 이상한 관절

        # 원 그리기 (정상/이상 공통 색: 초록)
        for j in range(17):
            x, y, c = rotated_keypoints[j]
            if c < 0.3:
                continue
            px = int(x * canvas_w)
            py = int(y * (canvas_h - 2 * PADDING)) + y_offset
            cv2.circle(canvas, (px, py), 4, (0, 255, 0), -1)
        
        # LSTM에서 이상으로 판단된 프레임만 체크
        is_wrong_frame = labels[i] == 1

        # 선 그리기 (정상은 초록, 이상 관절끼리 연결된 선만 빨강)
        for a, b in POSE_PAIRS:
            x1, y1, c1 = rotated_keypoints[a]
            x2, y2, c2 = rotated_keypoints[b]
            if c1 > 0.3 and c2 > 0.3:
                # 관절 a 또는 b가 threshold 이상이면 이상한 관절
                # threshold 기준 완화 (0.1 이상인 경우만)
                is_abnormal = (
                    labels[i] == 1 and
                    (a in top_joints or b in top_joints)
                )
                color = (0, 0, 255) if is_abnormal else (0, 255, 0)
                thickness = 5 if is_abnormal else 2

                x1 = int(x1 * canvas_w)
                y1 = int(y1 * (canvas_h - 2 * PADDING)) + y_offset
                x2 = int(x2 * canvas_w)
                y2 = int(y2 * (canvas_h - 2 * PADDING)) + y_offset
                cv2.line(canvas, (x1, y1), (x2, y2), color, thickness)
            
        print(f"프레임 {i} - 이상 관절:", [j for j in range(17) if mags[j] > threshold])
        out.write(canvas)
        frame_written += 1

    cap.release()
    out.release()
    print(f"📼 임시 시각화 저장 완료: {temp_save_path} (fps: {fps}, frames_written: {frame_written})")

    convert_video_with_ffmpeg(temp_save_path, save_path)

    if os.path.exists(temp_save_path):
        os.remove(temp_save_path)


def summarize_top_joints(diff_seq, labels, top_k=4):
    joint_error_sum = np.zeros(17)
    for i, label in enumerate(labels):
        if label == 1:
            diffs = diff_seq[i].reshape(17, 2)
            mags = np.linalg.norm(diffs, axis=1)
            joint_error_sum += mags * (mags > 0.1)
    sorted_indices = list(np.argsort(joint_error_sum)[::-1])
    return [j for j in sorted_indices if joint_error_sum[j] > 0][:top_k]