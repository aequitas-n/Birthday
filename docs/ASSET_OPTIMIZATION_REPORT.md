# Theme Asset Size Optimization Report

**Date:** 9 September 2026  
**Goal:** Maximum size reduction with zero meaningful visual quality loss  
**Scope:** Vintage Diary theme assets under `assets/themes/Vintage-Diary/` (+ unused font)

---

## 1. Original totals

| Measure | Before |
|---------|--------|
| Raw `assets/` folder | **45.62 MB** (47.84 MB incl. unused Inter + unused PNGs) |
| Theme PNGs only | **46.12 MB** / **~37.7 MB** of actively referenced theme images |
| Release APK (`app-release.apk`) | **106.47 MB** (9 Sep 2026 build) |
| Bundled `flutter_assets/assets` (prior) | **~39.14 MB** |

> Note: The ~110 MB figure matches the **release APK**, not source assets alone. Most of the APK is Flutter engine + AOT + ICU; theme images were ~39 MB of that.

---

## 2. Optimized totals

| Measure | After |
|---------|-------|
| Raw `assets/` folder | **4.88 MB** |
| Theme images (WebP) | **4.08 MB** |
| Fonts (Fraunces + Caveat + CourierPrime) | **0.80 MB** |
| Bundled `flutter_assets/assets` | **4.87 MB** |
| Release APK (`app-release.apk`) | **72.2 MB** |

**Raw asset savings:** 45.62 → 4.88 MB ≈ **40.7 MB** (**~89%** of prior asset folder)  
**APK savings:** 106.47 → 72.2 MB ≈ **34.3 MB** (**~32%** of prior release APK)

---

## 3–5. APK / percentage

| | Before | After | Delta |
|--|--------|-------|-------|
| Source `assets/` | 45.62 MB | 4.88 MB | −89% |
| Bundled flutter assets | 39.14 MB | 4.87 MB | −88% |
| Release APK | 106.47 MB | **72.2 MB** | **−32%** (−34.3 MB) |

APK reduction ≠ asset reduction 1:1 because the Flutter engine, AOT snapshot, and native libs dominate the remaining ~72 MB.
---

## 6. Top 20 largest assets BEFORE

| # | File | Size | Dims | Alpha |
|---|------|------|------|-------|
| 1 | text-card.png | 3.26 MB | 1448×1086 | yes (UNUSED) |
| 2 | Calm-Mood.png | 2.98 MB | 1230×1278 | yes |
| 3 | profile_card.png | 2.97 MB | 941×1672 | no |
| 4 | profile-card.png | 2.94 MB | 842×1867 | yes (UNUSED) |
| 5 | Anxious-Mood.png | 2.86 MB | 1230×1278 | yes |
| 6 | Affection-Mood.png | 2.82 MB | 1230×1278 | yes |
| 7 | Sad-Mood.png | 2.81 MB | 1230×1278 | yes |
| 8 | Frustrated-Mood.png | 2.76 MB | 1230×1278 | yes |
| 9 | Surprised-Mood.png | 2.72 MB | 1230×1278 | yes |
| 10 | Neutral-Mood.png | 2.62 MB | 1230×1278 | yes |
| 11 | Journal-Card.png | 2.49 MB | 1402×1122 | no |
| 12 | Joyful-Mood.png | 2.39 MB | 1230×1278 | yes |
| 13 | vintage-bg.png | 2.38 MB | 941×1672 | no |
| 14 | Calendar.png | 2.26 MB | 1254×1254 | no |
| 15 | Excited-home.png | 2.08 MB | 1230×1278 | yes |
| 16 | bottom-navbar.png | 1.78 MB | 2172×724 | yes |
| 17 | user-strip.png | 1.43 MB | 2172×724 | yes |
| 18 | search.png | 1.32 MB | 2090×341 | yes |
| 19 | profile_card1.png | 1.25 MB | 941×1672 | yes (UNUSED) |
| 20 | Inter-Variable.ttf | 0.88 MB | — | UNUSED (not in pubspec) |

---

## 7. Top assets AFTER

| File | Size |
|------|------|
| profile_card.webp | 555 KB |
| Journal-Card.webp | 296 KB |
| bottom-navbar.webp | 292 KB |
| vintage-bg.webp | 280 KB |
| Anxious-Mood.webp | 270 KB |
| Calm-Mood.webp | 258 KB |
| Frustrated-Mood.webp | 245 KB |
| Affection-Mood.webp | 239 KB |
| Sad-Mood.webp | 232 KB |
| Surprised-Mood.webp | 230 KB |
| user-strip.webp | 225 KB |
| Joyful-Mood.webp | 221 KB |
| Calendar.webp | 219 KB |
| Neutral-Mood.webp | 217 KB |
| search.webp | 203 KB |
| Excited-home.webp | 187 KB |

---

## 8. PNG → WebP conversions (16)

All actively shipped theme images:

**Opaque (cwebp q=92, no resize):**  
`vintage-bg`, `Journal-Card`, `Calendar`, `profile_card`

**Transparent chrome (cwebp q=90, alpha_q=100, -exact):**  
`bottom-navbar`, `user-strip`, `search`

**Moods (resize max edge 768 → 739×768, then WebP q=90 + alpha):**  
all 8 mood illustrations + `Excited-home`

---

## 9. Lossless PNG (oxipng)

Tried on every candidate. Savings were small (~5–10%) vs originals; **lossy high-quality WebP always won** by a large margin. Oxipng results retained in `tools/_opt_trial/*.oxi.png` for comparison only — not shipped.

---

## 10. Assets resized

| Set | Before | After | Rationale |
|-----|--------|-------|-----------|
| Mood illustrations + Excited-home | 1230×1278 | 739×768 | Max on-screen use ≈ 144 dp × 3 DPR ≈ 432 px; 768 leaves headroom for invite (~46% card width) and future peeks. Aspect ratio unchanged. |

**Not resized:** backgrounds, profile card, journal card, calendar, chrome strips — already near or below useful 3× phone budgets; downscaling would soften cover-fit backgrounds.

---

## 11–12. Duplicates / unused removed

| File | Why | Referenced? | Action |
|------|-----|-------------|--------|
| `text-card.png` (3.26 MB) | Token + pubspec only; never `Image.asset` | Dead | Removed from pubspec + quarantined to `tools/_opt_backup_png/` |
| `profile-card.png` (2.94 MB) | Hyphen variant; not in pubspec | No | Quarantined |
| `profile_card1.png` (1.25 MB) | Alternate; not in pubspec | No | Quarantined |
| `Inter-Variable.ttf` (0.88 MB) | Not listed under `flutter.fonts`; tests forbid Inter | No | Quarantined |

No byte-identical duplicates among active assets.

---

## 13. Intentionally untouched

| Asset | Why |
|-------|-----|
| Fraunces / Caveat / CourierPrime fonts | Required typography; already modest (~0.8 MB) |
| Design system `.txt` specs | Tiny docs, not bundled as Flutter assets |
| PNG originals in `tools/_opt_backup_png/` | Recovery / visual A-B; not shipped |

---

## 14. Visual regression

- Functional suite: **220/220 pass** after format switch  
- Manual emulator A-B: **recommended** — compare parchment grain on `vintage-bg` / `Journal-Card` / `profile_card` and mood alpha edges  
- Goldens: still stale from prior UI work; regenerate only after visual sign-off  

Quality gate used:

- WebP q≥90 (opaque q=92)  
- Alpha preserved with `-exact` / `alpha_q=100`  
- Mood aspect ratio unchanged  
- Flutter `Image.asset` / `AssetImage` paths updated  

---

## 15. Remaining opportunities

1. Further WebP quality tuning (q=85) if grain still looks identical — small extra savings  
2. Split APK / App Bundle so unused ABI slices shrink install size further (engine, not art)  
3. Regenerate goldens after visual QA  
4. Optional: delete `tools/_opt_backup_png` once signed off (frees local disk only)

---

## Classification (Phase 2)

| Class | Assets | Strategy used |
|-------|--------|---------------|
| A Photographic/bg | vintage-bg, Journal-Card, Calendar, profile_card | High-q WebP, no resize |
| B Parchment texture | (same as A for this theme) | High-q WebP |
| C Transparent illustration | Moods, Excited-home | Resize + WebP+alpha |
| D/E Chrome strips | navbar, user-strip, search | WebP+alpha, no resize |
| F Debug/reference | design `.txt` | Left |
| G Duplicate | none exact | — |
| H Unused | text-card, profile-card, profile_card1, Inter | Removed from ship set |
| I Exact PNG fidelity needed | none required after WebP visual check | — |

---

## Savings breakdown (theme images in optimization set)

| Mechanism | Approx. contribution |
|-----------|----------------------|
| Format optimization (PNG→WebP) | ~majority of 33.6 MB trial savings |
| Resolution (moods 1230→768) | significant on mood set |
| Unused removed from ship set | ~8.3 MB source (text-card was in pubspec; others were disk-only) |
| Lossless oxipng alone | ~1–2 MB (superseded by WebP) |

Trial on 16 active images: **37,753 KB → 4,168 KB (−89.0%)**.

---

## Files changed

- `assets/themes/Vintage-Diary/**` — WebP replacements  
- `pubspec.yaml` — asset list  
- `lib/design/tokens/vintage_diary_tokens.dart` — paths; removed unused `textCard`  
- Comments in geometry / mood / journal card docs  
- `tools/optimize_theme_assets.ps1`, `tools/asset_audit.dart` — reproducible pipeline  
- Originals preserved under `tools/_opt_backup_png/`
