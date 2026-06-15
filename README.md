# CBT Site Generator — HMG Academy CBT Pro Template Builder

A browser-based platform for generating client-branded CBT websites for schools, tutorial centres, universities, academies, and training organisations.

The generator lets you enter client details, upload logo, choose colours, fonts, layouts, feature visibility, Supabase settings, and package options. It then produces a ready-to-upload ZIP containing a customized CBT website based on the HMG Academy CBT Pro v3.1 Enterprise template.

> No paid AI API. No server-side generator. No client data is uploaded to a third-party generator server. ZIP creation happens in your browser.

---

## Brand owner

Built by HMG Concepts / HMG Academy.

- Founder: Adewale Samson Adeagbo
- WhatsApp: +234 810 086 6322
- Phone: +234 907 790 7677
- Email: hismarvellousgrace@gmail.com
- Tech/partnerships: buildingmyictcareer@gmail.com
- HMG Academy: https://hmgacademy.pages.dev/
- HMG Concepts: https://hmgconcepts.pages.dev/

---

## What this generator creates

Each generated ZIP can include:

- `index.html` landing page
- `teacher.html` teacher dashboard
- `student.html` student exam portal
- `admin.html` enterprise admin panel
- Supabase SQL setup
- PWA manifest and service worker
- offline page
- link/code checker
- deployment validator
- feature guide
- sample CSV
- client logo/theme/config files
- client-specific deployment and handover docs

---

## Main generator features

| Feature | Explanation |
|---|---|
| Client intake form | Collect institution name, short name, owner/contact, email, phone, WhatsApp, website, address. |
| Logo upload | Upload PNG/JPG/WEBP/SVG logo. If omitted, an initials SVG logo is generated. |
| Colour builder | Choose primary, accent, secondary, background, surface, and text colours. |
| Font selector | Choose system/Inter, Plus Jakarta Sans, Poppins, Nunito, Montserrat, or Georgia. |
| Layout presets | Enterprise, modern cards, classic school, minimalist, neon tech, government/institutional. |
| Feature flags | Select visible/marketed features for the client package. Core enterprise files remain preserved. |
| Supabase injection | Optionally inject Project URL, anon key, and admin email. |
| Browser ZIP engine | Generates a ZIP locally without JSZip/CDN/server dependency. |
| Config export/import | Save and reload client generator profiles. |
| Client docs | Generates deployment, features, handover, brand kit, and Supabase notes. |

---

## How to use

### Option A — host the generator

1. Upload the `CBT gen` folder to GitHub Pages, Netlify, Vercel, Cloudflare Pages, or another static host.
2. Open `index.html`.
3. Fill the client form.
4. Click **Generate CBT Website ZIP**.
5. Send/deploy the generated ZIP for the client.

### Option B — run locally

Because browsers often block `fetch()` from `file://`, run a local static server:

```bash
cd "CBT gen"
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080/index.html
```

---

## Important security rule

Only paste the Supabase **anon public key** into the generator. Never paste a `service_role` key. The generated CBT platform relies on Supabase RLS/RPC for security.

---

## Folder structure

```text
CBT gen/
├── index.html
├── styles.css
├── generator.js
├── template-manifest.json
├── manifest.webmanifest
├── sw.js
├── offline.html
├── assets/
│   └── generator-logo.svg
├── templates/
│   └── hmg-cbt-pro-v3.1/
│       └── full CBT website template files
├── README.md
├── DEPLOYMENT.md
├── FEATURES.md
├── SECURITY.md
├── CHANGELOG.md
└── CLIENT_INTAKE_FORM.md
```

---

## Generated site deployment summary

For each generated client CBT website:

1. Extract generated ZIP.
2. Create Supabase project.
3. Confirm `SB_URL`, `SB_KEY`, and `ADMIN_EMAIL` in HTML files.
4. Run `COMPLETE_SQL_SETUP.sql`.
5. Upload files to static hosting.
6. Open `deployment_validator.html`.
7. Test teacher signup → admin approval → exam creation → student submission → teacher result view.

Full details are in `DEPLOYMENT.md`.
