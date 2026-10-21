-- =========================================================================
-- BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - LỆNH CẤP TÀI KHOẢN & HỒ SƠ BỆNH ÁN
-- HƯỚNG DẪN:
-- 1. Bạn có thể sửa số điện thoại và mật khẩu ở dòng 120 - 121 (nếu muốn đổi user):
--    - target_phone    : Số điện thoại đăng nhập (ví dụ: '0338976909')
--    - target_password : Mật khẩu đăng nhập (ví dụ: '070306')
-- 2. Dán TOÀN BỘ file này vào Supabase -> SQL Editor -> Nhấn RUN.
-- Script tự động:
--    - Tự động sửa kiểu dữ liệu visit_date sang TEXT và gỡ ràng buộc cũ nếu có.
--    - Tạo tài khoản đăng nhập + mã hóa mật khẩu trên Supabase Auth (hoặc cập nhật nếu đã có).
--    - Nạp toàn bộ Hồ sơ bệnh án: Lịch sử khám, Kết quả cận lâm sàng (4 xét nghiệm), Đơn thuốc.
-- =========================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- =========================================================================
-- BƯỚC 1: TỰ ĐỘNG CHUẨN HÓA CẤU TRÚC BẢNG (FIX LỖI KIỂU DATE VÀ RÀNG BUỘC CŨ)
-- =========================================================================
DO $$
BEGIN
    -- 1. Xử lý bảng public.medical_history
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'medical_history') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'visit_code') THEN
            ALTER TABLE public.medical_history ALTER COLUMN visit_code DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'department') THEN
            ALTER TABLE public.medical_history ALTER COLUMN department DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'doctor_name') THEN
            ALTER TABLE public.medical_history ALTER COLUMN doctor_name DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'reason') THEN
            ALTER TABLE public.medical_history ALTER COLUMN reason DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'diagnosis') THEN
            ALTER TABLE public.medical_history ALTER COLUMN diagnosis DROP NOT NULL;
        END IF;
        
        -- Chuyển visit_date sang TEXT nếu đang là DATE/TIMESTAMP
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'visit_date') THEN
            ALTER TABLE public.medical_history ALTER COLUMN visit_date DROP DEFAULT;
            ALTER TABLE public.medical_history ALTER COLUMN visit_date TYPE TEXT USING visit_date::text;
            ALTER TABLE public.medical_history ALTER COLUMN visit_date SET DEFAULT '09/10/2026 14:04';
        ELSE
            ALTER TABLE public.medical_history ADD COLUMN visit_date TEXT DEFAULT '09/10/2026 14:04';
        END IF;
    END IF;

    -- 2. Xử lý bảng public.lab_results
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'lab_results') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'test_code') THEN
            ALTER TABLE public.lab_results ALTER COLUMN test_code DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'test_name') THEN
            ALTER TABLE public.lab_results ALTER COLUMN test_name DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'category') THEN
            ALTER TABLE public.lab_results ALTER COLUMN category DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'doctor_name') THEN
            ALTER TABLE public.lab_results ALTER COLUMN doctor_name DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'test_date') THEN
            ALTER TABLE public.lab_results ALTER COLUMN test_date DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'details') THEN
            ALTER TABLE public.lab_results ALTER COLUMN details DROP NOT NULL;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'lab_results' AND column_name = 'visit_date') THEN
            ALTER TABLE public.lab_results ALTER COLUMN visit_date DROP DEFAULT;
            ALTER TABLE public.lab_results ALTER COLUMN visit_date TYPE TEXT USING visit_date::text;
            ALTER TABLE public.lab_results ALTER COLUMN visit_date SET DEFAULT '09/10/2026 14:04';
        ELSE
            ALTER TABLE public.lab_results ADD COLUMN visit_date TEXT DEFAULT '09/10/2026 14:04';
        END IF;
    END IF;

    -- 3. Xử lý bảng public.prescriptions
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'prescriptions') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'prescriptions' AND column_name = 'prescription_code') THEN
            ALTER TABLE public.prescriptions ALTER COLUMN prescription_code DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'prescriptions' AND column_name = 'doctor_name') THEN
            ALTER TABLE public.prescriptions ALTER COLUMN doctor_name DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'prescriptions' AND column_name = 'department') THEN
            ALTER TABLE public.prescriptions ALTER COLUMN department DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'prescriptions' AND column_name = 'diagnosis') THEN
            ALTER TABLE public.prescriptions ALTER COLUMN diagnosis DROP NOT NULL;
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'prescriptions' AND column_name = 'prescription_date') THEN
            ALTER TABLE public.prescriptions ALTER COLUMN prescription_date DROP NOT NULL;
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'prescriptions' AND column_name = 'visit_date') THEN
            ALTER TABLE public.prescriptions ALTER COLUMN visit_date DROP DEFAULT;
            ALTER TABLE public.prescriptions ALTER COLUMN visit_date TYPE TEXT USING visit_date::text;
            ALTER TABLE public.prescriptions ALTER COLUMN visit_date SET DEFAULT '09/10/2026 14:04';
        ELSE
            ALTER TABLE public.prescriptions ADD COLUMN visit_date TEXT DEFAULT '09/10/2026 14:04';
        END IF;
    END IF;
END $$;

-- Tạo bảng chuẩn nếu chưa tồn tại
CREATE TABLE IF NOT EXISTS public.medical_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    patient_code TEXT NOT NULL DEFAULT '2600168496',
    patient_name TEXT NOT NULL DEFAULT 'NGUYỄN KIỀU LINH',
    hospital_name TEXT NOT NULL DEFAULT '[25329] Bệnh viện đa khoa Tư nhân Hùng Vương',
    visit_date TEXT NOT NULL DEFAULT '09/10/2026 14:04',
    treatment_type TEXT NOT NULL DEFAULT 'Ngoại trú',
    symptoms TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.lab_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    patient_code TEXT NOT NULL DEFAULT '2600168496',
    patient_name TEXT NOT NULL DEFAULT 'NGUYỄN KIỀU LINH',
    visit_date TEXT NOT NULL DEFAULT '09/10/2026 14:04',
    test_title TEXT NOT NULL,
    doctor_reading TEXT NOT NULL,
    readings JSONB DEFAULT '[]'::jsonb,
    conclusion TEXT NOT NULL,
    has_image BOOLEAN DEFAULT true,
    display_order INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    patient_code TEXT NOT NULL DEFAULT '2600168496',
    patient_name TEXT NOT NULL DEFAULT 'NGUYỄN KIỀU LINH',
    visit_date TEXT NOT NULL DEFAULT '09/10/2026 14:04',
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bổ sung đầy đủ các cột nghiệp vụ
ALTER TABLE IF EXISTS public.medical_history ADD COLUMN IF NOT EXISTS patient_code TEXT DEFAULT '2600168496';
ALTER TABLE IF EXISTS public.medical_history ADD COLUMN IF NOT EXISTS patient_name TEXT DEFAULT 'NGUYỄN KIỀU LINH';
ALTER TABLE IF EXISTS public.medical_history ADD COLUMN IF NOT EXISTS hospital_name TEXT DEFAULT '[25329] Bệnh viện đa khoa Tư nhân Hùng Vương';
ALTER TABLE IF EXISTS public.medical_history ADD COLUMN IF NOT EXISTS treatment_type TEXT DEFAULT 'Ngoại trú';
ALTER TABLE IF EXISTS public.medical_history ADD COLUMN IF NOT EXISTS symptoms TEXT DEFAULT '';
ALTER TABLE IF EXISTS public.medical_history ADD COLUMN IF NOT EXISTS visit_date TEXT DEFAULT '09/10/2026 14:04';

ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS patient_code TEXT DEFAULT '2600168496';
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS patient_name TEXT DEFAULT 'NGUYỄN KIỀU LINH';
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS visit_date TEXT DEFAULT '09/10/2026 14:04';
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS test_title TEXT;
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS doctor_reading TEXT;
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS readings JSONB DEFAULT '[]'::jsonb;
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS conclusion TEXT DEFAULT '';
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS has_image BOOLEAN DEFAULT true;
ALTER TABLE IF EXISTS public.lab_results ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 1;

ALTER TABLE IF EXISTS public.prescriptions ADD COLUMN IF NOT EXISTS patient_code TEXT DEFAULT '2600168496';
ALTER TABLE IF EXISTS public.prescriptions ADD COLUMN IF NOT EXISTS patient_name TEXT DEFAULT 'NGUYỄN KIỀU LINH';
ALTER TABLE IF EXISTS public.prescriptions ADD COLUMN IF NOT EXISTS visit_date TEXT DEFAULT '09/10/2026 14:04';
ALTER TABLE IF EXISTS public.prescriptions ADD COLUMN IF NOT EXISTS items JSONB DEFAULT '[]'::jsonb;

-- BẬT RLS & CHÍNH SÁCH ĐỌC GHI CÔNG KHAI
ALTER TABLE public.medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public all medical_history" ON public.medical_history;
DROP POLICY IF EXISTS "Public read medical_history" ON public.medical_history;
DROP POLICY IF EXISTS "Public insert medical_history" ON public.medical_history;
DROP POLICY IF EXISTS "Public delete medical_history" ON public.medical_history;
DROP POLICY IF EXISTS "Public update medical_history" ON public.medical_history;
CREATE POLICY "Public all medical_history" ON public.medical_history FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public all lab_results" ON public.lab_results;
DROP POLICY IF EXISTS "Public read lab_results" ON public.lab_results;
DROP POLICY IF EXISTS "Public insert lab_results" ON public.lab_results;
DROP POLICY IF EXISTS "Public delete lab_results" ON public.lab_results;
DROP POLICY IF EXISTS "Public update lab_results" ON public.lab_results;
CREATE POLICY "Public all lab_results" ON public.lab_results FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public all prescriptions" ON public.prescriptions;
DROP POLICY IF EXISTS "Public read prescriptions" ON public.prescriptions;
DROP POLICY IF EXISTS "Public insert prescriptions" ON public.prescriptions;
DROP POLICY IF EXISTS "Public delete prescriptions" ON public.prescriptions;
DROP POLICY IF EXISTS "Public update prescriptions" ON public.prescriptions;
CREATE POLICY "Public all prescriptions" ON public.prescriptions FOR ALL USING (true) WITH CHECK (true);

-- =========================================================================
-- BƯỚC 2: TẠO TÀI KHOẢN VÀ NẠP HỒ SƠ BỆNH ÁN
-- =========================================================================
DO $$
DECLARE
    -- 👉 Cấu hình tài khoản và thông tin bệnh nhân
    target_phone    TEXT := '0338976909';       -- Số điện thoại đăng nhập
    target_password TEXT := '070306';           -- Mật khẩu đăng nhập
    v_code          TEXT := '2600168496';       -- Mã bệnh nhân
    v_name          TEXT := 'NGUYỄN KIỀU LINH'; -- Họ và tên bệnh nhân
    v_date          TEXT := '09/10/2026 14:04'; -- Ngày khám bệnh (09/10/2026)
    
    target_email    TEXT;
    v_user_id       UUID;
    encrypted_pw    TEXT;
BEGIN
    target_email := target_phone || '@hungvuong.hospital';
    
    BEGIN
        encrypted_pw := extensions.crypt(target_password, extensions.gen_salt('bf'));
    EXCEPTION WHEN OTHERS THEN
        encrypted_pw := crypt(target_password, gen_salt('bf'));
    END;

    -- 1. TỰ ĐỘNG TẠO HOẶC CẬP NHẬT MẬT KHẨU TÀI KHOẢN TRONG auth.users
    SELECT id INTO v_user_id FROM auth.users WHERE email = target_email;

    IF v_user_id IS NULL THEN
        v_user_id := gen_random_uuid();
        INSERT INTO auth.users (
            instance_id,
            id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000000',
            v_user_id,
            'authenticated',
            'authenticated',
            target_email,
            encrypted_pw,
            NOW(),
            '{"provider":"email","providers":["email"]}'::jsonb,
            jsonb_build_object('phone', target_phone, 'full_name', v_name),
            NOW(),
            NOW()
        );

        INSERT INTO auth.identities (
            id,
            user_id,
            identity_data,
            provider,
            provider_id,
            last_sign_in_at,
            created_at,
            updated_at
        ) VALUES (
            gen_random_uuid(),
            v_user_id,
            format('{"sub":"%s","email":"%s"}', v_user_id::text, target_email)::jsonb,
            'email',
            target_email,
            NOW(),
            NOW(),
            NOW()
        ) ON CONFLICT DO NOTHING;

        RAISE NOTICE '✅ ĐÃ TẠO TÀI KHOẢN MỚI: SĐT % | Mật khẩu: %', target_phone, target_password;
    ELSE
        UPDATE auth.users
        SET encrypted_password = encrypted_pw,
            raw_user_meta_data = jsonb_build_object('phone', target_phone, 'full_name', v_name),
            email_confirmed_at = COALESCE(email_confirmed_at, NOW()),
            updated_at = NOW()
        WHERE id = v_user_id;

        RAISE NOTICE '🔄 ĐÃ CẬP NHẬT MẬT KHẨU: SĐT % | Mật khẩu mới: %', target_phone, target_password;
    END IF;

    -- 2. XÓA DỮ LIỆU CŨ CỦA USER NÀY NẾU CÓ ĐỂ NẠP LẠI MỚI NHẤT
    DELETE FROM public.medical_history WHERE phone = target_phone;
    DELETE FROM public.lab_results WHERE phone = target_phone;
    DELETE FROM public.prescriptions WHERE phone = target_phone;

    -- 3. NẠP LỊCH SỬ KHÁM BỆNH (Ảnh 1)
    INSERT INTO public.medical_history (
        phone, patient_code, patient_name, hospital_name, visit_date, treatment_type, symptoms
    ) VALUES (
        target_phone,
        v_code,
        v_name,
        '[25329] Bệnh viện đa khoa Tư nhân Hùng Vương',
        v_date,
        'Ngoại trú',
        ''
    );

    -- 4. NẠP KẾT QUẢ CẬN LÂM SÀNG (Ảnh 2, 3, 4)
    -- Xét nghiệm 1: Điện tim thường (BS Nguyễn Việt Anh)
    INSERT INTO public.lab_results (
        phone, patient_code, patient_name, visit_date, test_title, doctor_reading, readings, conclusion, has_image, display_order
    ) VALUES (
        target_phone, v_code, v_name, v_date,
        'Chỉ định: 09/10/2026 15:00 - Điện tim thường',
        'Đọc kết quả: Nguyễn Việt Anh - 09/10/2026 16:58',
        '[]'::jsonb,
        'Nhịp xoang, tần số 68 ck/phút
Trục trung gian',
        true,
        1
    );

    -- Xét nghiệm 2: Siêu âm ổ bụng (BS Tạ Thị Hà)
    INSERT INTO public.lab_results (
        phone, patient_code, patient_name, visit_date, test_title, doctor_reading, readings, conclusion, has_image, display_order
    ) VALUES (
        target_phone, v_code, v_name, v_date,
        'Chỉ định: 09/10/2026 15:00 - Siêu âm ổ bụng',
        'Đọc kết quả: Tạ Thị Hà - 09/10/2026 16:52',
        '[
            "- GAN: Kích thước bình thường, nhu mô đều, không có khối khu trú. Tĩnh mạch gan không giãn, không có huyết khối.",
            "- ĐƯỜNG MẬT: Trong gan không giãn, không có sỏi.",
            "- ỐNG MẬT CHỦ: Không giãn, không có sỏi.",
            "- TÚI MẬT: Thành mỏng, dịch mật trong, không giãn, không có sỏi.",
            "- TĨNH MẠCH CỬA: Không giãn, trong lòng không có huyết khối.",
            "- TỤY: Kích thước bình thường, nhu mô đều, ống Wirsung không giãn.",
            "- LÁCH: Kích thước bình thường, nhu mô đều, tĩnh mạch lách không giãn, không có huyết khối.",
            "- THẬN PHẢI: Kích thước bình thường, nhu mô đều, ranh giới nhu mô và đài bể thận rõ, đài bể thận không giãn, không có sỏi. Niệu quản không giãn.",
            "- THẬN TRÁI: Kích thước bình thường, nhu mô đều, ranh giới nhu mô và đài bể thận rõ, đài bể thận không giãn, không có sỏi. Niệu quản không giãn.",
            "- BÀNG QUANG: Thành mỏng, nước tiểu trong, không có sỏi.",
            "- TỬ CUNG: Kích thước bình thường, nhu mô đều, không thấy khối bất thường. Buồng tử cung không có dịch.",
            "- Phần phụ hai bên không thấy khối bất thường.",
            "- Ổ BỤNG: Không có dịch tự do.",
            "Ruột thừa vị trí hố chậu phải, ĐK ngang khoảng 3.2mm, ấn xẹp, lòng chứa khí, xung quanh không thấy thâm nhiễm."
        ]'::jsonb,
        'Hình ảnh siêu âm hiện tại không thấy bất thường.',
        true,
        2
    );

    -- Xét nghiệm 3: Khám chuyên khoa Tai – Mũi – Họng (BS Lò Thị Xuân)
    INSERT INTO public.lab_results (
        phone, patient_code, patient_name, visit_date, test_title, doctor_reading, readings, conclusion, has_image, display_order
    ) VALUES (
        target_phone, v_code, v_name, v_date,
        'Chỉ định: 09/10/2026 15:00 - Khám chuyên khoa Tai – Mũi – Họng',
        'Đọc kết quả: Lò Thị Xuân - 09/10/2026 16:21',
        '[
            "- TAI:",
            "  + Ống tai ngoài 2 bên có ít đáy , không có dị vật ống tai",
            "  + Màng nhĩ 2 bên sáng, không thủng",
            "- MŨI:",
            "  + Niêm mạc cuốn mũi 2 bên nề, sàn mũi khe mũi giữa 2 bên có nhiều dịch nhày. Khe mũi giữa phải có polyp độ IV, khe mũi giữa trái có polyp độ III",
            "  + Vách ngăn mũi bình thường, không lệch vẹo.",
            "  + Vòm có ít dịch nhày, còn tổ chức lympho",
            "- HỌNG:",
            "  + Niêm mạc thành sau họng đỏ, có tổ chức hạt viêm.",
            "  + Amydal hai bên không viêm",
            "  + Dây thanh bình thường, niêm mạc hồng nhạt, đóng mở khít. Sụn phễu di động bình thường.",
            "  + Hạ họng sạch, không có u cục"
        ]'::jsonb,
        'Viêm mũi xoang mạn tính (polyp mũi 2 bên).',
        true,
        3
    );

    -- Xét nghiệm 4: Chụp X-quang ngực thẳng [số hóa 1 phim] (BS Đào Văn Trí)
    INSERT INTO public.lab_results (
        phone, patient_code, patient_name, visit_date, test_title, doctor_reading, readings, conclusion, has_image, display_order
    ) VALUES (
        target_phone, v_code, v_name, v_date,
        'Chỉ định: 09/10/2026 15:00 - Chụp X-quang ngực thẳng [số hóa 1 phim]',
        'Đọc kết quả: Đào Văn Trí - 09/10/2026 15:38',
        '[
            "* Kết quả X-Quang ngực thẳng:",
            "- Bóng tim không to.",
            "- Bóng trung thất không rộng, không thấy khối.",
            "- Hai rốn phổi đồng nhất.",
            "- Nhu mô phổi hai bên sáng đều.",
            "- Vòm hoành hai bên cong đều, góc sườn hoành hai bên nhọn."
        ]'::jsonb,
        'Hiện tại không thấy hình ảnh tổn thương trên phim chụp.',
        true,
        4
    );

    -- 5. NẠP ĐƠN THUỐC (Ảnh 5)
    INSERT INTO public.prescriptions (
        phone, patient_code, patient_name, visit_date, items
    ) VALUES (
        target_phone, v_code, v_name, v_date,
        '[
            {"stt": 1, "thuoc": "Benita", "so_luong": 1, "don_gia": "110.000", "thanh_tien": "110.000", "cach_dung": "2 nhát / bên/ lần * 1 lần / ngày"},
            {"stt": 2, "thuoc": "Curam 1000mg", "so_luong": 14, "don_gia": "7.254", "thanh_tien": "101.556", "cach_dung": "1 viên/ lần* 2 lần/ ngày* 7 ngày"},
            {"stt": 3, "thuoc": "Medovent 30mg", "so_luong": 14, "don_gia": "2.135", "thanh_tien": "29.890", "cach_dung": "1 viên/ lần* 2 lần/ ngày* 7 ngày"},
            {"stt": 4, "thuoc": "Medrol <16>", "so_luong": 5, "don_gia": "4.480", "thanh_tien": "22.400", "cach_dung": "1 viên/ lần* 1 lần/ ngày* 5 ngày"},
            {"stt": 5, "thuoc": "Promax iNO <150> nhát xịt", "so_luong": 1, "don_gia": "200.000", "thanh_tien": "200.000", "cach_dung": "xịt mũi ngày 3 lần , mỗi lần 2 nhát / bên"}
        ]'::jsonb
    );

    RAISE NOTICE '🎉 HOÀN TẤT! Đã cấp xong tài khoản & hồ sơ bệnh án cho SĐT: % (Mật khẩu: %)', target_phone, target_password;
END $$;
