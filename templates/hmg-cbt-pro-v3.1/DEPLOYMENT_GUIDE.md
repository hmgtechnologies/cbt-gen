# HMG Academy CBT Pro v3.1 — Quick Deployment Guide

Use this as the short operational checklist. For full details, see `DEPLOYMENT.md`.

## A. Configure Supabase

1. Create a Supabase project.
2. Copy Project URL and anon key.
3. In Supabase SQL Editor, run `COMPLETE_SQL_SETUP.sql` from top to bottom.
4. Confirm verification queries show:
   - `profiles`, `exams`, `results`, `students`
   - RLS enabled on all four tables
   - `get_public_exam_by_code`
   - `verify_student_for_exam`
   - `get_exam_attempt_count`
   - admin RPC functions
5. In Authentication settings, decide whether Email Confirmation is ON or OFF.

## B. Configure frontend files

Edit these constants in `teacher.html`, `student.html`, `admin.html`, and `link_checker.html`:

```js
const SB_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SB_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Edit this in `teacher.html` and `admin.html`:

```js
const ADMIN_EMAIL = 'your-admin-email@example.com';
```

Never use the Supabase `service_role` key in frontend files.

## C. Deploy static files

Upload all files to any static host:

- GitHub Pages
- Netlify
- Vercel
- Cloudflare Pages

No build command is required.

## D. Test before production

1. Open `deployment_validator.html`.
2. Create a teacher account.
3. Approve teacher in `admin.html`.
4. Create an exam in `teacher.html`.
5. Open `student.html?code=XXXXXX`.
6. Submit a test result.
7. Confirm result appears in teacher and admin dashboards.
8. Export CSV to confirm reporting works.

## E. v3.1 security reminders

- Students use RPCs, not broad anonymous table reads.
- Attempt limit is enforced through `get_exam_attempt_count`.
- Registered student verification is through `verify_student_for_exam`.
- Student submissions are accepted only for open, non-expired exams.
- Admin RPCs require a real admin profile inside PostgreSQL.

## F. Rollback plan

If deployment fails:

1. Restore previous static files.
2. Do not delete Supabase data.
3. Re-run `COMPLETE_SQL_SETUP.sql` after fixing config.
4. Check browser console and Supabase logs.
