# CBT Site Generator — Deployment Guide

This guide explains how to deploy the generator itself and how to deploy CBT websites produced by it.

---

## Part A — Deploy the generator platform

### A1. Requirements

- Static hosting: GitHub Pages, Netlify, Vercel, Cloudflare Pages, or similar.
- No build step.
- No backend server.
- No AI API.

### A2. Upload files

Upload the entire `CBT gen` folder contents to a repository or static host:

```text
index.html
styles.css
generator.js
template-manifest.json
manifest.webmanifest
sw.js
offline.html
assets/
templates/
README.md
DEPLOYMENT.md
FEATURES.md
SECURITY.md
CHANGELOG.md
CLIENT_INTAKE_FORM.md
```

The `templates/hmg-cbt-pro-v3.1/` folder must be uploaded because the generator reads template files from there.

### A3. GitHub Pages deployment

1. Create a GitHub repo, e.g. `cbt-site-generator`.
2. Upload all files from inside `CBT gen`.
3. Go to **Settings → Pages**.
4. Source: `Deploy from a branch`.
5. Branch: `main`, folder `/root`.
6. Save.
7. Open the GitHub Pages URL.

### A4. Netlify deployment

1. Go to Netlify.
2. Add new site.
3. Drag/drop the `CBT gen` folder or connect GitHub.
4. Build command: blank.
5. Publish directory: root.
6. Deploy.

### A5. Local use

If you want to use the generator offline/locally, do not open `index.html` directly by double-clicking. Run a local server:

```bash
cd "CBT gen"
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080/index.html
```

---

## Part B — Generate a client CBT website

1. Open the generator.
2. Enter client name, short name, contact details, and admin email.
3. Upload logo.
4. Choose colours, layout, font, and feature flags.
5. Optionally paste Supabase Project URL and anon key.
6. Click **Generate CBT Website ZIP**.
7. Save the ZIP.
8. Extract the ZIP.

---

## Part C — Deploy a generated CBT website

### C1. Create Supabase project

1. Go to https://supabase.com.
2. Create new project.
3. Copy:
   - Project URL;
   - anon public key.

### C2. Confirm frontend config

In the generated website, check:

```text
teacher.html
student.html
admin.html
link_checker.html
```

Confirm:

```js
const SB_URL = 'https://YOUR_PROJECT_ID.supabase.co';
const SB_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Also check:

```js
const ADMIN_EMAIL = 'client-admin@example.com';
```

### C3. Run SQL

1. Open `COMPLETE_SQL_SETUP.sql`.
2. Copy all content.
3. Open Supabase SQL Editor.
4. Paste and run.
5. Confirm the verification queries show RLS enabled and RPCs created.

### C4. Upload generated website

Upload the extracted generated website files to:

- GitHub Pages;
- Netlify;
- Vercel;
- Cloudflare Pages;
- cPanel static folder;
- any static web server.

No build command is required.

### C5. Test

1. Open `deployment_validator.html`.
2. Create a teacher account.
3. Login as admin.
4. Approve teacher.
5. Create sample exam.
6. Open student link/code.
7. Submit result.
8. Confirm teacher sees result.
9. Confirm admin sees platform data.

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| Generator cannot read template files | Opened with `file://` | Use local server or deploy to static host. |
| ZIP downloads but generated site cannot save results | Supabase SQL not run | Run `COMPLETE_SQL_SETUP.sql`. |
| Student code not found | Exam closed/expired or wrong code | Re-open exam or verify code. |
| Registered ID fails | Roster missing or RPC missing | Upload roster and re-run SQL. |
| Admin sees no data | Admin profile inactive or RPC missing | Activate admin profile and re-run SQL. |
| Logo not showing | Unsupported file or cache | Use PNG/SVG and hard refresh. |

---

## Security reminder

Never paste or deploy a Supabase `service_role` key in generated static files. Only use the anon public key.
