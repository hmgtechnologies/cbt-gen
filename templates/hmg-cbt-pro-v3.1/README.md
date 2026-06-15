# 🎓 HMG Academy CBT Pro v3.1 Enterprise

> **The CBT platform built for African classrooms** — free static hosting, Supabase free-tier backend, no paid AI API, no student app install, and no student accounts required.

**Brand owner:** HMG Concepts / HMG Academy  
**Founder:** Adewale Samson Adeagbo — Data Scientist, STEM Educator, AI-Augmented Solutions Developer  
**Support:** WhatsApp +234 810 086 6322 · Phone +234 907 790 7677 · hismarvellousgrace@gmail.com · buildingmyictcareer@gmail.com  
**Web:** https://hmgacademy.pages.dev/ · https://hmgconcepts.pages.dev/

---

## 1. What this system does

HMG Academy CBT Pro is a browser-based computer-based testing platform for schools, tutorial centres, examination practice programmes, and training organisations. It provides three portals:

| Portal | File | Purpose |
|---|---|---|
| Public landing page | `index.html` | Explains the platform and directs users to each portal. |
| Teacher dashboard | `teacher.html` | Create exams, upload/import questions, manage students, monitor results, export analytics. |
| Student portal | `student.html` | Students enter an exam code/link, take the exam, auto-save progress, submit, and receive a result or held-result notice. |
| Admin panel | `admin.html` | Approve teachers, supervise platform data, run security/deployment checks, export platform data. |

The platform is intentionally **zero-build**: upload the files to GitHub Pages, Netlify, Vercel, Cloudflare Pages, or any static hosting provider. Supabase supplies database and authentication using the free tier.

---

## 2. Major v3.1 enterprise upgrades

v3.1 focuses on correctness, security, and enterprise readiness while preserving all existing features.

### Database and SQL correctness

- `COMPLETE_SQL_SETUP.sql` has been rearranged so all helper functions exist **before** RLS policies reference them.
- Admin RPC functions now enforce admin status inside PostgreSQL through `public.is_platform_admin()`.
- Anonymous students no longer need broad table reads for exams, results, or rosters.
- Public student actions now use safe RPCs:
  - `get_public_exam_by_code(p_code)`
  - `verify_student_for_exam(p_exam_id, p_student_id)`
  - `get_exam_attempt_count(p_exam_id, p_student_name, p_student_class, p_student_id_ref)`
- Results now store decimal scores using `NUMERIC(10,2)` for partial-credit question types.
- Student submissions are accepted only when the exam is open, active, not archived, and not expired.

### Platform features added/enhanced

- Secure public exam loading RPC.
- Secure registered-student ID verification RPC.
- Secure attempt-count RPC.
- Decimal partial-credit scoring.
- Negative marking enforcement.
- Teacher-controlled result release/hold mode.
- Certificate/submission verification code saved with each result.
- JAMB-style keyboard shortcuts: `A-D`, `N`, `P`, arrow keys, `R`, `S`.
- CSV question metadata: `Difficulty`, `Tags`, and `Section` columns.
- Safer mixed old/new question storage parsing.
- Updated deployment validator and link checker.
- Updated documentation and security guidance.

---

## 3. Question types supported

| Type | Code | Auto-scored? | Notes |
|---|---:|---:|---|
| Multiple Choice | `mcq` | Yes | A-D option selection. |
| Multiple Response | `mrq` | Yes | Partial credit or all-or-nothing. |
| True/False | `tf` | Yes | A=True, B=False. |
| Short Answer | `short` | Yes | Exact/accepted-answer list. |
| Numeric | `numeric` | Yes | Supports tolerance and units. |
| Matching | `matching` | Yes | Partial credit by matched pairs. |
| Ordering | `ordering` | Yes | Partial credit by correct position. |
| Cloze / multi-blank | `cloze` | Yes | Pipe-separated accepted answers per blank. |
| Essay | `essay` | Rule-based | Keyword/minimum-word score; teacher review recommended. |
| Categorization | `categorization` | Yes | Partial credit per item category. |
| Multi-numeric | `multi_numeric` | Yes | Several numeric answers in one question. |

### CSV columns

```text
Question,A,B,C,D,CorrectAnswer,Explanation,Type,Tolerance,Unit,Accept,MRQ_AON,Pairs,Items,Difficulty,Tags,Section
```

The first 7 columns remain backward-compatible. Columns 8–17 are optional and enable advanced question types, scoring controls, analytics, and item-bank metadata.

---

## 4. Enterprise feature overview

### Teacher dashboard

- Account signup/login through Supabase Auth.
- Admin approval workflow through `profiles.status`.
- Create exams with subject, class, term, topic, session, type, pass mark, duration, attempt limit, question count, open/registered mode, schedule, close time, negative marking, instructions, and result-release control.
- Upload questions via CSV/XLSX/PDF/manual entry.
- Edit full exam metadata after publishing.
- Append questions to existing exams.
- Export/import exam packages as JSON.
- Print invigilator access sheets.
- Manage registered-student rosters.
- View results with answer breakdowns.
- Export results, item analysis, and analytics CSV.
- Generate browser-only rule-based insights.
- Import emergency student result backup JSON.

### Student portal

- Access by link or code.
- Open mode: name + class.
- Registered mode: secure student ID verification RPC.
- Integrity pledge.
- Countdown timer.
- Question navigation.
- Flag questions.
- Auto-save draft in `localStorage`.
- Scientific calculator.
- Text-to-speech/read-aloud.
- Keyboard shortcuts for CBT speed practice.
- Fullscreen/tab-switch/copy/right-click/devtools/audio/face flags.
- Emergency result backup JSON.
- Instant result if released, or held-result notice if teacher selected hold.

### Admin panel

- Admin login by configured email or `profiles.is_admin = true`.
- Approve, deactivate, reactivate, promote, and remove teacher profiles.
- View platform-wide exams/results.
- Export platform data.
- Run security checks.
- Download RLS smoke-test SQL.
- Broadcast local browser notice.
- Review teacher activity and platform health.

---

## 5. File inventory

```text
.nojekyll
_headers
admin.html
assets/hmg-academy-logo.png
CHANGELOG.md
COMPLETE_SQL_SETUP.sql
CONTRIBUTING.md
DEPLOYMENT.md
DEPLOYMENT_GUIDE.md
deployment_validator.html
DIAGNOSIS_REPORT.md
EXPERT_ENHANCEMENT_REPORT.md
feature_guide.html
FEATURES.md
FEATURES_GUIDE.md
further_maths_sample.csv
hmg-academy-logo.png
hmg-icon.svg
index.html
LICENSE
link_checker.html
manifest.webmanifest
offline.html
PROMPT_TEMPLATE.md
README.md
SECURITY.md
student.html
sw.js
```

> Note: `assets/hmg-academy-logo.png` is the primary logo used by the live pages. The root `hmg-academy-logo.png` is retained for backward compatibility with older deployments.

---

## 6. Deployment quick start

1. Create a Supabase project.
2. Copy the Project URL and anon public key.
3. Replace `SB_URL` and `SB_KEY` in:
   - `teacher.html`
   - `student.html`
   - `admin.html`
   - `link_checker.html`
4. Set `ADMIN_EMAIL` in `teacher.html` and `admin.html`.
5. Run **all** of `COMPLETE_SQL_SETUP.sql` in Supabase SQL Editor.
6. Upload the repository files to GitHub Pages/Netlify/Vercel/Cloudflare Pages.
7. Visit `deployment_validator.html`.
8. Test: teacher signup → admin approval → create exam → student submit → teacher/admin verify result.

For detailed steps, read `DEPLOYMENT.md`.

---

## 7. Cost model

| Layer | Tool | Cost |
|---|---|---:|
| Hosting | GitHub Pages / Netlify / Vercel / Cloudflare Pages | Free tier |
| Database | Supabase Postgres | Free tier |
| Auth | Supabase Auth | Free tier |
| Charts | Chart.js CDN with graceful fallback | Free |
| PWA/offline shell | Service worker | Free |
| Proctoring helpers | Browser APIs + optional free CDN model | Free |
| AI API | Not used | ₦0 |

---

## 8. Security principles

- Never place a Supabase `service_role` key in any frontend file.
- Use only the anon key in HTML.
- Run the v3.1 SQL so RLS and RPC guards are active.
- Treat exam access codes as private bearer tokens.
- Rotate exam codes if shared accidentally.
- Use HTTPS in production.
- Export backups regularly.
- Review `SECURITY.md` before production use.

---

## 9. Brand statement

HMG Academy CBT Pro is part of the HMG Technologies mission under HMG Concepts: **Learning Deliberately. Teaching Authentically.** It is built for Nigerian and African education realities — low budgets, mixed devices, variable internet, and the need for dependable assessment workflows without expensive subscriptions or paid AI APIs.


---

## 10. Complete file inventory

A complete file-by-file inventory is available in `FILE_INVENTORY.md`.
