-- ═══════════════════════════════════════════════════════════════════
-- HMG ACADEMY CBT PRO v3.1 ENTERPRISE — COMPLETE SUPABASE SETUP
-- ═══════════════════════════════════════════════════════════════════
-- Run this WHOLE file once in Supabase Dashboard → SQL Editor.
-- It is intentionally idempotent: safe to re-run after future updates.
--
-- Corrected in v3.1:
--   1. Helper functions are created BEFORE RLS policies that reference them.
--   2. Admin RPC functions now verify real admin status inside PostgreSQL.
--   3. Students no longer need broad anonymous SELECT access to exams/results.
--   4. Registered-student verification and attempt counting use safe RPCs.
--   5. Result scores support decimals for partial-credit question types.
--   6. Public exam loading hides question data before scheduled start time.
--   7. Existing installations are upgraded without dropping user data.
--
-- Brand: HMG Academy CBT Pro / HMG Concepts
-- Founder: Adewale Samson Adeagbo
-- Contacts: hismarvellousgrace@gmail.com · buildingmyictcareer@gmail.com
-- WhatsApp: +234 810 086 6322 · Phone: +234 907 790 7677
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- STEP 0: EXTENSIONS
-- ═══════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 1: CORE TABLES
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email       TEXT        UNIQUE NOT NULL,
  full_name   TEXT        DEFAULT '',
  role        TEXT        NOT NULL DEFAULT 'teacher',
  is_admin    BOOLEAN     NOT NULL DEFAULT false,
  status      TEXT        NOT NULL DEFAULT 'pending',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.exams (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  code            TEXT        UNIQUE NOT NULL,
  subject         TEXT        NOT NULL,
  duration        INTEGER     NOT NULL DEFAULT 45,
  attempt_limit   INTEGER     NOT NULL DEFAULT 1,
  select_count    INTEGER     NOT NULL DEFAULT 0,
  is_open         BOOLEAN     NOT NULL DEFAULT false,
  exam_mode       TEXT        NOT NULL DEFAULT 'open',
  negative_mark   NUMERIC     NOT NULL DEFAULT 0,
  release_results BOOLEAN     NOT NULL DEFAULT true,
  instructions    TEXT        NOT NULL DEFAULT '',
  is_archived     BOOLEAN     NOT NULL DEFAULT false,
  cert_code       TEXT        NOT NULL DEFAULT '',
  start_at        TIMESTAMPTZ,
  close_at        TIMESTAMPTZ,
  csv_data        JSONB       NOT NULL DEFAULT '[]'::jsonb,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.results (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  exam_id         UUID        NOT NULL REFERENCES public.exams(id) ON DELETE CASCADE,
  student_name    TEXT        NOT NULL,
  student_class   TEXT        NOT NULL DEFAULT '',
  student_id_ref  TEXT        DEFAULT '',
  student_type    TEXT        DEFAULT 'open',
  score           NUMERIC(10,2) NOT NULL DEFAULT 0,
  total           INTEGER     NOT NULL DEFAULT 0,
  correct_count   INTEGER     DEFAULT NULL,
  wrong_count     INTEGER     DEFAULT NULL,
  skipped_count   INTEGER     DEFAULT NULL,
  attempt_number  INTEGER     DEFAULT 1,
  time_taken      INTEGER     DEFAULT 0,
  answers_data    JSONB,
  violations      INTEGER     DEFAULT 0,
  violation_log   JSONB       DEFAULT '[]'::jsonb,
  proctor_data    JSONB,
  cert_code       TEXT        DEFAULT '',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.students (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id  UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT        NOT NULL,
  student_id  TEXT        NOT NULL,
  class       TEXT        NOT NULL DEFAULT '',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(teacher_id, student_id)
);

-- ═══════════════════════════════════════════════════════════════════
-- STEP 2: SAFE UPGRADE COLUMNS/TYPES FOR EXISTING INSTALLATIONS
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS exam_mode       TEXT        NOT NULL DEFAULT 'open';
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS start_at        TIMESTAMPTZ;
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS close_at        TIMESTAMPTZ;
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS updated_at      TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS negative_mark   NUMERIC     NOT NULL DEFAULT 0;
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS release_results BOOLEAN     NOT NULL DEFAULT true;
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS instructions    TEXT        NOT NULL DEFAULT '';
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS is_archived     BOOLEAN     NOT NULL DEFAULT false;
ALTER TABLE public.exams ADD COLUMN IF NOT EXISTS cert_code       TEXT        NOT NULL DEFAULT '';

ALTER TABLE public.results ADD COLUMN IF NOT EXISTS student_id_ref  TEXT DEFAULT '';
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS student_type    TEXT DEFAULT 'open';
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS answers_data    JSONB;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS time_taken      INTEGER DEFAULT 0;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS violations      INTEGER DEFAULT 0;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS violation_log   JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS proctor_data    JSONB;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS correct_count   INTEGER DEFAULT NULL;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS wrong_count     INTEGER DEFAULT NULL;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS skipped_count   INTEGER DEFAULT NULL;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS attempt_number  INTEGER DEFAULT 1;
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS cert_code       TEXT DEFAULT '';
ALTER TABLE public.results ADD COLUMN IF NOT EXISTS student_class   TEXT NOT NULL DEFAULT '';

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name  TEXT DEFAULT '';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role       TEXT NOT NULL DEFAULT 'teacher';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin   BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status     TEXT NOT NULL DEFAULT 'pending';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Decimal scores are required for MRQ, matching, ordering, cloze, essay keyword
-- scoring, categorisation, and multi-numeric partial credit.
ALTER TABLE public.results
  ALTER COLUMN score TYPE NUMERIC(10,2) USING score::NUMERIC;

-- Normalize old nulls so new NOT NULL defaults do not fail later.
UPDATE public.exams SET exam_mode = 'open' WHERE exam_mode IS NULL;
UPDATE public.exams SET negative_mark = 0 WHERE negative_mark IS NULL;
UPDATE public.exams SET release_results = true WHERE release_results IS NULL;
UPDATE public.exams SET instructions = '' WHERE instructions IS NULL;
UPDATE public.exams SET is_archived = false WHERE is_archived IS NULL;
UPDATE public.exams SET cert_code = '' WHERE cert_code IS NULL;
UPDATE public.results SET violation_log = '[]'::jsonb WHERE violation_log IS NULL;
UPDATE public.results SET cert_code = '' WHERE cert_code IS NULL;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 3: INDEXES AND DATA QUALITY CONSTRAINTS
-- ═══════════════════════════════════════════════════════════════════

CREATE INDEX IF NOT EXISTS idx_profiles_status       ON public.profiles(status);
CREATE INDEX IF NOT EXISTS idx_profiles_email        ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin     ON public.profiles(is_admin);

CREATE INDEX IF NOT EXISTS idx_exams_teacher_id      ON public.exams(teacher_id);
CREATE INDEX IF NOT EXISTS idx_exams_code            ON public.exams(code);
CREATE INDEX IF NOT EXISTS idx_exams_is_open         ON public.exams(is_open);
CREATE INDEX IF NOT EXISTS idx_exams_created_at      ON public.exams(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_exams_archived        ON public.exams(is_archived);
CREATE INDEX IF NOT EXISTS idx_exams_start_close     ON public.exams(start_at, close_at);

CREATE INDEX IF NOT EXISTS idx_results_exam_id       ON public.results(exam_id);
CREATE INDEX IF NOT EXISTS idx_results_student_name  ON public.results(student_name);
CREATE INDEX IF NOT EXISTS idx_results_student_ref   ON public.results(student_id_ref);
CREATE INDEX IF NOT EXISTS idx_results_created_at    ON public.results(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_results_violations    ON public.results(violations);
CREATE INDEX IF NOT EXISTS idx_results_exam_student  ON public.results(exam_id, lower(student_name), lower(student_class));

CREATE INDEX IF NOT EXISTS idx_students_teacher_id   ON public.students(teacher_id);
CREATE INDEX IF NOT EXISTS idx_students_student_id   ON public.students(student_id);
CREATE INDEX IF NOT EXISTS idx_students_class        ON public.students(class);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_role_check') THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_role_check CHECK (role IN ('teacher', 'admin'));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_status_check') THEN
    ALTER TABLE public.profiles
      ADD CONSTRAINT profiles_status_check CHECK (status IN ('pending', 'active', 'inactive', 'rejected'));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'exams_exam_mode_check') THEN
    ALTER TABLE public.exams
      ADD CONSTRAINT exams_exam_mode_check CHECK (exam_mode IN ('open', 'registered'));
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'exams_duration_check') THEN
    ALTER TABLE public.exams
      ADD CONSTRAINT exams_duration_check CHECK (duration > 0);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'exams_attempt_limit_check') THEN
    ALTER TABLE public.exams
      ADD CONSTRAINT exams_attempt_limit_check CHECK (attempt_limit > 0);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'results_total_check') THEN
    ALTER TABLE public.results
      ADD CONSTRAINT results_total_check CHECK (total >= 0);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'results_score_check') THEN
    ALTER TABLE public.results
      ADD CONSTRAINT results_score_check CHECK (score >= 0);
  END IF;
END $$;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 4: SECURITY DEFINER HELPERS (MUST EXIST BEFORE POLICIES)
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_exam_teacher_id(p_exam_id UUID)
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT e.teacher_id
  FROM public.exams e
  WHERE e.id = p_exam_id
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT
    COALESCE((
      SELECT (p.is_admin = true OR p.role = 'admin') AND p.status = 'active'
      FROM public.profiles p
      WHERE p.id = auth.uid()
      LIMIT 1
    ), false)
    OR lower(COALESCE(auth.jwt() ->> 'email', '')) = lower('buildingmyictcareer@gmail.com');
$$;

CREATE OR REPLACE FUNCTION public.is_exam_open_for_submission(p_exam_id UUID)
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.exams e
    WHERE e.id = p_exam_id
      AND e.is_archived = false
      AND e.is_open = true
      AND (e.start_at IS NULL OR e.start_at <= NOW())
      AND (e.close_at IS NULL OR e.close_at > NOW())
  );
$$;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 5: ENABLE ROW-LEVEL SECURITY
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.results  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 6: DROP OLD/INSECURE POLICIES
-- ═══════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Teachers select own exams" ON public.exams;
DROP POLICY IF EXISTS "Teachers insert own exams" ON public.exams;
DROP POLICY IF EXISTS "Teachers update own exams" ON public.exams;
DROP POLICY IF EXISTS "Teachers delete own exams" ON public.exams;
DROP POLICY IF EXISTS "Teachers see own exams" ON public.exams;
DROP POLICY IF EXISTS "Students can read exams by code" ON public.exams;
DROP POLICY IF EXISTS "Admins manage all exams" ON public.exams;

DROP POLICY IF EXISTS "Teachers select own results" ON public.results;
DROP POLICY IF EXISTS "Students can submit results" ON public.results;
DROP POLICY IF EXISTS "Teachers insert own results" ON public.results;
DROP POLICY IF EXISTS "Teachers update own results" ON public.results;
DROP POLICY IF EXISTS "Teachers delete own results" ON public.results;
DROP POLICY IF EXISTS "Teachers see own results" ON public.results;
DROP POLICY IF EXISTS "Admins manage all results" ON public.results;

DROP POLICY IF EXISTS "Users read own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow profile insert" ON public.profiles;
DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins manage all profiles" ON public.profiles;

DROP POLICY IF EXISTS "Teachers select own students" ON public.students;
DROP POLICY IF EXISTS "Teachers insert own students" ON public.students;
DROP POLICY IF EXISTS "Teachers update own students" ON public.students;
DROP POLICY IF EXISTS "Teachers delete own students" ON public.students;
DROP POLICY IF EXISTS "Teachers manage own students" ON public.students;
DROP POLICY IF EXISTS "Anyone can verify student ID" ON public.students;
DROP POLICY IF EXISTS "Admins manage all students" ON public.students;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 7: CREATE RLS POLICIES
-- ═══════════════════════════════════════════════════════════════════
-- Important: Students use RPC functions for exam loading, student-ID
-- verification, and attempt counting. Therefore no broad anonymous SELECT
-- policy is created on exams, results, or students.

-- Profiles
CREATE POLICY "Users read own profile"
  ON public.profiles FOR SELECT TO authenticated
  USING (auth.uid() = id OR public.is_platform_admin());

CREATE POLICY "Allow profile insert"
  ON public.profiles FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id OR public.is_platform_admin());

CREATE POLICY "Users update own profile"
  ON public.profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id OR public.is_platform_admin())
  WITH CHECK (auth.uid() = id OR public.is_platform_admin());

CREATE POLICY "Admins manage all profiles"
  ON public.profiles FOR DELETE TO authenticated
  USING (public.is_platform_admin());

-- Exams
CREATE POLICY "Teachers select own exams"
  ON public.exams FOR SELECT TO authenticated
  USING (auth.uid() = teacher_id OR public.is_platform_admin());

CREATE POLICY "Teachers insert own exams"
  ON public.exams FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = teacher_id OR public.is_platform_admin());

CREATE POLICY "Teachers update own exams"
  ON public.exams FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id OR public.is_platform_admin())
  WITH CHECK (auth.uid() = teacher_id OR public.is_platform_admin());

CREATE POLICY "Teachers delete own exams"
  ON public.exams FOR DELETE TO authenticated
  USING (auth.uid() = teacher_id OR public.is_platform_admin());

-- Results
CREATE POLICY "Teachers select own results"
  ON public.results FOR SELECT TO authenticated
  USING (auth.uid() = public.get_exam_teacher_id(exam_id) OR public.is_platform_admin());

CREATE POLICY "Students can submit results"
  ON public.results FOR INSERT TO anon
  WITH CHECK (public.is_exam_open_for_submission(exam_id));

CREATE POLICY "Teachers insert own results"
  ON public.results FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = public.get_exam_teacher_id(exam_id) OR public.is_platform_admin());

CREATE POLICY "Teachers update own results"
  ON public.results FOR UPDATE TO authenticated
  USING (auth.uid() = public.get_exam_teacher_id(exam_id) OR public.is_platform_admin())
  WITH CHECK (auth.uid() = public.get_exam_teacher_id(exam_id) OR public.is_platform_admin());

CREATE POLICY "Teachers delete own results"
  ON public.results FOR DELETE TO authenticated
  USING (auth.uid() = public.get_exam_teacher_id(exam_id) OR public.is_platform_admin());

-- Students roster
CREATE POLICY "Teachers select own students"
  ON public.students FOR SELECT TO authenticated
  USING (auth.uid() = teacher_id OR public.is_platform_admin());

CREATE POLICY "Teachers insert own students"
  ON public.students FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = teacher_id OR public.is_platform_admin());

CREATE POLICY "Teachers update own students"
  ON public.students FOR UPDATE TO authenticated
  USING (auth.uid() = teacher_id OR public.is_platform_admin())
  WITH CHECK (auth.uid() = teacher_id OR public.is_platform_admin());

CREATE POLICY "Teachers delete own students"
  ON public.students FOR DELETE TO authenticated
  USING (auth.uid() = teacher_id OR public.is_platform_admin());

-- ═══════════════════════════════════════════════════════════════════
-- STEP 8: TRIGGERS
-- ═══════════════════════════════════════════════════════════════════

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role, is_admin, status)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name',
             NEW.raw_user_meta_data->>'display_name',
             split_part(NEW.email, '@', 1)),
    CASE WHEN lower(NEW.email) = lower('buildingmyictcareer@gmail.com') THEN 'admin' ELSE 'teacher' END,
    CASE WHEN lower(NEW.email) = lower('buildingmyictcareer@gmail.com') THEN true ELSE false END,
    CASE WHEN lower(NEW.email) = lower('buildingmyictcareer@gmail.com') THEN 'active' ELSE 'pending' END
  )
  ON CONFLICT (id) DO UPDATE
    SET email      = EXCLUDED.email,
        full_name  = COALESCE(NULLIF(public.profiles.full_name, ''), EXCLUDED.full_name),
        is_admin   = public.profiles.is_admin OR EXCLUDED.is_admin,
        role       = CASE WHEN public.profiles.is_admin OR EXCLUDED.is_admin THEN 'admin' ELSE public.profiles.role END,
        status     = CASE WHEN public.profiles.is_admin OR EXCLUDED.is_admin THEN 'active' ELSE public.profiles.status END,
        updated_at = NOW();
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'handle_new_user trigger failed: %', SQLERRM;
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS update_exams_updated_at ON public.exams;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
DROP FUNCTION IF EXISTS public.update_updated_at_column();

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE PLPGSQL
SET search_path = public, pg_temp
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_exams_updated_at
  BEFORE UPDATE ON public.exams
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ═══════════════════════════════════════════════════════════════════
-- STEP 9: PUBLIC STUDENT RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.get_public_exam_by_code(TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.verify_student_for_exam(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.get_exam_attempt_count(UUID, TEXT, TEXT, TEXT) CASCADE;

CREATE OR REPLACE FUNCTION public.get_public_exam_by_code(p_code TEXT)
RETURNS TABLE (
  id              UUID,
  code            TEXT,
  subject         TEXT,
  duration        INTEGER,
  attempt_limit   INTEGER,
  select_count    INTEGER,
  is_open         BOOLEAN,
  exam_mode       TEXT,
  negative_mark   NUMERIC,
  release_results BOOLEAN,
  instructions    TEXT,
  start_at        TIMESTAMPTZ,
  close_at        TIMESTAMPTZ,
  csv_data        JSONB,
  created_at      TIMESTAMPTZ,
  updated_at      TIMESTAMPTZ
)
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT
    e.id,
    e.code,
    e.subject,
    e.duration,
    e.attempt_limit,
    e.select_count,
    e.is_open,
    e.exam_mode,
    e.negative_mark,
    e.release_results,
    e.instructions,
    e.start_at,
    e.close_at,
    CASE
      WHEN e.start_at IS NOT NULL AND e.start_at > NOW() THEN '[]'::jsonb
      ELSE e.csv_data
    END AS csv_data,
    e.created_at,
    e.updated_at
  FROM public.exams e
  WHERE upper(e.code) = upper(trim(p_code))
    AND e.is_archived = false
    AND e.is_open = true
    AND (e.close_at IS NULL OR e.close_at > NOW())
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.verify_student_for_exam(p_exam_id UUID, p_student_id TEXT)
RETURNS TABLE (
  full_name  TEXT,
  student_id TEXT,
  class      TEXT
)
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT s.full_name, s.student_id, s.class
  FROM public.students s
  JOIN public.exams e ON e.teacher_id = s.teacher_id
  WHERE e.id = p_exam_id
    AND e.is_archived = false
    AND upper(s.student_id) = upper(trim(p_student_id))
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.get_exam_attempt_count(
  p_exam_id UUID,
  p_student_name TEXT,
  p_student_class TEXT,
  p_student_id_ref TEXT DEFAULT ''
)
RETURNS INTEGER
LANGUAGE SQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
  SELECT COUNT(*)::INTEGER
  FROM public.results r
  WHERE r.exam_id = p_exam_id
    AND (
      (COALESCE(trim(p_student_id_ref), '') <> '' AND upper(COALESCE(r.student_id_ref, '')) = upper(trim(p_student_id_ref)))
      OR
      (lower(trim(r.student_name)) = lower(trim(p_student_name))
       AND lower(trim(r.student_class)) = lower(trim(p_student_class)))
    );
$$;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 10: ADMIN RPC FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.admin_get_all_profiles() CASCADE;
DROP FUNCTION IF EXISTS public.admin_get_all_exams() CASCADE;
DROP FUNCTION IF EXISTS public.admin_get_all_results() CASCADE;
DROP FUNCTION IF EXISTS public.admin_set_profile_status(UUID, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.admin_set_profile_role(UUID, TEXT, TEXT) CASCADE;
DROP FUNCTION IF EXISTS public.admin_delete_profile(UUID) CASCADE;
DROP FUNCTION IF EXISTS public.admin_get_platform_stats() CASCADE;
DROP FUNCTION IF EXISTS public.admin_get_exam_results(UUID) CASCADE;

CREATE OR REPLACE FUNCTION public.admin_get_all_profiles()
RETURNS SETOF public.profiles
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;
  RETURN QUERY SELECT * FROM public.profiles ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_get_all_exams()
RETURNS SETOF public.exams
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;
  RETURN QUERY SELECT * FROM public.exams ORDER BY created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_get_all_results()
RETURNS TABLE (
  id              UUID,
  exam_id         UUID,
  student_name    TEXT,
  student_class   TEXT,
  student_id_ref  TEXT,
  student_type    TEXT,
  score           NUMERIC,
  total           INTEGER,
  correct_count   INTEGER,
  wrong_count     INTEGER,
  skipped_count   INTEGER,
  attempt_number  INTEGER,
  time_taken      INTEGER,
  answers_data    JSONB,
  violations      INTEGER,
  violation_log   JSONB,
  proctor_data    JSONB,
  cert_code       TEXT,
  created_at      TIMESTAMPTZ,
  exams           JSONB
)
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;

  RETURN QUERY
  SELECT
    r.id, r.exam_id, r.student_name, r.student_class,
    r.student_id_ref, r.student_type, r.score, r.total,
    r.correct_count, r.wrong_count, r.skipped_count,
    r.attempt_number, r.time_taken, r.answers_data,
    r.violations, r.violation_log, r.proctor_data,
    r.cert_code, r.created_at,
    jsonb_build_object(
      'subject',    e.subject,
      'teacher_id', e.teacher_id,
      'code',       e.code
    ) AS exams
  FROM public.results r
  LEFT JOIN public.exams e ON e.id = r.exam_id
  ORDER BY r.created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_set_profile_status(p_id UUID, p_status TEXT)
RETURNS VOID
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;

  IF p_status NOT IN ('pending', 'active', 'inactive', 'rejected') THEN
    RAISE EXCEPTION 'Invalid status: %', p_status;
  END IF;

  UPDATE public.profiles
  SET status = p_status, updated_at = NOW()
  WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_set_profile_role(p_id UUID, p_role TEXT, p_status TEXT)
RETURNS VOID
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;

  IF p_role NOT IN ('teacher', 'admin') THEN
    RAISE EXCEPTION 'Invalid role: %', p_role;
  END IF;

  IF p_status NOT IN ('pending', 'active', 'inactive', 'rejected') THEN
    RAISE EXCEPTION 'Invalid status: %', p_status;
  END IF;

  UPDATE public.profiles
  SET is_admin  = (p_role = 'admin'),
      role      = p_role,
      status    = p_status,
      updated_at = NOW()
  WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_delete_profile(p_id UUID)
RETURNS VOID
LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;

  DELETE FROM public.profiles WHERE id = p_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_get_platform_stats()
RETURNS TABLE (
  total_teachers   BIGINT,
  active_teachers  BIGINT,
  pending_teachers BIGINT,
  total_exams      BIGINT,
  live_exams       BIGINT,
  total_results    BIGINT,
  total_students   BIGINT,
  avg_score        NUMERIC,
  pass_rate        NUMERIC
)
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;

  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM public.profiles WHERE role IN ('teacher', 'admin')) AS total_teachers,
    (SELECT COUNT(*) FROM public.profiles WHERE status = 'active') AS active_teachers,
    (SELECT COUNT(*) FROM public.profiles WHERE status = 'pending') AS pending_teachers,
    (SELECT COUNT(*) FROM public.exams) AS total_exams,
    (SELECT COUNT(*) FROM public.exams WHERE is_open = true AND is_archived = false) AS live_exams,
    (SELECT COUNT(*) FROM public.results) AS total_results,
    (SELECT COUNT(*) FROM public.students) AS total_students,
    COALESCE((SELECT ROUND(AVG((score / NULLIF(total, 0)) * 100), 2) FROM public.results WHERE total > 0), 0) AS avg_score,
    COALESCE((
      SELECT ROUND(
        (COUNT(*) FILTER (WHERE (score / NULLIF(total, 0)) * 100 >= 50)::NUMERIC /
         NULLIF(COUNT(*), 0) * 100, 2)
      FROM public.results WHERE total > 0
    ), 0) AS pass_rate;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_get_exam_results(p_exam_id UUID)
RETURNS TABLE (
  id              UUID,
  exam_id         UUID,
  student_name    TEXT,
  student_class   TEXT,
  student_id_ref  TEXT,
  student_type    TEXT,
  score           NUMERIC,
  total           INTEGER,
  correct_count   INTEGER,
  wrong_count     INTEGER,
  skipped_count   INTEGER,
  attempt_number  INTEGER,
  time_taken      INTEGER,
  answers_data    JSONB,
  violations      INTEGER,
  violation_log   JSONB,
  created_at      TIMESTAMPTZ
)
LANGUAGE PLPGSQL
SECURITY DEFINER
STABLE
SET search_path = public, pg_temp
AS $$
BEGIN
  IF NOT public.is_platform_admin() THEN
    RAISE EXCEPTION 'Not authorized: admin access required';
  END IF;

  RETURN QUERY
  SELECT
    r.id, r.exam_id, r.student_name, r.student_class,
    r.student_id_ref, r.student_type, r.score, r.total,
    r.correct_count, r.wrong_count, r.skipped_count,
    r.attempt_number, r.time_taken, r.answers_data,
    r.violations, r.violation_log, r.created_at
  FROM public.results r
  WHERE r.exam_id = p_exam_id
  ORDER BY r.created_at DESC;
END;
$$;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 11: FUNCTION PERMISSIONS
-- ═══════════════════════════════════════════════════════════════════
-- Never expose a service_role key in frontend files. These grants allow only
-- the safe anon RPCs to run anonymously; admin RPCs still require an admin JWT.

GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT, INSERT ON public.results TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.exams TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.results TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.students TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.profiles TO authenticated;

REVOKE ALL ON FUNCTION public.get_exam_teacher_id(UUID) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.is_platform_admin() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.is_exam_open_for_submission(UUID) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.get_public_exam_by_code(TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.verify_student_for_exam(UUID, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.get_exam_attempt_count(UUID, TEXT, TEXT, TEXT) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.get_exam_teacher_id(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_platform_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_exam_open_for_submission(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_public_exam_by_code(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.verify_student_for_exam(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_exam_attempt_count(UUID, TEXT, TEXT, TEXT) TO anon, authenticated;

REVOKE ALL ON FUNCTION public.admin_get_all_profiles() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_get_all_exams() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_get_all_results() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_set_profile_status(UUID, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_set_profile_role(UUID, TEXT, TEXT) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_delete_profile(UUID) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_get_platform_stats() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_get_exam_results(UUID) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.admin_get_all_profiles() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_all_exams() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_all_results() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_profile_status(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_profile_role(UUID, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_profile(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_platform_stats() TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_exam_results(UUID) TO authenticated;

-- ═══════════════════════════════════════════════════════════════════
-- STEP 12: MIGRATE EXISTING AUTH USERS INTO PROFILES
-- ═══════════════════════════════════════════════════════════════════
-- Change the email below if your production admin email changes.

INSERT INTO public.profiles (id, email, full_name, role, is_admin, status)
SELECT
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'full_name',
           u.raw_user_meta_data->>'display_name',
           split_part(u.email, '@', 1)),
  CASE WHEN lower(u.email) = lower('buildingmyictcareer@gmail.com') THEN 'admin' ELSE 'teacher' END,
  CASE WHEN lower(u.email) = lower('buildingmyictcareer@gmail.com') THEN true ELSE false END,
  CASE WHEN lower(u.email) = lower('buildingmyictcareer@gmail.com') THEN 'active' ELSE 'active' END
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = u.id
)
ON CONFLICT (id) DO NOTHING;

-- Optional manual admin bootstrap. Replace YOUR-UUID-HERE with the UUID from
-- Supabase Dashboard → Authentication → Users, then uncomment if needed.
--
-- INSERT INTO public.profiles (id, email, full_name, role, is_admin, status)
-- VALUES (
--   'YOUR-UUID-HERE',
--   'buildingmyictcareer@gmail.com',
--   'Adewale Samson Adeagbo',
--   'admin',
--   true,
--   'active'
-- )
-- ON CONFLICT (id) DO UPDATE
--   SET email      = EXCLUDED.email,
--       full_name  = EXCLUDED.full_name,
--       role       = 'admin',
--       is_admin   = true,
--       status     = 'active',
--       updated_at = NOW();

-- ═══════════════════════════════════════════════════════════════════
-- STEP 13: VERIFICATION QUERIES
-- ═══════════════════════════════════════════════════════════════════

-- 1. Tables and RLS status. Expected: 4 rows, all rowsecurity=true.
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN ('profiles', 'exams', 'results', 'students')
ORDER BY tablename;

-- 2. Policies. Expected: teacher/admin policies and NO broad anonymous SELECT.
SELECT tablename, policyname, cmd, roles
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- 3. RPC functions. Expected: admin_* plus the public student RPCs.
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND (routine_name LIKE 'admin_%'
       OR routine_name IN ('get_public_exam_by_code', 'verify_student_for_exam', 'get_exam_attempt_count', 'get_exam_teacher_id', 'is_platform_admin', 'is_exam_open_for_submission'))
ORDER BY routine_name;

-- 4. Profiles list. Confirm your admin email has role='admin', is_admin=true, status='active'.
SELECT id, email, full_name, role, is_admin, status, created_at
FROM public.profiles
ORDER BY created_at DESC;

-- ═══════════════════════════════════════════════════════════════════
-- ✅ SETUP COMPLETE
-- ═══════════════════════════════════════════════════════════════════
-- Next steps:
--   1. Update SB_URL, SB_KEY, and ADMIN_EMAIL in teacher.html, student.html,
--      admin.html, and link_checker.html.
--   2. Supabase Auth → Providers → Email: decide whether to require email
--      confirmation. For school demos, OFF is easiest; for production, ON is safer.
--   3. Deploy to GitHub Pages, Netlify, Vercel, or Cloudflare Pages.
--   4. Test flow: teacher signup → admin approval → create exam → student submits
--      → teacher sees results → admin sees platform analytics.
--
-- HMG Academy CBT Pro v3.1 Enterprise
-- Learning Deliberately. Teaching Authentically.
-- ═══════════════════════════════════════════════════════════════════
