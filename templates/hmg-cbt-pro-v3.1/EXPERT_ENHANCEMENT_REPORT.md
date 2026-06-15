# Expert Enhancement Report — HMG Academy CBT Pro v3.1 Enterprise

Date: 2026-06-14  
Prepared for: HMG Academy / HMG Concepts  
Founder: Adewale Samson Adeagbo

---

## 1. Executive summary

The CBT platform was upgraded from a feature-rich static/Supabase CBT system into a more secure, enterprise-ready v3.1 release. Existing features were preserved and strengthened. The work focused on:

- SQL correctness and proper arrangement;
- RLS security hardening;
- safe public student access;
- admin RPC hardening;
- partial-credit/decimal score accuracy;
- negative marking;
- held-result workflow;
- keyboard shortcuts for CBT/JAMB-style exam practice;
- question metadata for item-bank analytics;
- documentation and deployment clarity;
- brand integration.

No paid AI API was added.

---

## 2. Internet/market research summary

Modern CBT and online examination systems commonly include the following unique/high-value features:

| Market feature | Observed in market | Implemented/enhanced in HMG CBT |
|---|---|---|
| Question banks | Questionmark, Moodle, ProProfs, TestInvite | CSV/XLSX/manual import, exam packages, metadata columns. |
| Randomization | Questionmark, Moodle, JAMB practice apps | Random question selection and shuffled delivery. |
| Multiple question types | ProProfs, iSpring, Moodle, Eklavvya | 11+ types supported. |
| Secure browser/proctoring | Respondus, ExamSoft, Proctorio | Browser integrity flags and proctor snapshots using free tools. |
| Candidate verification | Proctoring platforms, enterprise CBT | Registered-student mode with secure RPC. |
| Scheduling | Enterprise exam tools | Start and close time support. |
| Attempt controls | LMS/CBT systems | Secure attempt-count RPC. |
| Analytics | ExamSoft, Questionmark, ProProfs | Result analytics, item analysis, CSV exports. |
| Certificates/credentials | ProProfs, SpeedExam | Submission/certificate verification code. |
| Offline/low-connectivity resilience | JAMB practice tools, offline CBT | PWA shell, drafts, emergency backup JSON. |
| Accessibility | Moodle/Inspera/modern exam tools | Read aloud, responsive UI, keyboard shortcuts. |
| Bulk import | Most CBT tools | CSV/XLSX/roster import. |
| Branding | Enterprise tools | HMG Academy/HMG Concepts embedded across files. |

Because the requirement was to use free-based tools and avoid AI API costs, paid features such as true lockdown browser, live remote proctors, SSO/LTI, and paid AI essay grading were not added. Instead, free browser/Supabase equivalents were implemented where realistic.

---

## 3. Main enhancements delivered

### 3.1 SQL architecture

`COMPLETE_SQL_SETUP.sql` was fully restructured:

1. Extension creation.
2. Table creation.
3. Safe upgrade columns.
4. Decimal score conversion.
5. Indexes and constraints.
6. Helper functions.
7. RLS enablement.
8. Policy cleanup.
9. Correct RLS policies.
10. Triggers.
11. Public student RPCs.
12. Admin RPCs.
13. Grants.
14. Existing user migration.
15. Verification queries.

This is the correct operational arrangement for Supabase/Postgres.

### 3.2 Security hardening

- Removed reliance on broad anonymous table reads.
- Added safe RPCs for student flows.
- Added server-side admin verification.
- Student result inserts now require the exam to be open, active, not archived, started, and not expired.
- Service-role key remains excluded from frontend.

### 3.3 Scoring upgrades

- Partial-credit question types now store decimal scores.
- Negative marking is applied consistently.
- Correct/wrong/skipped counts are stored.
- Scoring summary is included in `answers_data`.

### 3.4 Student experience upgrades

- Code/link entry retained.
- Wait room improved.
- Keyboard shortcuts added.
- Held-result screen added.
- Submission/certificate verification code added.
- Emergency backup retained.

### 3.5 Teacher experience upgrades

- Question data parser handles old and new storage formats.
- CSV template supports `Difficulty`, `Tags`, and `Section`.
- SQL guide updated.
- Exam editing, appending, exports, backups, and analytics retained.

### 3.6 Admin experience upgrades

- Admin RPC security strengthened.
- Admin SQL blocks updated.
- Teacher removal language corrected.
- Platform-wide exports retained.

---

## 4. File-by-file enhancement notes

| File | Enhancements |
|---|---|
| `COMPLETE_SQL_SETUP.sql` | Full v3.1 corrected SQL, safe RLS/RPC architecture. |
| `teacher.html` | Secure SQL snippets, JSONB parser, metadata CSV support, full-name signup metadata. |
| `student.html` | RPC exam loading, RPC student verification, RPC attempt count, negative marking, held results, certificate code, shortcuts. |
| `admin.html` | JSONB parser, updated SQL snippets, admin wording correction. |
| `link_checker.html` | Secure public RPC check and scheduled-exam awareness. |
| `deployment_validator.html` | Correct file checks and v3.1 SQL/RPC validation. |
| `index.html` | Version updated to v3.1 Enterprise. |
| `sw.js` | Cache bumped to v7. |
| `further_maths_sample.csv` | Metadata columns added. |
| `README.md` | Rewritten comprehensive v3.1 overview. |
| `DEPLOYMENT.md` | Rewritten detailed deployment guide. |
| `DEPLOYMENT_GUIDE.md` | Updated quick deployment guide. |
| `FEATURES.md` | Rewritten detailed features file. |
| `FEATURES_GUIDE.md` | Updated user guide. |
| `SECURITY.md` | Rewritten security model. |
| `CHANGELOG.md` | Updated v3.1 changelog. |
| `DIAGNOSIS_REPORT.md` | Updated diagnosis. |
| `EXPERT_ENHANCEMENT_REPORT.md` | This report. |

---

## 5. Enterprise features now available without paid AI API

1. Role-based teacher/admin workflows.
2. Admin approval workflow.
3. Secure public exam access.
4. Registered-student identity verification.
5. Attempt-limit enforcement.
6. Exam scheduling and close windows.
7. Negative marking.
8. Result hold/release display control.
9. Decimal partial-credit scoring.
10. Multi-question-type authoring.
11. Question metadata tagging.
12. Item analysis exports.
13. Performance analytics.
14. Emergency student backup.
15. Teacher full backup.
16. Exam package export/import.
17. PWA/offline shell.
18. Proctoring/integrity logs.
19. Certificate/submission code.
20. Deployment validator.
21. Link/code health checker.
22. Security checklist/smoke-test support.

---

## 6. What was intentionally not added

| Feature | Reason |
|---|---|
| Paid AI essay grading | User specified no AI API due to cost. |
| True lockdown browser | Requires native application or paid secure-browser product. |
| Live remote human proctoring | Requires staffing or paid service. |
| SSO/LTI | Usually requires paid LMS/identity infrastructure and more backend work. |
| Payment/e-commerce | Outside school CBT core and may require secret keys. |

---

## 7. Recommended future roadmap

### Free/low-cost additions

- Result verification page by certificate code.
- Teacher-controlled release-results page for held results.
- More item-bank filtering by tags/difficulty.
- Printable seating/invigilator attendance sheet.
- Import/export Moodle GIFT or QTI-lite format.
- More accessibility controls: contrast mode, dyslexia-friendly font toggle.
- Local LAN deployment guide using Supabase self-hosting or local Postgres for advanced users.

### Paid/enterprise only if budget becomes available

- True lockdown browser.
- Live proctoring integrations.
- SSO/LMS integration.
- Dedicated backend for server-side marking and audit logs.
- Encrypted storage buckets for proctoring media.

---

## 8. Final expert verdict

HMG Academy CBT Pro v3.1 is now a robust, free-tier, school-ready CBT system. The most important improvement is the corrected security posture: data access decisions are now handled in Supabase SQL/RLS/RPC instead of relying on frontend logic.

The platform is appropriate for:

- school quizzes;
- continuous assessment;
- terminal exams with supervision;
- WAEC/NECO/BECE/JAMB practice;
- tutorial centre mocks;
- low-cost institutional CBT pilots.

For high-stakes national/professional certification exams, pair it with human invigilation and additional operational controls.
