-- ==========================================================
-- BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - HỒ SƠ BỆNH ÁN ĐIỆN TỬ
-- LỆNH TẠO BẢNG CHUẨN XÁC THEO HỒ SƠ BỆNH NHÂN NGUYỄN KIỀU LINH
-- Chạy script này trong Supabase -> SQL Editor -> Nhấn RUN
-- ==========================================================

-- 1. BẢNG LỊCH SỬ KHÁM BỆNH
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

-- 2. BẢNG KẾT QUẢ CẬN LÂM SÀNG
CREATE TABLE IF NOT EXISTS public.lab_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    patient_code TEXT NOT NULL DEFAULT '2600168496',
    patient_name TEXT NOT NULL DEFAULT 'NGUYỄN KIỀU LINH',
    visit_date TEXT NOT NULL DEFAULT '09/10/2026 14:04',
    test_title TEXT NOT NULL,       -- Ví dụ: Chỉ định: 09/10/2026 15:00 - Điện tim thường
    doctor_reading TEXT NOT NULL,   -- Ví dụ: Đọc kết quả: Nguyễn Việt Anh - 09/10/2026 16:58
    readings JSONB DEFAULT '[]'::jsonb, -- Các dòng đọc kết quả chi tiết
    conclusion TEXT NOT NULL,       -- Kết luận
    has_image BOOLEAN DEFAULT true, -- Xem kết quả hình ảnh
    display_order INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. BẢNG ĐƠN THUỐC
CREATE TABLE IF NOT EXISTS public.prescriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    patient_code TEXT NOT NULL DEFAULT '2600168496',
    patient_name TEXT NOT NULL DEFAULT 'NGUYỄN KIỀU LINH',
    visit_date TEXT NOT NULL DEFAULT '09/10/2026 14:04',
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- BẬT ROW LEVEL SECURITY (RLS) & TẠO POLICY ĐỌC GHI
ALTER TABLE public.medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read medical_history" ON public.medical_history;
CREATE POLICY "Public read medical_history" ON public.medical_history FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert medical_history" ON public.medical_history;
CREATE POLICY "Public insert medical_history" ON public.medical_history FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read lab_results" ON public.lab_results;
CREATE POLICY "Public read lab_results" ON public.lab_results FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert lab_results" ON public.lab_results;
CREATE POLICY "Public insert lab_results" ON public.lab_results FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Public read prescriptions" ON public.prescriptions;
CREATE POLICY "Public read prescriptions" ON public.prescriptions FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert prescriptions" ON public.prescriptions;
CREATE POLICY "Public insert prescriptions" ON public.prescriptions FOR INSERT WITH CHECK (true);
