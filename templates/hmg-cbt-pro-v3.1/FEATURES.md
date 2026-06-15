# HMG Academy CBT Pro v3.1 — Detailed Features

This document explains the features in the CBT platform and how each feature helps schools, teachers, students, and administrators.

---

## 1. Access and roles

### Landing page

`index.html` introduces the platform, highlights HMG Academy/HMG Concepts branding, and links to the three portals.

### Teacher role

Teachers create exams, manage students, publish links/codes, and analyse results. Teacher data is isolated by RLS so each teacher sees their own exams, students, and results unless they are also an admin.

### Student role

Students do not need accounts. They access an exam by direct link or code. This is ideal for classrooms, WhatsApp groups, CBT labs, and low-friction assessment.

### Admin role

Admins approve teachers, supervise platform data, export reports, and run security checks.

---

## 2. Exam creation features

| Feature | Explanation |
|---|---|
| Subject/class/term/topic/session metadata | Encodes school reporting context for filters and result exports. |
| Duration | Countdown timer for exam pressure and fairness. |
| Attempt limit | Uses secure v3.1 RPC to count previous attempts. |
| Question count selection | Teachers can upload a large bank and deliver a random subset. |
| Open mode | Any student with the link/code can sit the exam. |
| Registered mode | Student ID must match the teacher’s uploaded roster. |
| Start time | Students see a wait room until exam opens. |
| Close time | Exam automatically stops accepting submissions after expiry. |
| Negative marking | Deducts configured marks per wrong answer and stores adjusted score. |
| Result release control | Teacher can show instant result or hold result until later. |
| Instructions | Teacher-provided exam rules shown before entry. |

---

## 3. Question authoring and import

### CSV import

The system supports the extended CSV format:

```text
Question,A,B,C,D,CorrectAnswer,Explanation,Type,Tolerance,Unit,Accept,MRQ_AON,Pairs,Items,Difficulty,Tags,Section
```

### XLSX import

Teachers can upload spreadsheet files; the browser extracts rows and converts them into question objects.

### PDF/text import

For legacy question papers, teachers can paste/import structured text and the system detects common MCQ patterns.

### Manual entry

Teachers can build questions in the dashboard without external files.

### Metadata columns

- `Difficulty`: Easy, Medium, Hard, or school-defined label.
- `Tags`: pipe-separated topic/skill tags, e.g. `Algebra|Quadratic Equations`.
- `Section`: exam section, topic strand, or learning outcome.

These fields support better analytics, remediation, and item-bank management.

---

## 4. Question types

| Type | Auto scoring | Partial credit | Description |
|---|---:|---:|---|
| MCQ | Yes | No | One correct option A-D. |
| MRQ | Yes | Yes | Multiple correct options with partial or all-or-nothing mode. |
| True/False | Yes | No | A=True, B=False. |
| Short answer | Yes | No | Exact answer plus accepted alternatives. |
| Numeric | Yes | No | Numeric answer with tolerance and optional unit. |
| Matching | Yes | Yes | Pair left and right items. |
| Ordering | Yes | Yes | Arrange items in the correct sequence. |
| Cloze | Yes | Yes | Several fill-in-the-gap blanks. |
| Essay | Rule-based | Yes | Keyword/minimum-word score; teacher review recommended. |
| Categorization | Yes | Yes | Place items into categories. |
| Multi-numeric | Yes | Yes | Solve several numeric parts in one question. |

---

## 5. Student exam-taking features

### Link + code access

Teachers can share a URL or a 4–12 character code. The student portal extracts codes from:

- `?code=ABC123`
- `?exam=ABC123`
- `?c=ABC123`
- raw pasted code

### Wait room

If an exam has a future start time, students see a countdown. In v3.1, public RPC hides question data until the start time.

### Draft auto-save

Answers are saved locally during the exam. If the browser refreshes accidentally, the system can restore the draft.

### Navigator

Students see answered, unanswered, and flagged questions in a grid.

### Flag for review

Students can flag uncertain questions and revisit them before submission.

### Keyboard shortcuts

- `A-D`: select/toggle options
- `N` or right arrow: next question
- `P` or left arrow: previous question
- `R`: flag question
- `S`: open submit dialog

This mimics common CBT/JAMB-style speed practice workflows.

### Scientific calculator

Built-in calculator supports arithmetic, trigonometry, powers, constants, memory, and history.

### Read aloud

Browser speech synthesis reads the question and options when available.

---

## 6. Integrity and proctoring features

All integrity features use browser-side/free tools. They are not a replacement for human invigilation in high-stakes exams, but they provide useful logs.

| Feature | Description |
|---|---|
| Tab/app switch detection | Flags when document becomes hidden. |
| Window blur detection | Flags repeated focus loss. |
| Fullscreen monitoring | Prompts/flags when fullscreen is exited. |
| Copy/cut/paste/right-click blocking | Reduces easy copying. |
| Print/view-source/devtools shortcut blocking | Flags suspicious shortcuts. |
| DevTools window-size trap | Detects likely open devtools. |
| Periodic camera snapshots | Stores snapshots in `proctor_data` if permission is granted. |
| Multiple/no-face signal | Uses optional free face detection models where available. |
| Audio spike warning | Uses Web Audio API to flag loud/possible dictation audio. |
| Dynamic watermark | Shows student identity overlay during exam. |

---

## 7. Scoring and results

### Decimal scores

v3.1 stores scores as `NUMERIC(10,2)`, so partial-credit results match what students see.

### Negative marking

If a teacher sets a negative mark, the platform deducts:

```text
wrong_count × negative_mark
```

The score is clamped at zero.

### Held results

If `release_results=false`, the student sees a “Submission Received” screen without score or answer review. The teacher still receives the full result.

### Certificate/submission code

Each submission receives a verification code stored in `results.cert_code` and displayed to the student.

### Emergency backup

If saving fails, the student can download a JSON backup and send it to the teacher. Teachers can import backup JSON from the dashboard.

---

## 8. Teacher analytics

| Analytics | Purpose |
|---|---|
| Score distribution | See class performance spread. |
| Pass/fail ratio | Quickly judge performance against pass mark. |
| Per-question item analysis | Identify easy/hard questions and misconceptions. |
| Time analytics | Detect questions taking too long. |
| Leaderboard | Rank performance and percentiles. |
| Weakness identification | Find struggling students/topics. |
| Rule-based insights | No paid AI API; transparent recommendations. |
| CSV export | Use in Excel, Google Sheets, or school records. |

---

## 9. Admin features

- Teacher account approval.
- Pending/active/inactive status control.
- Admin promotion.
- Platform-wide exam and result views.
- CSV exports.
- Security checks.
- RLS smoke-test SQL download.
- Deployment checklist downloads.
- Platform health indicators.

Admin RPCs are protected server-side by `public.is_platform_admin()`.

---

## 10. PWA/offline shell

- `manifest.webmanifest` makes the platform installable.
- `sw.js` caches the app shell.
- `offline.html` provides a fallback page.
- Exam data still requires Supabase connectivity at loading/submission time, but drafts and emergency backup reduce data-loss risk.

---

## 11. Free-tool architecture

| Layer | Tool |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Hosting | Any static host |
| Database/auth | Supabase free tier |
| Charts | Chart.js CDN |
| PWA | Service Worker |
| Proctoring helpers | Browser APIs, optional free CDN model |
| AI | None; rule-based logic only |

---

## 12. Brand integration

The HMG Academy / HMG Concepts identity is embedded in:

- page titles
- landing page
- teacher login/dashboard
- student portal
- admin portal
- manifest
- documentation
- exported reports/checklists
- certificates/submission backups

Brand details:

- Founder: Adewale Samson Adeagbo
- WhatsApp: +234 810 086 6322
- Phone: +234 907 790 7677
- Email: hismarvellousgrace@gmail.com
- Tech/partnerships: buildingmyictcareer@gmail.com
