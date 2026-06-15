# Changelog — CBT Site Generator

## v1.0.0 — 2026-06-14

Initial enterprise generator release.

### Added

- Client details form.
- Logo upload and initials-logo fallback.
- Colour, font, theme, radius, and layout selectors.
- Feature selection groups.
- Supabase URL, anon key, and admin email fields.
- Browser-only ZIP creation with internal ZIP writer.
- Template manifest loader.
- HMG Academy CBT Pro v3.1 Enterprise template bundle.
- Client config JSON export/import.
- Generated files:
  - `client-config.js`
  - `client-config.json`
  - `client-theme.css`
  - `client-branding.js`
  - `brand/brand-kit.json`
  - client logo/icon
  - `CLIENT_DEPLOYMENT.md`
  - `CLIENT_FEATURES.md`
  - `CLIENT_HANDOVER.md`
  - `SUPABASE_SETUP_NOTES.md`
- Generator PWA shell.
- Documentation and deployment guides.

### Security

- No server upload required.
- No paid AI API.
- No external ZIP library required.
- Warns against service_role keys.
