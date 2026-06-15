# 🚀 HMG Academy CBT Pro v3.1 — Complete Deployment Guide

This guide explains how to deploy the CBT system using free or free-tier tools. It assumes no paid AI API and no paid server.

---

## 1. What you need

| Requirement | Recommended free tool |
|---|---|
| Static hosting | GitHub Pages, Netlify, Vercel, or Cloudflare Pages |
| Database | Supabase Postgres free tier |
| Authentication | Supabase Auth free tier |
| Browser | Chrome/Edge/Firefox/Safari latest |
| Code editor | VS Code, Notepad++, or any text editor |

---

## 2. Files to upload

Upload every file in the project root except `.git`:

```text
index.html
teacher.html
student.html
admin.html
link_checker.html
deployment_validator.html
feature_guide.html
offline.html
sw.js
manifest.webmanifest
hmg-icon.svg
hmg-academy-logo.png
assets/hmg-academy-logo.png
COMPLETE_SQL_SETUP.sql
README.md
DEPLOYMENT.md
DEPLOYMENT_GUIDE.md
FEATURES.md
FEATURES_GUIDE.md
SECURITY.md
CHANGELOG.md
CONTRIBUTING.md
PROMPT_TEMPLATE.md
DIAGNOSIS_REPORT.md
EXPERT_ENHANCEMENT_REPORT.md
further_maths_sample.csv
_headers
.nojekyll
LICENSE
```

---

## 3. Step-by-step Supabase setup

### Step 3.1 — Create the project

1. Go to https://supabase.com.
2. Sign in or create a free account.
3. Click **New Project**.
4. Enter project name, password, and region.
5. Wait for the project to finish provisioning.

### Step 3.2 — Copy API values

Open **Project Settings → API** and copy:

- Project URL, e.g. `https://xxxxx.supabase.co`
- `anon` public key

### Step 3.3 — Update frontend config

Open these files and replace the constants:

```js
const SB_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SB_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Files:

- `teacher.html`
- `student.html`
- `admin.html`
- `link_checker.html`

Also update admin email in:

```js
const ADMIN_EMAIL = 'buildingmyictcareer@gmail.com';
```

Files:

- `teacher.html`
- `admin.html`

Use your real production admin email if different.

---

## 4. Run the database SQL

1. Open `COMPLETE_SQL_SETUP.sql`.
2. Copy the entire file.
3. Go to Supabase **SQL Editor**.
4. Create a new query.
5. Paste the SQL.
6. Click **Run**.

### Why the full SQL matters

The v3.1 SQL is not just table creation. It also creates:

- `profiles`, `exams`, `results`, `students`
- all missing upgrade columns
- decimal score support
- RLS policies
- admin-safe RPC functions
- student-safe RPC functions
- trigger for new teacher profiles
- admin bootstrap/migration
- verification queries

### Expected verification output

At the end, Supabase should show:

- 4 public tables with `rowsecurity = true`
- policies for profiles/exams/results/students
- RPC functions including:
  - `get_public_exam_by_code`
  - `verify_student_for_exam`
  - `get_exam_attempt_count`
  - `admin_get_all_profiles`
  - `admin_get_all_exams`
  - `admin_get_all_results`
  - `is_platform_admin`
- your admin profile row active and admin-enabled

---

## 5. Supabase Auth settings

### For demos and school labs

1. Go to **Authentication → Providers → Email**.
2. Turn **Confirm email** OFF.
3. Save.

This lets teachers sign up and be approved quickly.

### For production

Keep email confirmation ON if your school wants stronger identity assurance. If you keep it ON, teachers must click the Supabase email link before they can login.

### Redirect URLs

Go to **Authentication → URL Configuration** and add your deployment domain, for example:

```text
https://hmgacademyhub.github.io/cbt-system/
https://hmgacademyhub.github.io/cbt-system/teacher.html
https://hmgacademyhub.github.io/cbt-system/admin.html
```

Add Netlify/Vercel/Cloudflare URLs too if you use them.

---

## 6. GitHub Pages deployment

1. Create or open your GitHub repository.
2. Upload all files into the repository root.
3. Go to **Settings → Pages**.
4. Under **Build and deployment**, choose:
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/root`
5. Save.
6. Wait 1–5 minutes.
7. Visit the generated URL.

If your project is under a repository path such as `/cbt-system/`, relative links already work because the files use relative paths.

---

## 7. Netlify deployment

1. Go to https://netlify.com.
2. Click **Add new site**.
3. Choose **Deploy manually** or connect GitHub.
4. Drag the project folder or connect the repo.
5. Build command: leave empty.
6. Publish directory: project root.
7. Deploy.

Optional: add the `_headers` file for security headers. Netlify reads it automatically.

---

## 8. Vercel deployment

1. Go to https://vercel.com.
2. Import the repository.
3. Framework preset: **Other**.
4. Build command: blank.
5. Output directory: blank/root.
6. Deploy.

---

## 9. Cloudflare Pages deployment

1. Go to Cloudflare Dashboard → Pages.
2. Connect your GitHub repository.
3. Framework preset: None.
4. Build command: blank.
5. Build output directory: `/`.
6. Deploy.

---

## 10. Post-deployment test plan

Run this test before sharing with real students.

### Teacher flow

1. Open `teacher.html`.
2. Sign up as a teacher.
3. Open `admin.html` with the admin account.
4. Approve the teacher.
5. Login again as teacher.
6. Create an exam with 3–5 questions.
7. Copy the exam link/code.

### Student flow

1. Open `student.html?code=XXXXXX`.
2. Enter student name/class or verify student ID if registered mode.
3. Answer the exam.
4. Submit.
5. Confirm result is saved.

### Teacher result flow

1. Return to `teacher.html`.
2. Open Results.
3. Confirm the student submission appears.
4. Open answer breakdown.
5. Export results CSV.

### Admin flow

1. Open `admin.html`.
2. Confirm teachers, exams, and results appear.
3. Run security checks.
4. Export platform CSV.

---

## 11. Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| Teacher cannot login | Wrong Supabase URL/key or email not confirmed | Check `SB_URL`, `SB_KEY`, Auth email confirmation setting. |
| Teacher sees “pending approval” | Admin has not approved teacher | Login as admin and approve. |
| Student code says exam not found | Exam closed, archived, expired, wrong code, or SQL not run | Re-open exam, check code, run `COMPLETE_SQL_SETUP.sql`. |
| Registered student cannot verify ID | Roster not uploaded or RPC missing | Upload roster and re-run SQL. |
| Attempt limit not enforced | Attempt-count RPC missing | Re-run SQL and verify `get_exam_attempt_count`. |
| Results do not save | RLS/policy missing or exam closed | Re-run SQL and ensure exam is open/not expired. |
| Admin sees no data | Admin RPC not created or admin profile inactive | Re-run SQL, set `profiles.is_admin=true`, `status='active'`. |
| Charts not visible offline | Chart.js CDN unavailable | Exports still work; reconnect internet for charts. |
| Camera/proctoring blocked | Browser permission/HTTPS issue | Use HTTPS and allow camera/microphone. |
| PWA not updating | Old service worker cache | Hard refresh or clear site data; v3.1 uses `hmg-cbt-shell-v7`. |

---

## 12. Production checklist

- [ ] `SB_URL` and `SB_KEY` updated in all required files.
- [ ] `ADMIN_EMAIL` updated.
- [ ] `COMPLETE_SQL_SETUP.sql` run successfully.
- [ ] Admin profile active and admin-enabled.
- [ ] RLS enabled on all tables.
- [ ] No `service_role` key in frontend.
- [ ] HTTPS deployment active.
- [ ] Teacher signup tested.
- [ ] Admin approval tested.
- [ ] Exam creation tested.
- [ ] Student submission tested.
- [ ] Teacher results tested.
- [ ] Admin exports tested.
- [ ] Backup/export tested.
- [ ] Deployment validator passes.

---

## 13. Updating an existing deployment

1. Backup current repository files.
2. Backup Supabase data:
   - export exams/results from teacher/admin dashboards;
   - optionally use Supabase table export.
3. Upload v3.1 files.
4. Run the full `COMPLETE_SQL_SETUP.sql` again.
5. Hard refresh browser cache.
6. Re-test one full exam flow.

The SQL is designed to be idempotent and preserves data.

---

## 14. No paid AI API policy

The platform deliberately avoids AI API calls because paid APIs are not cost-effective for many schools. Essay scoring and insights are transparent rule-based logic in the browser. Teachers should still review high-stakes essays manually.
