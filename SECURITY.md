# CBT Site Generator — Security Guide

## 1. Generator security model

The generator runs fully in the browser. It does not upload client details or logos to a generator server. It reads the included CBT template files, modifies them in memory, and downloads a ZIP.

## 2. Sensitive data warning

Do not paste the following into the generator:

- Supabase service_role key;
- database password;
- SMTP password;
- payment secret key;
- AI API key;
- private school credentials.

Only paste the Supabase anon public key.

## 3. Generated CBT site security model

Generated CBT sites rely on Supabase:

- Row Level Security;
- secure public student RPCs;
- admin RPC server-side checks;
- teacher-owned data policies;
- open/expired exam submission checks.

The frontend is public, so security must not depend on hiding JavaScript.

## 4. Logo/client data privacy

Uploaded logos are processed locally in the browser and inserted into the ZIP. If you deploy the generator on your own domain, no third-party generator backend receives the file.

## 5. Operational recommendations

- Deploy over HTTPS.
- Run `COMPLETE_SQL_SETUP.sql` fully.
- Confirm no `service_role` key appears in generated files.
- Treat exam codes as private access tokens.
- Use registered-student mode for high-stakes exams.
- Rotate codes if leaked.
- Export backups carefully.
- Protect result CSVs and proctoring data.

## 6. Proctoring limitation

Generated CBT sites include browser-based integrity flags. These support teachers but are not equivalent to paid lockdown browsers or live human proctoring.

## 7. Incident response

If a generated site exposes a secret:

1. Remove the site immediately.
2. Rotate the exposed secret in Supabase or the relevant provider.
3. Regenerate the site using only the anon key.
4. Re-run deployment validator and security checks.
