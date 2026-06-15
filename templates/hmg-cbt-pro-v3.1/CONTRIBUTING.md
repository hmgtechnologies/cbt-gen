# Contributing to HMG Academy CBT Pro

Thank you for helping improve HMG Academy CBT Pro — a free CBT platform for schools, tutorial centres, and African classrooms.

## 1. Project principles

All contributions must follow these principles:

1. Preserve existing features.
2. Keep deployment static/no-build unless clearly documented.
3. Use free or free-tier tools.
4. Do not add paid AI API dependency.
5. Do not expose service-role keys or secrets.
6. Keep HMG Academy/HMG Concepts brand details intact.
7. Update documentation when behaviour changes.
8. Keep SQL idempotent and safe to re-run.

## 2. Development setup

No build process is required.

1. Clone/download the repository.
2. Open files in a code editor.
3. Use a local static server if desired:

```bash
python3 -m http.server 8080
```

4. Open `http://localhost:8080/index.html`.

## 3. Supabase setup for testing

1. Create a free Supabase project.
2. Run `COMPLETE_SQL_SETUP.sql`.
3. Update `SB_URL` and `SB_KEY` in:
   - `teacher.html`
   - `student.html`
   - `admin.html`
   - `link_checker.html`
4. Update `ADMIN_EMAIL` in:
   - `teacher.html`
   - `admin.html`

Never use the `service_role` key in frontend files.

## 4. Code style

- Keep JavaScript plain and readable.
- Prefer small helper functions over repeated parsing logic.
- Escape user-visible HTML unless intentionally rendering trusted internal content.
- Keep CSS inline/embedded because static preview may not load external assets.
- Avoid unnecessary dependencies.

## 5. SQL style

- Use `public.` schema qualification.
- Create functions before policies that reference them.
- Use `DROP POLICY IF EXISTS` and `DROP FUNCTION IF EXISTS` for idempotency.
- Use `SECURITY DEFINER` carefully and set `search_path`.
- Admin RPCs must call `public.is_platform_admin()`.
- Anonymous student workflows should use safe RPCs, not broad table reads.
- Preserve existing data during upgrades.

## 6. Testing checklist

Before submitting a change, test:

- [ ] `node --check` passes for extracted scripts.
- [ ] `COMPLETE_SQL_SETUP.sql` can run on a new Supabase project.
- [ ] Teacher signup works.
- [ ] Admin approval works.
- [ ] Teacher can create exam.
- [ ] Student can load exam via code/link.
- [ ] Registered-student mode works.
- [ ] Attempt limit works.
- [ ] Result saves.
- [ ] Teacher sees result.
- [ ] Admin sees platform data.
- [ ] Export functions work.
- [ ] Deployment validator passes.
- [ ] Link checker works.

## 7. Documentation updates

Update relevant docs when you change behaviour:

- `README.md`
- `DEPLOYMENT.md`
- `FEATURES.md`
- `SECURITY.md`
- `CHANGELOG.md`
- `DIAGNOSIS_REPORT.md`
- `EXPERT_ENHANCEMENT_REPORT.md`

## 8. Brand details

Keep these details accurate:

- Founder: Adewale Samson Adeagbo
- Parent brand: HMG Concepts
- School brand: HMG Academy
- WhatsApp: +234 810 086 6322
- Phone: +234 907 790 7677
- Email: hismarvellousgrace@gmail.com
- Tech/partnerships: buildingmyictcareer@gmail.com
- Motto: Learning Deliberately. Teaching Authentically.

## 9. Pull request summary format

Use this structure:

```text
Summary:
- ...

Files changed:
- ...

Security impact:
- ...

Testing performed:
- ...

Documentation updated:
- ...
```
