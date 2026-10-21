-- ==========================================================
-- BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - HỒ SƠ BỆNH ÁN ĐIỆN TỬ
-- LỆNH TẠO BẢNG CHUẨN XÁC THEO HỒ SƠ BỆNH NHÂN NGUYỄN KIỀU LINH
-- Chạy script này trong Supabase -> SQL Editor -> Nhấn RUN
-- ==========================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;

-- Tự động sửa kiểu dữ liệu và gỡ bỏ ràng buộc cũ nếu bảng đã tồn tại từ trước
DO $$
BEGIN
    -- 1. Bảng medical_history
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
        
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'medical_history' AND column_name = 'visit_date') THEN
            ALTER TABLE public.medical_history ALTER COLUMN visit_date DROP DEFAULT;
            ALTER TABLE public.medical_history ALTER COLUMN visit_date TYPE TEXT USING visit_date::text;
            ALTER TABLE public.medical_history ALTER COLUMN visit_date SET DEFAULT '09/10/2026 14:04';
        ELSE
            ALTER TABLE public.medical_history ADD COLUMN visit_date TEXT DEFAULT '09/10/2026 14:04';
        END IF;
    END IF;

    -- 2. Bảng lab_results
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

    -- 3. Bảng prescriptions
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
    test_title TEXT NOT NULL,
    doctor_reading TEXT NOT NULL,
    readings JSONB DEFAULT '[]'::jsonb,
    conclusion TEXT NOT NULL,
    has_image BOOLEAN DEFAULT true,
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

-- BỔ SUNG CỘT
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

-- BẬT ROW LEVEL SECURITY (RLS) & TẠO POLICY ĐỌC GHI
ALTER TABLE public.medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lab_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read medical_history" ON public.medical_history;
CREATE POLICY "Public read medical_history" ON public.medical_history FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert medical_history" ON public.medical_history;
CREATE POLICY "Public insert medical_history" ON public.medical_history FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public delete medical_history" ON public.medical_history;
CREATE POLICY "Public delete medical_history" ON public.medical_history FOR DELETE USING (true);
DROP POLICY IF EXISTS "Public update medical_history" ON public.medical_history FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read lab_results" ON public.lab_results;
CREATE POLICY "Public read lab_results" ON public.lab_results FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert lab_results" ON public.lab_results;
CREATE POLICY "Public insert lab_results" ON public.lab_results FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public delete lab_results" ON public.lab_results;
CREATE POLICY "Public delete lab_results" ON public.lab_results FOR DELETE USING (true);
DROP POLICY IF EXISTS "Public update lab_results" ON public.lab_results FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Public read prescriptions" ON public.prescriptions;
CREATE POLICY "Public read prescriptions" ON public.prescriptions FOR SELECT USING (true);
DROP POLICY IF EXISTS "Public insert prescriptions" ON public.prescriptions;
CREATE POLICY "Public insert prescriptions" ON public.prescriptions FOR INSERT WITH CHECK (true);
DROP POLICY IF EXISTS "Public delete prescriptions" ON public.prescriptions;
CREATE POLICY "Public delete prescriptions" ON public.prescriptions FOR DELETE USING (true);
DROP POLICY IF EXISTS "Public update prescriptions" ON public.prescriptions FOR UPDATE USING (true);
