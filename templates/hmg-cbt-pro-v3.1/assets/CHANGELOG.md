# Changelog — HMG Academy CBT Pro

## v3.1 Enterprise Security & Correctness Release — 2026-06-14

### SQL and database fixes

- Reordered `COMPLETE_SQL_SETUP.sql` so helper functions are created before RLS policies reference them.
- Added `public.is_platform_admin()` and made admin RPCs enforce admin status inside PostgreSQL.
- Removed dependency on broad anonymous `SELECT` policies for exams and students.
- Replaced unsafe `WITH CHECK (true)` student result insert with `public.is_exam_open_for_submission(exam_id)`.
- Added public student RPCs:
  - `get_public_exam_by_code`
  - `verify_student_for_exam`
  - `get_exam_attempt_count`
- Added schedule-aware public exam loading: question data is hidden before scheduled start time.
- Changed `results.score` to `NUMERIC(10,2)` for partial-credit accuracy.
- Added/standardised indexes for exams, results, profiles, and students.
- Added/standardised constraints for roles, statuses, modes, durations, attempts, and non-negative scores.
- Added safer grants and explicit RPC execution permissions.
- Updated SQL snippets embedded in `teacher.html` and `admin.html`.

### Student portal

- Student exam loading now uses secure public RPC with legacy REST fallback.
- Registered-student ID verification now uses secure RPC with legacy fallback.
- Attempt-limit checking now uses secure RPC instead of anonymous result table reads.
- Implemented negative-marking deduction.
- Implemented held-result display when `release_results=false`.
- Added submission/certificate verification code display and storage.
- Added JAMB-style keyboard shortcuts.
- Fixed scheduled wait-room issue by re-fetching exam data after start time.
- Added robust question-data parser for old JSON-string and new JSONB-array formats.
- Fixed typo: `HMT Academy` → `HMG Academy`.
- Improved typed-answer keyboard handling so normal input editing is not incorrectly flagged as cheating.

### Teacher dashboard

- Stores question banks as native JSONB arrays while still reading old JSON-string records.
- Added robust `parseQuestionData()` and `cloneQuestionData()` helpers.
- Added CSV metadata support: `Difficulty`, `Tags`, `Section`.
- Added signup full-name metadata to Supabase Auth signup.
- Updated question template header to include metadata fields.
- Updated embedded SQL snippets to v3.1 security model.

### Admin panel

- Added robust question-data parser.
- Updated teacher rejection wording to clarify that frontend cannot delete Supabase Auth users without a service key.
- Updated SQL setup text to remove old insecure anonymous roster/read policy language.
- Updated embedded admin RPC SQL to server-side admin guard model.

### Tools and docs

- Updated `deployment_validator.html` required file list and SQL checks.
- Updated `link_checker.html` to use secure public exam RPC and schedule-aware messages.
- Updated `sw.js` cache name to `hmg-cbt-shell-v7`.
- Updated `index.html` from v2.0 wording to v3.1 Enterprise.
- Updated `further_maths_sample.csv` with metadata columns.
- Rewrote/expanded README, deployment, features, security, diagnosis, enhancement, and prompt documentation.

---

## v3.0 Enterprise Baseline

- Added full exam editing.
- Added question append workflows.
- Added registered-student mode.
- Added proctoring snapshot support.
- Added deployment validator.
- Added feature guide.
- Added exam package export/import.
- Added item analysis and analytics exports.
- Added PWA/offline shell.

---

## v2.x Enhanced Baseline

- Teacher, student, and admin portals.
- CSV question upload.
- Exam access codes and links.
- Student countdown timer.
- Basic results and exports.
- Supabase backend integration.
