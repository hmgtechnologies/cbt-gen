# Security Policy — HMG Academy CBT Pro v3.1

This document explains the security model, required configuration, operational precautions, and known limitations.

---

## 1. Security model

HMG Academy CBT Pro is a static frontend application backed by Supabase. Because HTML/JavaScript files are public by design, all critical access control must happen in Supabase through:

- Row Level Security (RLS)
- SQL helper functions
- RPC functions
- PostgreSQL-side admin checks
- strict use of anon key only in frontend

The v3.1 SQL setup implements this model in `COMPLETE_SQL_SETUP.sql`.

---

## 2. Keys and secrets

### Safe in frontend

- Supabase Project URL
- Supabase anon public key

### Never safe in frontend

- Supabase `service_role` key
- Database password
- SMTP credentials
- private API keys
- AI API keys
- payment secret keys

If a `service_role` key is ever exposed, rotate it immediately in Supabase.

---

## 3. RLS tables

| Table | Protection |
|---|---|
| `profiles` | Users see/update own profile; admins supervise all. |
| `exams` | Teachers manage own exams; admins supervise all. |
| `results` | Teachers see results for own exams; admins supervise all; students can insert only into open active exams. |
| `students` | Teachers manage own rosters; admins supervise all; anonymous lookup is blocked. |

---

## 4. Public student access

Students are not logged in. v3.1 therefore uses safe public RPCs instead of broad anonymous table reads.

| RPC | Purpose |
|---|---|
| `get_public_exam_by_code` | Loads only an open, non-archived, non-expired exam by code. Hides question data before scheduled start time. |
| `verify_student_for_exam` | Confirms a student ID belongs to the exam teacher’s roster without exposing the whole roster. |
| `get_exam_attempt_count` | Counts previous attempts for attempt-limit enforcement without exposing all results. |

---

## 5. Admin access

Admin RPC functions call `public.is_platform_admin()` inside PostgreSQL. A frontend-only admin check is never enough.

Admin access is granted when:

- the authenticated user has a profile row with `is_admin = true` or `role = 'admin'`; and
- `status = 'active'`;

or when the configured emergency admin email matches the JWT email.

Default embedded admin email in the repo:

```text
buildingmyictcareer@gmail.com
```

Change it in production if needed.

---

## 6. Exam-code safety

Exam codes are bearer-style access tokens. Anyone with the code/link can enter an open exam unless the exam is in registered mode.

Recommended controls:

- Use registered mode for high-stakes exams.
- Rotate codes if a link leaks.
- Set close time.
- Use start time for scheduled exams.
- Disable/close exams immediately after the session.
- Avoid posting high-stakes exam links in public groups.

---

## 7. Proctoring and integrity limits

Browser proctoring provides useful flags, not absolute proof of cheating.

### What it can detect/flag

- tab switching
- app/window focus loss
- right click
- copy/cut/paste attempts
- print/view-source/devtools shortcuts
- likely devtools window opening
- fullscreen exit
- camera snapshots if permitted
- multiple/no-face signal when optional model loads
- loud audio spikes

### What it cannot guarantee

- that the student has no second device
- perfect identity verification
- perfect face detection on all devices
- impossible-to-bypass browser controls
- high-stakes legal proctoring equivalence

For high-stakes exams, combine the platform with human invigilation, lab seating controls, ID checks, and post-exam result review.

---

## 8. Privacy guidance

The platform may store:

- student name/class/ID
- answers
- score
- timing
- integrity logs
- optional proctoring snapshots

Schools should:

- inform students before proctored exams;
- avoid unnecessary camera use for low-stakes quizzes;
- export and delete old data according to school policy;
- restrict admin access;
- protect CSV exports and backups.

---

## 9. Incident response

If something goes wrong:

1. Close affected exams in teacher/admin dashboard.
2. Rotate exam codes.
3. Export logs/results for audit.
4. Check Supabase SQL/RLS policies.
5. Check whether a frontend file accidentally contains a secret.
6. Rotate Supabase keys if secrets were exposed.
7. Re-run `COMPLETE_SQL_SETUP.sql`.
8. Re-test with a dummy exam.

---

## 10. Production hardening checklist

- [ ] HTTPS enabled.
- [ ] `COMPLETE_SQL_SETUP.sql` run fully.
- [ ] RLS enabled on all four tables.
- [ ] No broad anonymous `SELECT` policy on `students`.
- [ ] No broad anonymous `SELECT` policy on `results`.
- [ ] Student insert policy checks `is_exam_open_for_submission`.
- [ ] Admin RPC functions use `is_platform_admin`.
- [ ] No `service_role` key in frontend.
- [ ] Admin profile is active.
- [ ] Teacher approval workflow tested.
- [ ] Link checker tested.
- [ ] Deployment validator tested.
- [ ] Data export/backup policy defined.

---

## 11. Reporting vulnerabilities

Contact HMG Concepts / HMG Academy:

- WhatsApp: +234 810 086 6322
- Phone: +234 907 790 7677
- Email: hismarvellousgrace@gmail.com
- Tech/partnerships: buildingmyictcareer@gmail.com

Please include:

- page/file affected;
- steps to reproduce;
- browser/device;
- screenshots or console errors if available;
- whether real student data was involved.
