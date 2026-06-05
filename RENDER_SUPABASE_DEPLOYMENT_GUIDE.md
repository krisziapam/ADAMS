# ADAMS Deployment Guide: Render + Supabase

This package is prepared for deployment as a Docker-based Render Web Service connected to a Supabase PostgreSQL database.

## 1. Supabase database setup

1. Open your Supabase project.
2. Go to **SQL Editor**.
3. Open `ADAMS_PostgreSQL_SpringBoot_Setup.sql` from this project.
4. Paste the full script into Supabase SQL Editor and run it.

Important: the script contains `DROP TABLE IF EXISTS ... CASCADE`, so it resets the ADAMS demo tables. Use it only on a fresh Supabase project or database/schema.

## 2. Get the Supabase connection values

In Supabase, click **Connect** and use the **Session Pooler** connection string, not the Transaction Pooler.

Example Supabase connection string:

```text
postgresql://postgres.xxxxxxxxxxxxx:[YOUR-PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres
```

Convert it for Render environment variables:

```text
ADAMS_DB_URL=jdbc:postgresql://aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?sslmode=require
ADAMS_DB_USER=postgres.xxxxxxxxxxxxx
ADAMS_DB_PASSWORD=your-supabase-database-password
```

## 3. Push this project to GitHub

From the project root:

```bash
git init
git add .
git commit -m "Prepare ADAMS for Render and Supabase"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

## 4. Deploy on Render

Recommended method: Render Dashboard.

1. Go to Render Dashboard.
2. Click **New +** > **Web Service**.
3. Connect your GitHub repository.
4. Select **Docker** as runtime/environment. Render will detect the included `Dockerfile`.
5. Add environment variables:

```text
ADAMS_DB_URL=jdbc:postgresql://YOUR-SUPABASE-POOLER-HOST:5432/postgres?sslmode=require
ADAMS_DB_USER=postgres.YOUR_PROJECT_REF
ADAMS_DB_PASSWORD=YOUR_SUPABASE_DB_PASSWORD
```

6. Deploy.

Alternative method: If Render detects `render.yaml`, it may prompt you for the three secret values because they are marked with `sync: false`.

## 5. Open the app

After successful deployment, open:

```text
https://YOUR-RENDER-SERVICE.onrender.com/doc_ad_sys/login.jsp
```

Default demo logins:

```text
Username: admin
Password: admin123
```

```text
Username: staff
Password: staff123
```

## 6. Important production note about uploads

The app has upload-related pages/servlets. Render Free services use an ephemeral filesystem, so uploaded files stored locally can disappear after redeploys, restarts, or spin-downs. For production, either use a paid Render persistent disk or migrate file uploads to Supabase Storage/S3-compatible storage.
