# Lucerne Herbicides – PWA

This is a Progressive Web App version of the herbicide guide. It works offline and can be installed on iPhone via “Add to Home Screen.”

## Structure
- `index.html` – App shell
- `styles.css` – Mobile-friendly styles
- `app.js` – Search, filters, detail view, and state persistence
- `manifest.webmanifest` – PWA metadata (name, icons)
- `sw.js` – Service worker for offline caching
- `data/herbicides.json` – Preloaded dataset
- `icons/` – Place icon-192.png and icon-512.png here (optional)

## Deploy to GitHub Pages (automatic)
A GitHub Actions workflow is provided at `.github/workflows/deploy-pwa.yml` that publishes this folder to GitHub Pages whenever you push to `main` or `master`.

Steps (one-time):
1. Push your repository to GitHub (include this `pwa/` folder and the workflow file).
2. In GitHub → Settings → Pages:
   - Build and deployment → Source: GitHub Actions (select it).
3. Push a commit (or click "Run workflow") to trigger the deploy.
4. After it runs, find your site URL in:
   - Actions → the "Deploy PWA to GitHub Pages" workflow → "Deploy to GitHub Pages" step output → `page_url`
   - Or Settings → Pages → "Your site is live".

## Install on iPhone
1. Open the GitHub Pages URL in Safari on your iPhone.
2. Tap the Share button → Add to Home Screen → Add.
3. Launch from the Home Screen; it will cache for offline use after first open.

## Local preview (optional)
- Python 3: `python -m http.server 5173` (from the `pwa/` directory) → open `http://localhost:5173`
- Node: `npm i -g serve` then `serve -l 5173`

## Custom icons (optional)
- Add `pwa/icons/icon-192.png` and `pwa/icons/icon-512.png` (PNG) to brand the app icon.
- The manifest already references these filenames.

## Notes
- Filtering behavior matches the iOS app: type, phytotoxicity, application timing, and specific weeds (all selected weeds must be controlled).
- The service worker caches `index.html`, CSS, JS, manifest, and `data/herbicides.json`.
