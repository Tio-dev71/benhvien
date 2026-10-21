# Design Specification: Bệnh Viện Đa Khoa Hùng Vương Clone (PC & Mobile)

## 1. Overview & Objective
- **Project**: Complete 1:1 frontend clone of the official website of [Bệnh viện Đa khoa Hùng Vương](https://benhvienhungvuong.vn/).
- **Target Audience & Use Case**: University/Course Capstone Project (Đồ án), delivered quickly and reliably.
- **Scope**: Responsive single-page application covering both desktop (PC) and mobile viewpoints with pixel-perfect visual styling, responsive layouts, interactive widgets (sliders, carousels, tabs, modals, mobile offcanvas menu), and embedded real-world dataset with dynamic rendering.

## 2. Technology Stack & Architecture
- **Structure**: Semantic HTML5 with accessibility attributes and SEO tags.
- **Styling**: Modern Vanilla CSS3 with CSS custom properties (variables), Flexbox, CSS Grid, media queries for mobile-first responsiveness, and smooth animations.
- **Icons & Fonts**:
  - Google Fonts (`Inter`, `Montserrat` or native fallbacks matching Myriad Pro).
  - Remix Icons (`remixicon@4.2.0`) & FontAwesome 6 for icons.
- **Logic**: Vanilla ES6+ JavaScript (`data.js` and `app.js`).
- **Data Architecture**:
  - Hybrid offline-first architecture: `data.js` contains the complete live dataset (46 menu items, 4 hero banners, 8 specialized services, 20 specialties, galleries, 5 medical branches, partner hospitals, and contact information).
  - Optional non-blocking API synchronization hook to `https://apiweb.benhvienhungvuong.vn`.

## 3. Section Breakdown & UI Components

### 3.1 Top Bar & Header
- **Top Announcement Bar**: Working hours, emergency hotline `1800 9415` / `0913 529 115`.
- **Main Header (PC)**:
  - Hospital logo with red cross symbol & brand name.
  - Search input box with live autocomplete filter.
  - Quick action buttons: Phone call button & "Đặt lịch khám" button.
- **Navigation Bar**:
  - Primary menu: Trang chủ, Giới thiệu, Chuyên khoa, Dịch vụ, Hướng dẫn khám, Y học thường thức, Hệ thống y tế, Tuyển dụng.
  - Multi-level dropdown menus for subcategories.
- **Mobile Header & Drawer**:
  - Compact header with logo, hotline tap button, and hamburger icon.
  - Offcanvas drawer with full animated transition containing accordion-style navigation, search bar, and social links.

### 3.2 Hero Banner & Floating Cards
- **Hero Slider**: Auto-cycling banner images with previous/next controls and indicator dots.
- **3 Floating Action Cards** (overlapping banner bottom on PC, stacked cleanly on Mobile):
  1. *Cấp cứu 24/7*: Hotline numbers with direct click-to-call links.
  2. *Đặt lịch khám*: Quick booking prompt.
  3. *Bắt đầu từ 05h30*: Reception opening time schedule.

### 3.3 "Tại sao nên chọn Bệnh viện Đa khoa Hùng Vương?"
- **Left**: Hospital building photo with modern rounded borders and elevation shadow.
- **Right**: 4 feature cards with custom icons and descriptive text:
  1. Đội ngũ chuyên môn vững vàng
  2. Chất lượng dịch vụ ngày càng nâng cao
  3. Ứng dụng công nghệ hiện đại
  4. Không ngừng học hỏi & phát triển chuyên môn

### 3.4 "Dịch vụ chuyên môn"
- Heading with signature hospital blue styling.
- 8 specialized services cards (2x4 grid on PC, 2x2 / swipeable on Mobile):
  - Chăm sóc y tế ngoại viện, Thai nghén trọn gói, Thẩm mỹ da liễu, Thận nhân tạo, Khám doanh nghiệp, Cấp cứu, Chuyên gia nước ngoài, Chuyên gia tuyến TW.
- Navigation arrows & pagination dots.

### 3.5 App Download Banner
- Full-width banner in brand blue gradient.
- Phone app mockups with QR codes for Google Play and App Store.

### 3.6 "Chuyên khoa"
- Grid of circular specialty badges with icons:
  - 10 items per page on PC (2 rows of 5) with left/right carousel pagination.
  - 4 items per page on mobile (2x2 grid) with touch swipe / dots.
  - Covers Hiến mô tạng, Da liễu, Nam học & Vô sinh, Gây mê, Chẩn đoán hình ảnh, Phục hồi chức năng, Thận nhân tạo, Cấp cứu, Dược, Mắt, v.v.

### 3.7 "Cơ sở vật chất & Thiết bị" (Galleries)
- Tab navigation: Cơ sở vật chất & Thiết bị | Hoạt động nổi bật | Đội ngũ Chuyên gia | Hệ thống khoa phòng.
- Left featured panel: Full-size high resolution photo with title and descriptive excerpt.
- Right grid: 4 image thumbnails with hover zoom effect and titles (Máy vi phẫu ZEISS TIVATO 700, Phòng mổ vô khuẩn, Máy MRI 1.5 Tesla, Hệ thống chụp DSA).

### 3.8 "Hệ thống Y tế Hùng Vương" (Branches)
- Split layout:
  - Featured building rendering / photography.
  - Title, description, address, and hotline for the selected branch (Gia Lai, Sơn Dương, Thanh Ba, Kim Xuyên, Chân Mộng).
  - Thumbnail selector cards to easily switch between branches with auto-rotation timer (every 5 seconds).

### 3.9 "Đối tác của chúng tôi"
- Logo carousel of partner hospitals: Vinmec, Việt Đức, Bệnh viện TW Thái Nguyên, Tai Mũi Họng TW, Tim Hà Nội, v.v.

### 3.10 Footer
- 4-column structured layout:
  - Col 1: Hospital identity, official registration, address, hotlines.
  - Col 2: Hospital working hours, patient admission schedule, emergency hotline.
  - Col 3: Network of satellite clinics with individual address and contact info.
  - Col 4: Social channels (Facebook, TikTok, YouTube, Zalo, Google Maps), Newsletter subscription form.
- Bottom copyright bar: Copyright © 2026 Bệnh viện Đa khoa Hùng Vương.

### 3.11 Floating Actions
- Left: Dual pills for Hotline (`1800 9415`) and "Đặt lịch khám" with wiggle animation (`btn-lac-lu`).
- Right: Scroll-to-top circular button with smooth scrolling behavior.

## 4. Verification & Testing Criteria
- Cross-browser compatibility (Chrome, Safari, Firefox, Edge).
- Viewport verification:
  - Desktop (>1200px)
  - Tablet (768px - 1199px)
  - Mobile (<768px)
- Zero build steps required: opens directly via file or local HTTP server.
