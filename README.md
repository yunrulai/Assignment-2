# SecureShop — Setup & Guidelines

Essential notes to get the project running and secure it.

Prerequisites
- Install Node.js (16+ recommended)
- SQL Server accessible from this machine (local or networked)

Quick setup
1. Copy `.env.example` to `.env` and fill values.
2. From `server/`:
   - Install: `cd server && npm install`
   - Seed sample data (creates admin): `npm run seed`
   - Start server (dev): `npm run dev`
3. From `client/`:
   - Install: `cd client && npm install`
   - Start dev server: `npm start`

Database
- Apply schema: run `sql/schema.sql` against your SQL Server instance.
- Seed test data: run `sql/seed.sql` (or use `server` seed script).

Important environment variables
- `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME` — database connection
- `DB_INSTANCE` — optional SQL Server instance name
- `JWT_SECRET` — set a strong random secret for tokens

Security & operational notes
- Change the default seeded admin password immediately after first login.
- Never commit `.env` or secrets to source control.
- Use strong `JWT_SECRET` and HTTPS in production.
- Limit CORS origins to the deployed frontend origin.

Default seeded admin
- Email: `admin@example.com`
- Password: `Admin123!` (change on first run)

Where to look
- Server entry: `server/index.js`
- Database files: `sql/schema.sql`, `sql/seed.sql`

If you want this reduced further, or want a short quick-reference checklist file, tell me which items to keep.
