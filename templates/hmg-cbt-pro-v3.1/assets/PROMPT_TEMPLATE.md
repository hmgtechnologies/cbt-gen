# Prompt Template — HMG Academy CBT Pro Maintenance & Enhancement

Use this template when asking an AI assistant/developer to review or improve the CBT platform.

---

## Context

You are working on **HMG Academy CBT Pro**, a free browser-based CBT platform by **HMG Concepts / HMG Academy**, founded by **Adewale Samson Adeagbo**.

Brand details:

- Founder: Adewale Samson Adeagbo
- WhatsApp: +234 810 086 6322
- Phone: +234 907 790 7677
- Email: hismarvellousgrace@gmail.com
- Tech/Partnerships: buildingmyictcareer@gmail.com
- HMG Academy: https://hmgacademy.pages.dev/
- HMG Concepts: https://hmgconcepts.pages.dev/
- Motto: Learning Deliberately. Teaching Authentically.

The system uses:

- static HTML/CSS/JavaScript;
- Supabase free tier;
- no paid AI API;
- no build process;
- no exposed service-role key.

---

## Files to inspect

Inspect all project files, especially:

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
COMPLETE_SQL_SETUP.sql
README.md
DEPLOYMENT.md
FEATURES.md
SECURITY.md
CHANGELOG.md
further_maths_sample.csv
```

---

## Required behaviour

When improving the platform:

1. Preserve existing features.
2. Do not introduce paid APIs.
3. Do not add AI API calls.
4. Do not expose Supabase `service_role` key.
5. Keep the app deployable as static files.
6. Ensure Supabase SQL is idempotent and correctly ordered.
7. Ensure RLS policies do not expose other teachers’ data.
8. Use RPCs for anonymous student flows instead of broad table reads.
9. Keep HMG brand details embedded.
10. Update documentation after code changes.

---

## Security checklist for generated changes

Ask these questions before accepting a change:

- Does it require a secret in the frontend? If yes, reject or redesign.
- Does anonymous access read entire tables? If yes, reject or use RPC.
- Does an admin RPC verify admin status inside PostgreSQL? If no, fix.
- Does a policy reference a function before that function is created? If yes, reorder SQL.
- Does scoring use decimal values for partial credit? If no, fix.
- Does the feature work without paid AI API? If no, reject or provide free alternative.

---

## Example request

```text
Take the role of a senior CBT platform engineer and Supabase security auditor.
Review this HMG Academy CBT Pro repository.
Fix bugs, security issues, SQL ordering issues, documentation gaps, and deployment problems.
Preserve all existing features.
Use only free tools.
Do not add paid AI APIs.
Ensure teacher/student/admin workflows are correct.
Update README, DEPLOYMENT, FEATURES, SECURITY, CHANGELOG, DIAGNOSIS_REPORT, and EXPERT_ENHANCEMENT_REPORT.
Create a ready-to-upload folder and zip.
```

---

## Acceptance criteria

A completed enhancement should include:

- JavaScript syntax check passes.
- SQL setup is correctly ordered.
- RLS policies are secure.
- Teacher can create an exam.
- Student can load via code/link.
- Registered student can verify ID.
- Attempt limit works.
- Result saves.
- Teacher sees result.
- Admin sees platform data.
- Documentation is updated.
- Ready-to-upload folder and zip are produced.
