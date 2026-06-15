# Diagnosis Report — HMG Academy CBT Pro v3.1

Date: 2026-06-14  
Reviewer role: Expert CBT platform auditor, Supabase/RLS reviewer, frontend QA reviewer, deployment reviewer.

---

## 1. Repository diagnosis summary

The repository is a static web CBT platform with Supabase backend. It already had a strong feature base: teacher dashboard, student portal, admin panel, CSV upload, result analytics, PWA shell, proctoring helpers, and detailed branding.

The main issues identified were not design issues; they were **production correctness and security-arrangement issues**:

1. SQL helper functions were referenced before guaranteed creation in some setup snippets.
2. Some embedded SQL snippets used older insecure assumptions, especially broad anonymous reads.
3. Admin RPC functions needed server-side admin validation, not just frontend checks.
4. Student attempt-limit checking depended on anonymous result reads in the old flow.
5. Registered-student verification depended on anonymous roster reads in the old flow.
6. `results.score` was integer-based, while multiple question types produce partial credit.
7. `release_results` and `negative_mark` existed but were not fully enforced in student scoring/display.
8. Old and new Supabase JSONB storage formats could coexist and needed robust parsing.
9. The public landing page still displayed older v2.0 labels.
10. Documentation needed to reflect the enterprise/security model clearly.

---

## 2. Files reviewed

All visible repository files were reviewed:

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
teacher.html
```

---

## 3. SQL diagnosis

### Previous risk

Older setup snippets allowed or implied:

- broad anonymous exam reads;
- broad anonymous roster verification;
- unrestricted student result inserts;
- admin RPCs without internal admin assertion.

### v3.1 correction

`COMPLETE_SQL_SETUP.sql` now creates/updates objects in the correct order:

1. extension
2. tables
3. upgrade columns/types
4. indexes/constraints
5. helper functions
6. RLS enablement
7. policy cleanup
8. policies
9. triggers
10. public student RPCs
11. admin RPCs
12. function grants
13. user migration
14. verification queries

This arrangement prevents “function does not exist” policy errors and reduces accidental data exposure.

---

## 4. Frontend diagnosis

### Student portal

Issues fixed:

- exam loading now uses `get_public_exam_by_code`;
- attempt count now uses `get_exam_attempt_count`;
- student ID verification now uses `verify_student_for_exam`;
- negative marking is applied;
- held results are hidden from students;
- decimal partial scores are saved;
- verification code is displayed/saved;
- scheduled exam wait room re-fetches data at start;
- keyboard shortcuts were added;
- question JSON parsing is robust.

### Teacher dashboard

Issues fixed:

- question storage now works with both native JSONB arrays and older JSON strings;
- CSV question metadata columns were added;
- signup now passes full-name metadata;
- embedded SQL snippets were updated;
- question template was updated.

### Admin panel

Issues fixed:

- question JSON parsing is robust;
- teacher rejection wording no longer claims the static frontend can delete Supabase Auth users;
- SQL documentation now reflects secure RPC/RLS design.

---

## 5. Deployment diagnosis

`deployment_validator.html` previously referenced a non-existent enhancement report filename. It now checks the actual required files and v3.1 SQL/RPC security indicators.

`sw.js` cache was bumped to force updated app-shell caching.

---

## 6. Feature gap diagnosis from market scan

A review of CBT/exam platforms showed recurring enterprise features:

- question banks with metadata and randomization;
- secure exam delivery/browser restrictions;
- candidate identity verification;
- scheduling and access windows;
- detailed analytics and item analysis;
- certificates/credential codes;
- offline or low-connectivity resilience;
- bulk import/export;
- proctoring/integrity logs;
- LMS/API integrations;
- accessibility features;
- practice-mode familiarity tools.

The v3.1 platform addresses many of these with free tools. Paid-only items such as enterprise live proctoring, true lockdown browser, SSO, LTI, and paid AI grading are documented as limitations rather than falsely claimed.

---

## 7. Remaining limitations

- No true native lockdown browser because this is a free static web app.
- No paid AI API by design.
- Browser proctoring can be bypassed by determined users.
- Static frontend cannot securely hold secrets.
- Result release is controlled at submission display; a full post-release student re-access portal would require an additional secure result lookup workflow.
- Very large question banks may approach Supabase/free-browser storage limits.

---

## 8. Final diagnosis verdict

The platform is now stronger, safer, and more deployment-ready. The largest improvement is the corrected Supabase security architecture: **students use safe RPCs, teachers use RLS-isolated data, and admins use server-verified RPCs.**

Recommended next step before production: deploy the `CBT` folder, run `COMPLETE_SQL_SETUP.sql`, and test one full teacher → student → result → admin flow.
