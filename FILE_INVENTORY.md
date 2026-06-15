# File Inventory — CBT Site Generator

| File/Folder | Purpose |
|---|---|
| `index.html` | Main generator interface. |
| `styles.css` | Generator UI styling. |
| `generator.js` | Browser-only generator logic and ZIP writer. |
| `template-manifest.json` | List of CBT template files read by the generator. |
| `manifest.webmanifest` | PWA metadata for installing the generator. |
| `sw.js` | Service worker for generator app shell. |
| `offline.html` | Offline fallback page for the generator. |
| `generator_validator.html` | Checks template reachability and v3.1 security indicators. |
| `assets/generator-logo.svg` | Generator logo/favicon. |
| `templates/hmg-cbt-pro-v3.1/` | Full CBT website template used for generated client packages. |
| `README.md` | Main generator overview. |
| `DEPLOYMENT.md` | Generator and generated-site deployment guide. |
| `FEATURES.md` | Feature explanation. |
| `SECURITY.md` | Security notes for generator and generated sites. |
| `CHANGELOG.md` | Version history. |
| `CLIENT_INTAKE_FORM.md` | Client information collection template. |
| `FILE_INVENTORY.md` | This file inventory. |

## Generated client package files

The generator can create files such as:

- `client-config.js`
- `client-config.json`
- `client-theme.css`
- `client-branding.js`
- `brand/brand-kit.json`
- `CLIENT_DEPLOYMENT.md`
- `CLIENT_FEATURES.md`
- `CLIENT_HANDOVER.md`
- `SUPABASE_SETUP_NOTES.md`
- `assets/client-logo.*`
- `assets/client-icon.svg`

These are added to the generated CBT website ZIP.
