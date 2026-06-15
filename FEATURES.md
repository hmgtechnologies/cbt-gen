# CBT Site Generator — Detailed Features

This document explains the generator platform and the generated CBT website features.

---

## 1. Generator platform features

### 1.1 Client details collection

The generator captures:

- institution/client name;
- short name;
- CBT website title;
- tagline;
- institution type;
- owner/contact person;
- email, phone, WhatsApp, website;
- address;
- admin email.

These details are embedded into the generated CBT package.

### 1.2 Logo and brand assets

- Upload a client logo as PNG, JPG, WEBP, or SVG.
- If no logo is uploaded, the generator creates an initials-based SVG logo.
- Generated package includes:
  - `assets/client-logo.*`
  - `assets/client-icon.svg`
  - `brand/brand-kit.json`

### 1.3 Colour and theme builder

The generator produces `client-theme.css` with:

- primary colour;
- accent colour;
- secondary colour;
- background colour;
- surface/card colour;
- text colour;
- border radius;
- font family;
- layout preset.

### 1.4 Layout presets

| Preset | Use case |
|---|---|
| Enterprise | Professional school/company deployments. |
| Modern Cards | Clean EdTech look. |
| Classic School | Conservative school style. |
| Minimal | Low-distraction CBT deployment. |
| Neon Tech | Youth/tutorial/tech academy style. |
| Government/Institutional | Formal public-sector style. |

### 1.5 Feature selection

The generator lets you select visible/configured features, including:

- teacher dashboard;
- student portal;
- admin panel;
- registered-student mode;
- scheduling;
- negative marking;
- held results;
- proctoring flags;
- item analysis;
- certificates;
- PWA/offline shell;
- deployment validator;
- link checker;
- documentation.

Core enterprise files are preserved so features can be re-enabled later.

### 1.6 Supabase configuration

The generator can inject:

- Supabase Project URL;
- Supabase anon public key;
- admin email.

It refuses obvious `service_role` key usage.

### 1.7 Browser-only ZIP generation

The generator includes a small internal ZIP writer using the ZIP STORE method. It does not require:

- JSZip;
- npm;
- backend server;
- paid API;
- AI API.

### 1.8 Config import/export

You can download a client profile JSON and reload it later for updates or repeat deployments.

---

## 2. Generated CBT website features

The generated CBT website is based on HMG Academy CBT Pro v3.1 Enterprise and includes:

### Teacher features

- teacher signup/login;
- admin approval workflow;
- exam creation;
- CSV/XLSX/PDF/manual question import;
- full exam editing;
- question append;
- question bank editor;
- registered-student roster upload;
- exam scheduling;
- negative marking;
- result hold/release control;
- result analytics;
- item analysis;
- CSV exports;
- exam package export/import;
- emergency backup import.

### Student features

- exam code/link access;
- open mode and registered-student mode;
- integrity pledge;
- countdown timer;
- navigator;
- question flagging;
- auto-save draft;
- scientific calculator;
- text-to-speech;
- keyboard shortcuts;
- proctoring/integrity flags;
- instant/held result display;
- certificate/submission code;
- emergency result backup JSON.

### Admin features

- teacher approval;
- teacher deactivation/reactivation;
- admin promotion;
- platform-wide analytics;
- view all exams/results;
- CSV export;
- security checks;
- RLS smoke-test download;
- deployment checklist.

### Database/security features

- Supabase RLS;
- server-side admin guard RPC;
- safe public exam-loading RPC;
- safe registered-student verification RPC;
- safe attempt-count RPC;
- decimal partial-credit scores;
- scheduled exam access control;
- no service-role key in frontend.

---

## 3. No AI API policy

The generator and generated CBT sites do not use paid AI APIs. Rule-based logic is used for:

- essay keyword scoring;
- analytics recommendations;
- item analysis;
- performance summaries.

This keeps operating costs suitable for schools and tutorial centres.
