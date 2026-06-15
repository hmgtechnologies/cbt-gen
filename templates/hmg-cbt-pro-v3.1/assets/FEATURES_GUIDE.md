# HMG Academy CBT Pro v3.1 — User Feature Guide

This guide explains how to use the main features.

## 1. Teacher workflow

### Create an exam

1. Open `teacher.html`.
2. Sign in.
3. Go to **Create**.
4. Enter subject, class, term, exam type, duration, pass mark, and attempt limit.
5. Choose exam mode:
   - **Open**: students type name/class.
   - **Registered**: students must verify uploaded Student ID.
6. Optional: set start time, close time, negative marking, instructions, and result release.
7. Upload questions or add manually.
8. Publish.
9. Copy link/code from **Assessments**.

### Upload students for registered mode

1. Go to **Students**.
2. Download the roster template.
3. Fill `FullName,StudentID,Class`.
4. Upload CSV.
5. Create exam with mode `registered`.

### Edit an exam

1. Go to **Assessments**.
2. Click edit/manage.
3. Change metadata, schedule, mode, release setting, or questions.
4. Save.

### Export data

- Results CSV: **Results → Export**.
- Analytics CSV: **Analytics → Export**.
- Exam package: **Assessments → Export Package**.
- Teacher backup: **Settings → Enterprise Operations**.

## 2. Student workflow

### Join an exam

Students can:

- click a direct link; or
- open `student.html` and type the access code.

### During exam

Students can:

- use question navigator;
- flag questions;
- use calculator;
- use read-aloud;
- use shortcuts `A-D`, `N`, `P`, arrows, `R`, `S`;
- submit before time ends.

### After exam

- If results are released: score, grade, review, explanations, and submission code are shown.
- If results are held: the student sees confirmation only; teacher releases results later outside the current static flow.
- If saving fails: student downloads backup JSON and sends it to teacher.

## 3. Admin workflow

### Approve teachers

1. Open `admin.html`.
2. Sign in as admin.
3. Go to **Pending Approvals**.
4. Approve or reject accounts.

### Monitor platform

- Overview shows counts and recent activity.
- Teachers page manages teacher status.
- All Exams page supervises exams.
- All Results page exports data.
- Security tab runs checks and downloads smoke tests.

## 4. Question import guide

### Basic MCQ row

```csv
Question,A,B,C,D,CorrectAnswer,Explanation
What is 2+2?,3,4,5,6,B,2+2 equals 4.
```

### Extended row with metadata

```csv
Question,A,B,C,D,CorrectAnswer,Explanation,Type,Tolerance,Unit,Accept,MRQ_AON,Pairs,Items,Difficulty,Tags,Section
What is 2+2?,3,4,5,6,B,2+2 equals 4.,mcq,,,,,,,Easy,Arithmetic|Numbers,Number Operations
```

### Matching

Put JSON in `Pairs`:

```json
[{"left":"Sodium","right":"Na"},{"left":"Potassium","right":"K"},{"left":"DISTRACTOR","right":"Au"}]
```

### Ordering

Put JSON array in `Items` in correct order:

```json
["Prophase","Metaphase","Anaphase","Telophase"]
```

### Cloze

Put accepted answers in `Items`:

```json
["mass|m","acceleration|a"]
```

### Essay

Use `Accept` or JSON rubric in `Items`:

```json
{"min_words":30,"keywords":["honesty","fairness","validity"]}
```

## 5. Deployment tools

- `deployment_validator.html`: confirms required files and config strings.
- `link_checker.html`: checks if an exam code/link is valid and ready.
- `feature_guide.html`: browser-readable feature guide.
- `COMPLETE_SQL_SETUP.sql`: canonical database setup.

## 6. Important limitations

- Browser proctoring flags are supportive evidence, not perfect proof.
- Essay scoring is rule-based and should be manually reviewed for high-stakes exams.
- Static hosting cannot securely hide all frontend logic; security-critical checks must stay in Supabase SQL/RLS/RPC.
- Exam links/codes should be treated like private access tokens.
