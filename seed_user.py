#!/usr/bin/env python3
"""
BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - SEED USER & HỒ SƠ BỆNH ÁN
Tự động tạo tài khoản đăng nhập + mật khẩu và nạp hồ sơ bệnh án chuẩn vào Supabase.
Cách dùng:
    python3 seed_user.py [so_dien_thoai] [mat_khau] [ho_ten]
Ví dụ:
    python3 seed_user.py 0338976989 123456 "NGUYỄN KIỀU LINH"
"""

import sys
import os
import json
import urllib.request
import urllib.error

SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://tfnxmcseexinbgkzwmwh.supabase.co")

def get_service_key():
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if key:
        return key
    env_file = os.path.join(os.path.dirname(__file__), ".env")
    if os.path.exists(env_file):
        with open(env_file, "r") as f:
            for line in f:
                if line.strip().startswith("SUPABASE_SERVICE_ROLE_KEY="):
                    return line.strip().split("=", 1)[1].strip()
    return ""

SERVICE_ROLE_KEY = get_service_key()

def clean_phone(phone: str) -> str:
    digits = "".join(c for c in phone if c.isdigit())
    if digits.startswith("84"):
        digits = "0" + digits[2:]
    return digits

def request_json(url, method="GET", data=None, headers=None):
    if not SERVICE_ROLE_KEY:
        print("❌ Lỗi: Chưa cấu hình SUPABASE_SERVICE_ROLE_KEY trong file .env hoặc biến môi trường!")
        return {}
    hdrs = {
        "apikey": SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    if headers:
        hdrs.update(headers)
    body = json.dumps(data).encode("utf-8") if data is not None else None
    req = urllib.request.Request(url, data=body, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            content = resp.read().decode("utf-8")
            return json.loads(content) if content else {}
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode("utf-8")
        try:
            return {"_error": True, "status": e.code, "body": json.loads(err_msg)}
        except:
            return {"_error": True, "status": e.code, "body": err_msg}

def seed_user(phone="0338976989", password="123456", name="NGUYỄN KIỀU LINH", patient_code="2600168496", visit_date="09/10/2026 14:04"):
    phone = clean_phone(phone)
    email = f"{phone}@hungvuong.hospital"
    print(f"\n========================================================")
    print(f"🏥 BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - CẤP TÀI KHOẢN & BỆNH ÁN")
    print(f"👉 Số điện thoại: {phone}")
    print(f"👉 Mật khẩu:      {password}")
    print(f"👉 Bệnh nhân:     {name} (Mã: {patient_code})")
    print(f"👉 Ngày khám:     {visit_date}")
    print(f"========================================================")

    # 1. TẠO HOẶC CẬP NHẬT TÀI KHOẢN AUTH TRÊN SUPABASE
    print("\n[1/4] Đang thiết lập tài khoản đăng nhập trên Supabase Auth...")
    users_resp = request_json(f"{SUPABASE_URL}/auth/v1/admin/users")
    existing_user = None
    if isinstance(users_resp, dict) and "users" in users_resp:
        for u in users_resp["users"]:
            if u.get("email") == email:
                existing_user = u
                break

    if existing_user:
        user_id = existing_user["id"]
        update_resp = request_json(
            f"{SUPABASE_URL}/auth/v1/admin/users/{user_id}",
            method="PUT",
            data={
                "password": password,
                "user_metadata": {
                    "phone": phone,
                    "full_name": name
                }
            }
        )
        print(f"  ✅ Tài khoản đã có sẵn -> Đã cập nhật mật khẩu mới: '{password}'")
    else:
        create_resp = request_json(
            f"{SUPABASE_URL}/auth/v1/admin/users",
            method="POST",
            data={
                "email": email,
                "password": password,
                "email_confirm": True,
                "user_metadata": {
                    "phone": phone,
                    "full_name": name
                }
            }
        )
        if isinstance(create_resp, dict) and create_resp.get("_error"):
            print(f"  ❌ Lỗi tạo tài khoản: {create_resp}")
        else:
            print(f"  ✅ Tạo tài khoản thành công! SĐT: {phone} | Mật khẩu: '{password}'")

    # 2. XÓA BỆNH ÁN CŨ ĐỂ CẬP NHẬT MỚI
    print("\n[2/4] Đang làm sạch dữ liệu bệnh án cũ của SĐT này...")
    request_json(f"{SUPABASE_URL}/rest/v1/medical_history?phone=eq.{phone}", method="DELETE")
    request_json(f"{SUPABASE_URL}/rest/v1/lab_results?phone=eq.{phone}", method="DELETE")
    request_json(f"{SUPABASE_URL}/rest/v1/prescriptions?phone=eq.{phone}", method="DELETE")
    print("  ✅ Đã sẵn sàng nạp dữ liệu mới.")

    # 3. NẠP HỒ SƠ BỆNH ÁN
    print("\n[3/4] Đang nạp hồ sơ bệnh án (Lịch sử khám, Cận lâm sàng, Đơn thuốc)...")
    
    # 3.1. Lịch sử khám bệnh
    med_history = [{
        "phone": phone,
        "visit_code": patient_code,
        "visit_date": "2026-10-09",
        "department": "[25329] Bệnh viện đa khoa Tư nhân Hùng Vương",
        "doctor_name": "BS. Điều trị",
        "reason": "Khám ngoại trú theo dõi",
        "diagnosis": "Viêm mũi xoang mạn tính (polyp mũi 2 bên)",
        "treatment": "Ngoại trú"
    }]
    r1 = request_json(f"{SUPABASE_URL}/rest/v1/medical_history", method="POST", data=med_history, headers={"Prefer": "return=minimal"})
    print("  ✅ Đã chèn Lịch sử khám bệnh.")

    # 3.2. Kết quả cận lâm sàng
    lab_results = [
        {
            "phone": phone,
            "test_code": "CLS-01",
            "test_name": "Điện tim thường",
            "category": "Cận lâm sàng",
            "doctor_name": "Nguyễn Việt Anh",
            "test_date": "2026-10-09",
            "conclusion": "Nhịp xoang, tần số 68 ck/phút. Trục trung gian",
            "details": {"readings": []},
            "status": "Đã có kết quả"
        },
        {
            "phone": phone,
            "test_code": "CLS-02",
            "test_name": "Siêu âm ổ bụng",
            "category": "Cận lâm sàng",
            "doctor_name": "Tạ Thị Hà",
            "test_date": "2026-10-09",
            "conclusion": "Hình ảnh siêu âm hiện tại không thấy bất thường.",
            "details": {"readings": [
                "- GAN: Kích thước bình thường, nhu mô đều, không có khối khu trú.",
                "- ĐƯỜNG MẬT: Trong gan không giãn, không có sỏi.",
                "- THẬN: Nhu mô đều, ranh giới rõ, không có sỏi.",
                "- Ổ BỤNG: Không có dịch tự do."
            ]},
            "status": "Đã có kết quả"
        },
        {
            "phone": phone,
            "test_code": "CLS-03",
            "test_name": "Khám chuyên khoa Tai – Mũi – Họng",
            "category": "Cận lâm sàng",
            "doctor_name": "Lò Thị Xuân",
            "test_date": "2026-10-09",
            "conclusion": "Viêm mũi xoang mạn tính (polyp mũi 2 bên).",
            "details": {"readings": [
                "- MŨI: Khe mũi giữa phải có polyp độ IV, khe mũi giữa trái có polyp độ III",
                "- HỌNG: Niêm mạc thành sau họng đỏ, có tổ chức hạt viêm."
            ]},
            "status": "Đã có kết quả"
        },
        {
            "phone": phone,
            "test_code": "CLS-04",
            "test_name": "Chụp X-quang ngực thẳng [số hóa 1 phim]",
            "category": "Cận lâm sàng",
            "doctor_name": "Đào Văn Trí",
            "test_date": "2026-10-09",
            "conclusion": "Hiện tại không thấy hình ảnh tổn thương trên phim chụp.",
            "details": {"readings": ["- Bóng tim không to.", "- Nhu mô phổi hai bên sáng đều."]},
            "status": "Đã có kết quả"
        }
    ]
    r2 = request_json(f"{SUPABASE_URL}/rest/v1/lab_results", method="POST", data=lab_results, headers={"Prefer": "return=minimal"})
    print("  ✅ Đã chèn 4 kết quả Cận lâm sàng.")

    # 3.3. Đơn thuốc
    prescriptions = [{
        "phone": phone,
        "prescription_code": "DT-2026-8892",
        "doctor_name": "BS. Điều trị",
        "department": "Khoa Khám bệnh",
        "diagnosis": "Viêm mũi xoang mạn tính",
        "prescription_date": "2026-10-09",
        "instructions": "Dùng thuốc đúng liều lượng chỉ định",
        "items": [
            {"stt": 1, "thuoc": "Benita", "so_luong": 1, "don_gia": "110.000", "thanh_tien": "110.000", "cach_dung": "2 nhát / bên/ lần * 1 lần / ngày"},
            {"stt": 2, "thuoc": "Curam 1000mg", "so_luong": 14, "don_gia": "7.254", "thanh_tien": "101.556", "cach_dung": "1 viên/ lần* 2 lần/ ngày* 7 ngày"},
            {"stt": 3, "thuoc": "Medovent 30mg", "so_luong": 14, "don_gia": "2.135", "thanh_tien": "29.890", "cach_dung": "1 viên/ lần* 2 lần/ ngày* 7 ngày"},
            {"stt": 4, "thuoc": "Medrol <16>", "so_luong": 5, "don_gia": "4.480", "thanh_tien": "22.400", "cach_dung": "1 viên/ lần* 1 lần/ ngày* 5 ngày"},
            {"stt": 5, "thuoc": "Promax iNO <150> nhát xịt", "so_luong": 1, "don_gia": "200.000", "thanh_tien": "200.000", "cach_dung": "xịt mũi ngày 3 lần , mỗi lần 2 nhát / bên"}
        ]
    }]
    r3 = request_json(f"{SUPABASE_URL}/rest/v1/prescriptions", method="POST", data=prescriptions, headers={"Prefer": "return=minimal"})
    print("  ✅ Đã chèn Đơn thuốc.")

    print("\n[4/4] KIỂM TRA ĐĂNG NHẬP THỬ NGHIỆM...")
    login_payload = json.dumps({"email": email, "password": password}).encode("utf-8")
    login_req = urllib.request.Request(
        f"{SUPABASE_URL}/auth/v1/token?grant_type=password",
        data=login_payload,
        headers={"apikey": "sb_publishable_TiioCrJ1dydHkTy3EyP9mg_gIeBphuV", "Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(login_req) as resp:
            login_data = json.loads(resp.read().decode())
            print(f"  🎉 ĐĂNG NHẬP THÀNH CÔNG! Token hợp lệ, sẵn sàng đăng nhập trên Web!")
    except Exception as e:
        print(f"  ⚠️ Cảnh báo kiểm tra đăng nhập: {e}")

    print("\n========================================================")
    print(f"✨ HOÀN TẤT! BÂY GIỜ BẠN CÓ THỂ MỞ TRANG WEB:")
    print(f"👉 URL: http://localhost:4321/ho-so")
    print(f"👉 Số điện thoại đăng nhập: {phone}")
    print(f"👉 Mật khẩu đăng nhập:      {password}")
    print(f"========================================================\n")

if __name__ == "__main__":
    p_phone = sys.argv[1] if len(sys.argv) > 1 else "0338976989"
    p_pass = sys.argv[2] if len(sys.argv) > 2 else "123456"
    p_name = sys.argv[3] if len(sys.argv) > 3 else "NGUYỄN KIỀU LINH"
    seed_user(p_phone, p_pass, p_name)
