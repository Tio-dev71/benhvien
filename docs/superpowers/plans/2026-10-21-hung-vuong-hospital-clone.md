# Bệnh Viện Đa Khoa Hùng Vương Clone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete, responsive 1:1 clone of the Bệnh viện Đa khoa Hùng Vương website (https://benhvienhungvuong.vn/) for both desktop PC and mobile viewports.

**Architecture:** Modern semantic HTML5, Vanilla CSS3 with custom properties and responsive Flexbox/Grid, and ES6+ JavaScript organized into `js/data.js` (complete dataset with optional live sync fallback) and `js/app.js` (UI lifecycle and interactions).

**Tech Stack:** HTML5, CSS3, ES6+ JavaScript, Remix Icon (`@4.2.0`), FontAwesome 6, Google Fonts (`Inter`, `Montserrat`).

**Spec:** [docs/superpowers/specs/2026-10-21-hung-vuong-hospital-clone-design.md](file:///Users/tiodev/Desktop/benhvienclone/docs/superpowers/specs/2026-10-21-hung-vuong-hospital-clone-design.md)

## Global Constraints
- Primary Brand Blue: `#1274bc`, Secondary Blue: `#0085db`, Emergency Red: `#c50c03`
- Responsive Breakpoints: Desktop (`>=992px`), Tablet (`768px-991px`), Mobile (`<768px`)
- Zero external build tooling required: must run directly in any browser or with `npx serve` / Python HTTP server
- Fully functional offline data with automatic live API synchronization fallback

---

### Task 1: Complete Project Setup & Core Dataset Architecture
**Files:**
- Create: `js/data.js`
- Test: `test_data.js`

- [ ] **Step 1: Create `js/data.js` with full structured dataset**
Populate hospital settings, navigation menu tree (46 items), hero slides, why-choose-us cards, 8 specialized services, 20 specialties, 4 gallery groups, 5 branch articles, and 11 client hospital logos.
- [ ] **Step 2: Verify `js/data.js` integrity with node runner**
Run: `node -e "const data = require('./js/data.js'); console.log('Data loaded successfully:', Object.keys(data));"`
Expected: Prints `settings`, `menus`, `slides`, `services`, `chuyenKhoas`, `galleries`, `branches`, `clients`.
- [ ] **Step 3: Commit**
`git add js/data.js && git commit -m "feat: setup full offline-first hospital dataset"`

---

### Task 2: Core Design System & CSS Foundation
**Files:**
- Create: `css/style.css`

- [ ] **Step 1: Write `css/style.css` design tokens, reset, typography, and utility classes**
Define brand colors, container widths, responsive grids, buttons, badges, card hover effects, and keyframe animations (`btn-lac-lu`, `pulseStar`).
- [ ] **Step 2: Verify CSS syntax and rules**
Check standard linting and verify rules are valid CSS.
- [ ] **Step 3: Commit**
`git add css/style.css && git commit -m "style: implement design tokens and core stylesheet"`

---

### Task 3: Top Announcement Bar, Header, Main Navigation & Mobile Drawer
**Files:**
- Create: `index.html` (header section)
- Create: `js/app.js` (header & drawer navigation logic)

- [ ] **Step 1: Construct semantic HTML for Top Bar, Desktop Header, Navigation Menu, and Mobile Drawer in `index.html`**
- [ ] **Step 2: Add navigation event handlers, live search autocomplete, and mobile offcanvas toggle in `js/app.js`**
- [ ] **Step 3: Commit**
`git add index.html js/app.js && git commit -m "feat: implement header, live search, and mobile drawer"`

---

### Task 4: Hero Banner Slider & 3 Quick Action Floating Cards
**Files:**
- Modify: `index.html`
- Modify: `css/style.css`
- Modify: `js/app.js`

- [ ] **Step 1: Add HTML markup for Hero Carousel with next/prev arrows, indicators, and the 3 overlapping quick action cards**
- [ ] **Step 2: Implement auto-rotation carousel logic in `js/app.js` (5s interval, touch swipe support)**
- [ ] **Step 3: Verify slider transitions and responsive card positioning on desktop & mobile**
- [ ] **Step 4: Commit**
`git add index.html css/style.css js/app.js && git commit -m "feat: implement hero carousel and floating action cards"`

---

### Task 5: "Tại sao nên chọn BVĐK Hùng Vương" & "Dịch vụ chuyên môn"
**Files:**
- Modify: `index.html`
- Modify: `css/style.css`
- Modify: `js/app.js`

- [ ] **Step 1: Implement "Tại sao nên chọn Bệnh viện Đa khoa Hùng Vương" with building photo & 4 feature cards**
- [ ] **Step 2: Implement "Dịch vụ chuyên môn" 8-card grid/carousel with responsive chunking (8 cards on PC, 4 cards on Mobile)**
- [ ] **Step 3: Add smooth scrolling and touch drag handlers in `js/app.js`**
- [ ] **Step 4: Commit**
`git add index.html css/style.css js/app.js && git commit -m "feat: implement why choose us and specialized services section"`

---

### Task 6: App Download Banner & "Chuyên khoa" Specialty Carousel
**Files:**
- Modify: `index.html`
- Modify: `css/style.css`
- Modify: `js/app.js`

- [ ] **Step 1: Add App Download promotional banner with phone mockup and QR codes**
- [ ] **Step 2: Add "Chuyên khoa" section with circular badges (10 per page on PC, 4 per page on Mobile)**
- [ ] **Step 3: Add pagination navigation and touch swiping in `js/app.js`**
- [ ] **Step 4: Commit**
`git add index.html css/style.css js/app.js && git commit -m "feat: implement app banner and specialties carousel"`

---

### Task 7: "Cơ sở vật chất & Thiết bị" (Galleries) & "Hệ thống Y tế Hùng Vương" (Branches)
**Files:**
- Modify: `index.html`
- Modify: `css/style.css`
- Modify: `js/app.js`

- [ ] **Step 1: Add "Cơ sở vật chất & Thiết bị" 4-tab filter with large featured photo & 4 grid thumbnails**
- [ ] **Step 2: Add "Hệ thống Y tế Hùng Vương" branch showcase with branch description, large render, and thumbnail switcher**
- [ ] **Step 3: Connect auto-rotating timer and tab click handlers in `js/app.js`**
- [ ] **Step 4: Commit**
`git add index.html css/style.css js/app.js && git commit -m "feat: implement gallery tabs and hospital network showcase"`

---

### Task 8: "Đối tác của chúng tôi", Footer, and Floating Action Buttons
**Files:**
- Modify: `index.html`
- Modify: `css/style.css`
- Modify: `js/app.js`

- [ ] **Step 1: Implement partner hospital logo slider with infinite/smooth navigation**
- [ ] **Step 2: Build comprehensive 4-column footer with clinic network directory, hotline links, and copyright**
- [ ] **Step 3: Implement floating action buttons: Hotline, Đặt lịch khám with `btn-lac-lu` animation, and Back to top button**
- [ ] **Step 4: Commit**
`git add index.html css/style.css js/app.js && git commit -m "feat: implement partner slider, footer, and floating widgets"`

---

### Task 9: Cross-Device Visual QA & Verification
**Files:**
- Test: Local browser verification via `browser_subagent` on Desktop (1440x900) and Mobile (375x667).

- [ ] **Step 1: Launch static local server and open desktop viewport**
- [ ] **Step 2: Verify all sections match PC screenshot from user**
- [ ] **Step 3: Open mobile viewport and verify hamburger menu, drawer, and card layouts match Mobile screenshot**
- [ ] **Step 4: Final commit and summary documentation**
`git add . && git commit -m "chore: complete 1:1 hung vuong hospital clone with PC & mobile support"`
