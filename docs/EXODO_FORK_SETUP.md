# EXODO Fork Setup

This document describes the EXODO workflow for operating a maintained fork of Open WebUI.

## 1) Repository Strategy

- Fork: `osamuelnovaes/open-webui`
- Upstream remote: `open-webui/open-webui`
- Custom branch: `exodo-brand`
- Keep branding and integration changes isolated in `exodo-brand`.

## 2) Local Run (Docker)

From repository root:

1. Copy and edit env values:
   - `cp .env.example .env`
2. Set at least:
   - `WEBUI_SECRET_KEY`
   - `OPENAI_API_BASE_URL`
   - `OPENAI_API_KEY`
3. Run with EXODO override:
   - `docker compose -f docker-compose.yaml -f docker-compose.exodo.yaml up -d --build`
4. Open:
   - `http://localhost:3000`

## 3) EXODO SSO Integration (Trusted Headers)

Open WebUI supports trusted header auth. In EXODO reverse proxy/middleware, inject:

- `x-exodo-user-email`
- `x-exodo-user-name`
- `x-exodo-org-id`
- `x-exodo-user-role`

Recommended role mapping:

- EXODO `OWNER`, `ADMIN` -> Open WebUI `admin`
- EXODO `MANAGER`, `MEMBER` -> Open WebUI `user`

Notes:

- Keep `ENABLE_SIGNUP=False` in production.
- Only trust these headers from your private proxy layer.
- Do not expose trusted-header mode directly to the internet without a protective proxy.

## 4) Branding Behavior

- Set `WEBUI_NAME=EXODO Nexus`.
- Backend appends ` (Open WebUI)` when custom name is used.
- This keeps upstream attribution visible while enabling EXODO-facing branding.

## 5) Upstream Sync Workflow

Use the helper script:

- `bash scripts/sync-upstream.sh`

What it does:

1. Fetches `upstream` and `origin`.
2. Fast-forwards local `main` to `upstream/main`.
3. Pushes `main` to origin.
4. Merges `main` into `exodo-brand`.
5. Pushes `exodo-brand`.

## 6) Recommended Release Flow

1. Keep `main` close to upstream.
2. Implement all EXODO-specific changes in `exodo-brand`.
3. Tag releases from `exodo-brand` (example: `exodo-v0.8.12-1`).
4. On each upstream update:
   - run sync script,
   - resolve conflicts in `exodo-brand`,
   - run smoke tests,
   - release new EXODO tag.
