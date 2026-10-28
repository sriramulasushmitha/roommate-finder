# Roomie — Roommate Finder

A beginner-friendly full-stack roommate finder for college students. Students can browse available rooms, filter by location/rent/room type, publish listings, and contact a listing owner through their email app. Listings are persisted in Supabase PostgreSQL through a Node.js/Express REST API.

## Features

- Responsive landing page designed with HTML, CSS, and vanilla JavaScript.
- Real listing data fetched from the Express API (no mock listing dataset).
- Search/filter by city or campus, maximum monthly rent, and room type.
- Create, read, update, and delete listing API operations.
- Form validation in the browser and backend, loading state, empty state, and errors.
- Contact owner uses a `mailto:` link; it opens the visitor's configured mail application.
- Supabase PostgreSQL schema with constraints, indexes, timestamp trigger, and Row Level Security (RLS).
- Health endpoint and beginner troubleshooting guidance.

## Technology stack

- Frontend: HTML5, CSS3, vanilla JavaScript, Fetch API
- Backend: Node.js, Express 4
- Database: Supabase PostgreSQL
- Packages: `express`, `cors`, `dotenv`, `@supabase/supabase-js`, `ws`; `nodemon` for development
- Version control: Git and GitHub

## Project structure

```text
roommate-finder/
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── backend/
│   ├── server.js
│   ├── supabase.js
│   ├── package.json
│   └── .env.example
├── database/
│   └── schema.sql
├── .gitignore
└── README.md
```

## Prerequisites

- Node.js 18 or newer (Node 20 LTS recommended) and npm
- A free Supabase account/project
- A browser
- Optional: Git, GitHub account, and VS Code
- Optional: a simple static server such as VS Code Live Server

## 1. Create and configure Supabase

1. Sign in at [Supabase](https://supabase.com/) and create a project. Wait until its database is ready.
2. Open **SQL Editor** in your Supabase dashboard.
3. Open `database/schema.sql` from this project, copy its full contents, paste into the SQL Editor, and run it.
4. In **Project Settings → API** (the exact labels may vary), copy the project URL and the publishable/anon key. Do not use a `service_role` or secret key in the browser or commit one to Git.
5. The schema creates `public.listings`, constraints, indexes, an `updated_at` trigger, and RLS policies. The policies deliberately permit anonymous CRUD for this classroom demo. See the security warning below.

## 2. Configure backend environment

From the project root, copy the example file to `.env`:

**Windows PowerShell**
```powershell
Copy-Item backend/.env.example backend/.env
```

**macOS / Linux**
```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env` and replace placeholders:

```dotenv
PORT=3000
FRONTEND_ORIGIN=http://127.0.0.1:5500
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY
```

Use your own Supabase URL and anon/publishable key. Never paste a real key into frontend JavaScript or GitHub. `.env` is excluded by `.gitignore`.

The server accepts a comma-separated list of frontend origins in `FRONTEND_ORIGIN`. If your static server uses a different port/origin, update this variable and restart the backend.

## 3. Install dependencies

Open a terminal and **run these commands inside the `backend` directory**:

```bash
cd backend
npm install
```

The `package.json` already declares all runtime and development dependencies, so the first command is enough. These extra commands are optional and are included for clarity only:

```bash
npm install express cors dotenv @supabase/supabase-js ws
npm install --save-dev nodemon
```

Run the backend in development mode:

```bash
npm run dev
```

Or start normally:

```bash
npm start
```

The server should print `Roomie API listening on http://localhost:3000`. Check the health endpoint in a browser: `http://localhost:3000/api/health`. A healthy response has `"status":"ok"` and `"databaseConfigured":true`. This health check confirms environment configuration only; it does not guarantee a database query succeeded.

## 4. Start the frontend

In a second terminal, from the project root, start a static server. With VS Code Live Server, right-click `frontend/index.html` and choose **Open with Live Server**. It often serves at `http://127.0.0.1:5500`.

Alternatively, if Python is installed, run from the project root:

```bash
python -m http.server 5500 --directory frontend
```

Then visit `http://127.0.0.1:5500`. Keep the API at `http://localhost:3000`. If you serve the frontend on another origin, add that exact origin to `FRONTEND_ORIGIN` in `backend/.env`, then restart the backend.

The frontend defaults to `http://localhost:3000/api`. If you deploy the backend elsewhere, set `window.ROOMIE_API_BASE` before `script.js` loads, or update the `API_BASE` constant in `frontend/script.js`.

## 5. API reference

All request and response bodies are JSON. Listing IDs are UUIDs. List responses are capped at 100 newest listings.

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/health` | Server and environment health |
| GET | `/api/listings` | List all listings; supports `location`, `maxRent`, `roomType` query filters |
| GET | `/api/listings/:id` | Get one listing |
| POST | `/api/listings` | Create listing |
| PUT | `/api/listings/:id` | Replace editable listing fields |
| DELETE | `/api/listings/:id` | Delete listing |

Allowed `roomType` values are `Private`, `Shared`, and `Studio`. The JSON body for POST/PUT:

```json
{
  "title": "Sunny room near campus",
  "location": "Hyderabad",
  "rent": 8000,
  "room_type": "Private",
  "description": "Bright furnished room with Wi-Fi, desk, and shared kitchen access.",
  "contact_name": "Asha",
  "contact_email": "asha@example.com"
}
```

A successful create returns HTTP `201` with `{ "data": { ...listing } }`. Reads and updates return HTTP `200` with the same `data` wrapper. Delete returns `{ "data": { "id": "...", "deleted": true } }`. Validation errors return HTTP `400`; missing IDs return `404`; unconfigured database returns `503`; database failures return a generic `500` message and details in the backend terminal.

### Test endpoints with curl

Health:
```bash
curl http://localhost:3000/api/health
```

List:
```bash
curl "http://localhost:3000/api/listings?location=Hyderabad&maxRent=12000&roomType=Private"
```

Create (use your own values):
```bash
curl -X POST http://localhost:3000/api/listings \
  -H "Content-Type: application/json" \
  -d '{"title":"Sunny room near campus","location":"Hyderabad","rent":8000,"room_type":"Private","description":"Bright furnished room with Wi-Fi, desk, and shared kitchen access.","contact_name":"Asha","contact_email":"asha@example.com"}'
```

Use the returned `data.id` for `GET /api/listings/ID`, `PUT /api/listings/ID`, and `DELETE /api/listings/ID`. Do not use a real person's contact information for testing. Remember that this demo schema permits public write/delete access.

## 6. Git and GitHub submission

From the project root:

```bash
git init
git add .
git status
git commit -m "Build Roomie roommate finder full-stack app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/roommate-finder.git
git push -u origin main
```

Replace the remote URL with your own repository. Confirm `backend/.env` is not staged before committing. If it was staged accidentally, remove it from the Git index and rotate any exposed key.

## 7. Troubleshooting

- **`Missing SUPABASE_URL or SUPABASE_ANON_KEY`**: Copy `.env.example` to `.env`, fill both values, and restart the server.
- **Listings show a database error**: Run `database/schema.sql` in the correct Supabase project. Check table name `public.listings`, API URL/key, RLS policies, and the backend terminal.
- **`Failed to fetch` / cannot reach backend**: Start `npm run dev`; confirm port 3000 is free and the API health URL responds.
- **CORS origin blocked**: Set `FRONTEND_ORIGIN` to the exact origin including scheme and port (for example `http://127.0.0.1:5500`). Restart backend after changing `.env`.
- **`Invalid API key` / 401**: Copy the correct anon/publishable key from the same Supabase project as the URL. Do not use a database password as an API key.
- **Table or column does not exist**: Re-run the schema in the intended project and inspect the `listings` table in Table Editor.
- **`npm` not recognized**: Install Node.js LTS and reopen the terminal.
- **Port already in use**: Change `PORT` in `.env` and update `API_BASE` in `frontend/script.js`.
- **Mail app does not open**: The contact button uses `mailto:`; configure a default mail app or copy the displayed owner email from the database.
- **PowerShell curl behavior differs**: Use `curl.exe` or run the commands in Git Bash/WSL.

## 8. Security limitations and remaining setup

This is a learning/demo project, not a production housing marketplace.

- RLS is enabled, but the supplied demo policies deliberately allow `anon` users to read, insert, update, and delete all listings so the no-login CRUD demonstration can work. This is **not a secure owner authorization model**; a malicious visitor could modify or delete other users' listings. Before production, add Supabase Auth, an `owner_id` linked to `auth.uid()`, owner-scoped RLS policies, rate limiting, abuse reporting, spam prevention, email verification, and moderation.
- Contact email is displayed to the frontend API and can be scraped. Consider private contact flows and consent before real deployment.
- The API uses the anon/publishable key from the backend and does not use a service-role key. Do not change this by exposing a privileged key in client code.
- The browser's `_createdHere` marker only changes which edit/delete buttons are visible. It is not security or authentication. API CRUD remains public under the demo RLS policies.
- This project has no login, chat system, booking/payment flow, email sending service, or verified identity checks. The contact button opens the user's local email application.
- Real Supabase integration cannot be fully verified until you supply your own credentials and execute the SQL schema in your project.

## 9. Short demo script

1. Start Supabase, the backend, and the frontend.
2. Show the landing page and responsive navigation.
3. Search by a city, a maximum rent, and a room type; clear filters.
4. Publish a test listing with valid details and show it appears from the database.
5. Refresh the page to show the listing persists.
6. Click **Contact owner** to demonstrate the email hand-off.
7. Use the listing's edit/delete controls if it was created in the current browser session; confirm changes are persisted.
8. Open `/api/health` and `/api/listings` to show the REST API.

## 10. Beginner-friendly viva questions

**Q1. What is the role of Express.js?**  
Express.js handles HTTP requests, defines REST API routes, validates inputs, and returns JSON responses to the frontend.

**Q2. Why use Supabase?**  
Supabase provides a managed PostgreSQL database and an API platform, so the project can store and retrieve listing data without managing a database server manually.

**Q3. What does CRUD mean?**  
CRUD stands for Create, Read, Update, and Delete — the four basic operations supported by this listing application.

**Q4. What is Row Level Security (RLS)?**  
RLS is a PostgreSQL feature that applies policies to determine which rows a database role can read or change. RLS is enabled here, but the classroom policies are intentionally public and should be replaced for production.

**Q5. Why does the frontend use Fetch API?**  
Fetch API lets browser JavaScript send HTTP requests to the backend and process JSON responses asynchronously without reloading the page.

## License

For educational use. Add an appropriate license before public redistribution.
