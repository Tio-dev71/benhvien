/**
 * BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - APPLICATION CONTROLLER
 * Full client-side interactive logic, responsive carousels, tabs, and live search
 */

document.addEventListener('DOMContentLoaded', function () {
  const data = window.HUNG_VUONG_DATA || {};

  // --------------------------------------------------------------------------
  // 1. DESKTOP & MOBILE NAVIGATION MENU
  // --------------------------------------------------------------------------
  function initNavigation() {
    const menus = data.menus || [];
    const desktopNavMenu = document.getElementById('desktopNavMenu');
    const mobileNavList = document.getElementById('mobileNavList');

    if (!menus.length) return;

    // Filter active & sort by displayOrder
    const activeMenus = menus.filter(m => m.isActive).sort((a, b) => a.displayOrder - b.displayOrder);
    const topMenus = activeMenus.filter(m => !m.parentId);

    // Build hierarchical tree
    const menuTree = topMenus.map(top => ({
      ...top,
      children: activeMenus.filter(m => m.parentId === top.id).sort((a, b) => a.displayOrder - b.displayOrder)
    }));

    // Render Desktop Nav
    if (desktopNavMenu) {
      desktopNavMenu.innerHTML = menuTree.map((item, index) => {
        const hasChildren = item.children && item.children.length > 0;
        const activeClass = index === 0 ? 'active' : '';
        const title = item.title || item.name || '';
        const link = item.link || item.url || '#';
        return `
          <li class="nav-item ${activeClass}">
            <a href="${link}" class="nav-link">
              <span>${title}</span>
              ${hasChildren ? '<i class="ri-arrow-down-s-line arrow-icon"></i>' : ''}
            </a>
            ${hasChildren ? `
              <div class="dropdown-menu">
                ${item.children.map(child => `
                  <a href="${child.link || child.url || '#'}" class="dropdown-link">${child.title || child.name || ''}</a>
                `).join('')}
              </div>
            ` : ''}
          </li>
        `;
      }).join('');
    }

    // Render Mobile Nav
    if (mobileNavList) {
      mobileNavList.innerHTML = menuTree.map((item, index) => {
        const hasChildren = item.children && item.children.length > 0;
        const title = item.title || item.name || '';
        const link = item.link || item.url || '#';
        return `
          <li class="mobile-nav-item">
            <div class="mobile-nav-link" data-has-children="${hasChildren}" ${hasChildren ? `onclick="toggleMobileSubmenu(this)"` : ''}>
              <a href="${link}" style="flex:1;">${title}</a>
              ${hasChildren ? '<i class="ri-arrow-down-s-line" style="font-size:1.1rem; transition: transform 0.2s;"></i>' : ''}
            </div>
            ${hasChildren ? `
              <div class="mobile-submenu">
                ${item.children.map(child => `
                  <a href="${child.link || child.url || '#'}" class="mobile-submenu-link">${child.title || child.name || ''}</a>
                `).join('')}
              </div>
            ` : ''}
          </li>
        `;
      }).join('');
    }
  }

  // Toggle mobile submenu accordion
  window.toggleMobileSubmenu = function (el) {
    const parent = el.parentElement;
    const submenu = parent.querySelector('.mobile-submenu');
    const arrow = el.querySelector('i');
    if (submenu) {
      const isOpen = submenu.classList.contains('open');
      submenu.classList.toggle('open', !isOpen);
      if (arrow) {
        arrow.style.transform = isOpen ? 'rotate(0)' : 'rotate(180deg)';
      }
    }
  };

  // Mobile Drawer Open / Close
  const openDrawerBtn = document.getElementById('openMobileDrawerBtn');
  const closeDrawerBtn = document.getElementById('closeMobileDrawerBtn');
  const drawer = document.getElementById('mobileDrawer');
  const backdrop = document.getElementById('mobileDrawerBackdrop');

  function openDrawer() {
    drawer?.classList.add('active');
    backdrop?.classList.add('active');
    document.body.style.overflow = 'hidden';
  }

  function closeDrawer() {
    drawer?.classList.remove('active');
    backdrop?.classList.remove('active');
    document.body.style.overflow = '';
  }

  openDrawerBtn?.addEventListener('click', openDrawer);
  closeDrawerBtn?.addEventListener('click', closeDrawer);
  backdrop?.addEventListener('click', closeDrawer);

  // --------------------------------------------------------------------------
  // 2. HERO SLIDER CAROUSEL
  // --------------------------------------------------------------------------
  let currentHeroSlide = 0;
  let heroTimer = null;
  const slides = (data.slides || []).filter(s => s.isActive).sort((a, b) => a.displayOrder - b.displayOrder);

  function initHeroSlider() {
    const slidesWrapper = document.getElementById('heroSlidesWrapper');
    const dotsContainer = document.getElementById('heroSliderDots');
    const prevBtn = document.getElementById('heroPrevBtn');
    const nextBtn = document.getElementById('heroNextBtn');

    if (!slides.length || !slidesWrapper) return;

    // Render slides
    slidesWrapper.innerHTML = slides.map(slide => `
      <div class="hero-slide">
        <a href="${slide.link || '#'}" ${slide.link ? 'target="_blank" rel="noopener"' : ''}>
          <img src="${slide.imageUrl}" alt="Slide Bệnh viện Đa khoa Hùng Vương" loading="lazy">
        </a>
      </div>
    `).join('');

    // Render dots
    if (dotsContainer) {
      dotsContainer.innerHTML = slides.map((_, i) => `
        <div class="slider-dot ${i === 0 ? 'active' : ''}" data-index="${i}"></div>
      `).join('');

      dotsContainer.querySelectorAll('.slider-dot').forEach(dot => {
        dot.addEventListener('click', () => {
          goToHeroSlide(parseInt(dot.dataset.index, 10));
          startHeroAutoplay();
        });
      });
    }

    prevBtn?.addEventListener('click', () => {
      prevHeroSlide();
      startHeroAutoplay();
    });

    nextBtn?.addEventListener('click', () => {
      nextHeroSlide();
      startHeroAutoplay();
    });

    // Touch Swipe for Hero Slider
    let touchStartX = 0;
    slidesWrapper.addEventListener('touchstart', e => {
      touchStartX = e.touches[0].clientX;
    }, { passive: true });

    slidesWrapper.addEventListener('touchend', e => {
      const touchEndX = e.changedTouches[0].clientX;
      const diff = touchStartX - touchEndX;
      if (Math.abs(diff) > 40) {
        if (diff > 0) nextHeroSlide();
        else prevHeroSlide();
        startHeroAutoplay();
      }
    }, { passive: true });

    startHeroAutoplay();
  }

  function goToHeroSlide(index) {
    const slidesWrapper = document.getElementById('heroSlidesWrapper');
    const dots = document.querySelectorAll('#heroSliderDots .slider-dot');
    if (!slidesWrapper) return;

    currentHeroSlide = (index + slides.length) % slides.length;
    slidesWrapper.style.transform = `translateX(-${currentHeroSlide * 100}%)`;

    dots.forEach((dot, i) => {
      dot.classList.toggle('active', i === currentHeroSlide);
    });
  }

  function nextHeroSlide() {
    goToHeroSlide(currentHeroSlide + 1);
  }

  function prevHeroSlide() {
    goToHeroSlide(currentHeroSlide - 1);
  }

  function startHeroAutoplay() {
    if (heroTimer) clearInterval(heroTimer);
    heroTimer = setInterval(nextHeroSlide, 5000);
  }

  // --------------------------------------------------------------------------
  // 3. TẠI SAO NÊN CHỌN BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG
  // --------------------------------------------------------------------------
  function initWhyChooseUs() {
    const why = data.whyChooseUs;
    const grid = document.getElementById('whyChooseFeaturesGrid');
    const mainImg = document.getElementById('whyChooseMainImg');

    if (!why || !grid) return;

    if (why.mainImageUrl && mainImg) {
      mainImg.src = why.mainImageUrl;
    }

    const items = [
      { icon: why.icon1Url, title: why.title1, desc: why.desc1 },
      { icon: why.icon2Url, title: why.title2, desc: why.desc2 },
      { icon: why.icon3Url, title: why.title3, desc: why.desc3 },
      { icon: why.icon4Url, title: why.title4, desc: why.desc4 }
    ];

    grid.innerHTML = items.map(item => `
      <div class="why-feature-card">
        <div class="why-feature-icon-box">
          <img src="${item.icon}" alt="${item.title}" class="why-feature-icon">
        </div>
        <h4 class="why-feature-title">${item.title}</h4>
        <p class="why-feature-desc">${item.desc}</p>
      </div>
    `).join('');
  }

  // --------------------------------------------------------------------------
  // 4. DỊCH VỤ CHUYÊN MÔN (SPECIALIZED SERVICES CAROUSEL)
  // --------------------------------------------------------------------------
  let currentServicePage = 0;
  let servicePageCount = 1;
  const services = data.services || [];

  function initServices() {
    const servicesGrid = document.getElementById('servicesGrid');
    const dotsContainer = document.getElementById('serviceDots');
    const prevBtn = document.getElementById('servicePrevBtn');
    const nextBtn = document.getElementById('serviceNextBtn');

    if (!services.length || !servicesGrid) return;

    // Check screen width for chunk size (8 on desktop, 4 on mobile)
    const isMobile = window.innerWidth < 992;
    const chunkSize = isMobile ? 4 : 8;
    servicePageCount = Math.ceil(services.length / chunkSize);

    renderServicePage(currentServicePage, chunkSize);

    // Render pagination dots
    if (dotsContainer) {
      dotsContainer.innerHTML = Array.from({ length: servicePageCount }).map((_, i) => `
        <div class="ck-dot ${i === currentServicePage ? 'active' : ''}" data-service-dot="${i}"></div>
      `).join('');

      dotsContainer.querySelectorAll('[data-service-dot]').forEach(dot => {
        dot.addEventListener('click', () => {
          currentServicePage = parseInt(dot.dataset.serviceDot, 10);
          renderServicePage(currentServicePage, chunkSize);
        });
      });
    }

    prevBtn?.addEventListener('click', () => {
      currentServicePage = currentServicePage > 0 ? currentServicePage - 1 : servicePageCount - 1;
      renderServicePage(currentServicePage, chunkSize);
    });

    nextBtn?.addEventListener('click', () => {
      currentServicePage = currentServicePage < servicePageCount - 1 ? currentServicePage + 1 : 0;
      renderServicePage(currentServicePage, chunkSize);
    });
  }

  function renderServicePage(page, chunkSize) {
    const servicesGrid = document.getElementById('servicesGrid');
    const dots = document.querySelectorAll('#serviceDots .ck-dot');
    if (!servicesGrid) return;

    const start = page * chunkSize;
    const pageItems = services.slice(start, start + chunkSize);

    servicesGrid.innerHTML = pageItems.map(item => `
      <a href="https://benhvienhungvuong.vn/${item.slug || ''}" target="_blank" class="service-card">
        <div class="service-thumb-wrap">
          <img src="${item.thumbnail}" alt="${item.title}" class="service-thumb" loading="lazy">
        </div>
        <div class="service-info">
          <h4 class="service-title">${item.title}</h4>
        </div>
      </a>
    `).join('');

    dots.forEach((dot, i) => {
      dot.classList.toggle('active', i === page);
    });
  }

  // --------------------------------------------------------------------------
  // 5. CHUYÊN KHOA (SPECIALTIES CAROUSEL)
  // --------------------------------------------------------------------------
  let currentCkPage = 0;
  let ckPageCount = 1;
  const chuyenKhoas = (data.chuyenKhoas || []).filter(c => c.isActive);

  function initChuyenKhoas() {
    const grid = document.getElementById('chuyenKhoaGrid');
    const dotsContainer = document.getElementById('ckDotsContainer');
    const prevBtn = document.getElementById('ckPrevBtn');
    const nextBtn = document.getElementById('ckNextBtn');

    if (!chuyenKhoas.length || !grid) return;

    const isMobile = window.innerWidth < 992;
    const chunkSize = isMobile ? 4 : 10;
    ckPageCount = Math.ceil(chuyenKhoas.length / chunkSize);

    renderCkPage(currentCkPage, chunkSize);

    if (dotsContainer) {
      dotsContainer.innerHTML = Array.from({ length: ckPageCount }).map((_, i) => `
        <div class="ck-dot ${i === currentCkPage ? 'active' : ''}" data-ck-dot="${i}"></div>
      `).join('');

      dotsContainer.querySelectorAll('[data-ck-dot]').forEach(dot => {
        dot.addEventListener('click', () => {
          currentCkPage = parseInt(dot.dataset.ckDot, 10);
          renderCkPage(currentCkPage, chunkSize);
        });
      });
    }

    prevBtn?.addEventListener('click', () => {
      currentCkPage = currentCkPage > 0 ? currentCkPage - 1 : ckPageCount - 1;
      renderCkPage(currentCkPage, chunkSize);
    });

    nextBtn?.addEventListener('click', () => {
      currentCkPage = currentCkPage < ckPageCount - 1 ? currentCkPage + 1 : 0;
      renderCkPage(currentCkPage, chunkSize);
    });
  }

  function renderCkPage(page, chunkSize) {
    const grid = document.getElementById('chuyenKhoaGrid');
    const dots = document.querySelectorAll('#ckDotsContainer .ck-dot');
    if (!grid) return;

    const start = page * chunkSize;
    const pageItems = chuyenKhoas.slice(start, start + chunkSize);

    grid.innerHTML = pageItems.map(item => `
      <a href="https://benhvienhungvuong.vn/${item.slug || ''}" target="_blank" class="chuyenkhoa-item" title="${item.originalTitle || item.titleSmall}">
        <div class="chuyenkhoa-circle">
          <img src="${item.iconUrl}" alt="${item.titleSmall}" class="chuyenkhoa-icon" loading="lazy">
        </div>
        <span class="chuyenkhoa-name">${item.titleSmall}</span>
      </a>
    `).join('');

    dots.forEach((dot, i) => {
      dot.classList.toggle('active', i === page);
    });
  }

  // --------------------------------------------------------------------------
  // 6. CƠ SỞ VẬT CHẤT & THIẾT BỊ (GALLERY TABS)
  // --------------------------------------------------------------------------
  let activeGalleryGroup = 'CO_SO_VAT_CHAT';
  const galleries = data.galleries || [];
  const galleryGroups = data.galleryGroups || [];

  function initGalleries() {
    const tabsWrap = document.getElementById('galleryTabsWrap');
    if (!tabsWrap || !galleryGroups.length) return;

    // Render Tabs
    tabsWrap.innerHTML = galleryGroups.map((g, i) => `
      <button class="gallery-tab-btn ${i === 0 ? 'active' : ''}" data-group="${g.code}">
        ${g.name}
      </button>
    `).join('');

    tabsWrap.querySelectorAll('.gallery-tab-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        tabsWrap.querySelectorAll('.gallery-tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        activeGalleryGroup = btn.dataset.group;
        renderGalleryGroup(activeGalleryGroup);
      });
    });

    renderGalleryGroup(activeGalleryGroup);
  }

  function renderGalleryGroup(groupCode) {
    const featuredCard = document.getElementById('galleryFeaturedCard');
    const thumbnailsGrid = document.getElementById('galleryThumbnailsGrid');
    if (!featuredCard || !thumbnailsGrid) return;

    let items = galleries.filter(g => g.groupCode === groupCode && g.isActive);
    if (!items.length) {
      items = galleries.filter(g => g.isActive);
    }

    if (!items.length) return;

    const featured = items[0];
    const thumbs = items.slice(1, 5);

    // Left featured card
    featuredCard.innerHTML = `
      <img src="${featured.imageUrl}" alt="${featured.title}" id="galleryMainImg">
      <div class="gallery-featured-overlay">
        <h3 class="gallery-featured-title" id="galleryMainTitle">${featured.title}</h3>
        <p class="gallery-featured-desc" id="galleryMainDesc">${featured.description}</p>
      </div>
    `;

    // Right 4 thumbs
    thumbnailsGrid.innerHTML = thumbs.map((item, idx) => `
      <div class="gallery-thumb-item" data-thumb-index="${idx}">
        <img src="${item.imageUrl}" alt="${item.title}" loading="lazy">
        <div class="gallery-thumb-title-bar">${item.title}</div>
      </div>
    `).join('');

    // Click on thumb to view on left
    thumbnailsGrid.querySelectorAll('.gallery-thumb-item').forEach((thumbEl, idx) => {
      thumbEl.addEventListener('click', () => {
        const selected = thumbs[idx];
        if (selected) {
          const img = document.getElementById('galleryMainImg');
          const title = document.getElementById('galleryMainTitle');
          const desc = document.getElementById('galleryMainDesc');
          if (img) img.src = selected.imageUrl;
          if (title) title.textContent = selected.title;
          if (desc) desc.textContent = selected.description;
        }
      });
    });
  }

  // --------------------------------------------------------------------------
  // 7. HỆ THỐNG Y TẾ HÙNG VƯƠNG (BRANCHES SHOWCASE)
  // --------------------------------------------------------------------------
  let currentBranchIndex = 0;
  let branchTimer = null;
  const branches = data.branches || [];

  function initBranches() {
    const thumbnailsRow = document.getElementById('branchThumbnailsRow');
    if (!branches.length || !thumbnailsRow) return;

    // Render selector thumbnails
    thumbnailsRow.innerHTML = branches.map((b, i) => `
      <div class="branch-thumb-card ${i === 0 ? 'active' : ''}" data-branch-idx="${i}">
        <img src="${b.thumbnail}" alt="${b.title}" loading="lazy">
        <div class="branch-thumb-name">${b.title}</div>
      </div>
    `).join('');

    thumbnailsRow.querySelectorAll('.branch-thumb-card').forEach(card => {
      card.addEventListener('click', () => {
        selectBranch(parseInt(card.dataset.branchIdx, 10));
        startBranchTimer();
      });
    });

    selectBranch(0);
    startBranchTimer();
  }

  function selectBranch(index) {
    if (!branches.length) return;
    currentBranchIndex = (index + branches.length) % branches.length;
    const branch = branches[currentBranchIndex];

    const heroImg = document.getElementById('branchHeroImg');
    const title = document.getElementById('branchTitle');
    const desc = document.getElementById('branchDesc');
    const addr = document.getElementById('branchAddress');
    const phone = document.getElementById('branchPhone');

    if (heroImg) heroImg.src = branch.thumbnail;
    if (title) title.textContent = branch.title;
    if (desc) desc.textContent = branch.description || 'Được đầu tư bài bản với trang thiết bị đồng bộ, cung cấp dịch vụ y tế an toàn, thuận tiện nhất cho nhân dân trong khu vực.';

    // Branch specific addresses & phone lookups from settings
    const settings = data.settings || {};
    if (branch.title.includes('Gia Lai')) {
      if (addr) addr.textContent = settings.diachiGL || '236A Lê Duẩn, Phường Hội Phú, Tỉnh Gia Lai';
      if (phone) phone.textContent = settings.hotlineGL || '1800 8015';
    } else if (branch.title.includes('Sơn Dương')) {
      if (addr) addr.textContent = settings.diachiSD || 'TDP Tân Phúc, Xã Sơn Dương, Tỉnh Tuyên Quang';
      if (phone) phone.textContent = settings.sdtSD || '0913 529 115';
    } else if (branch.title.includes('Kim Xuyên')) {
      if (addr) addr.textContent = settings.diachiKX || 'Thôn Gò Đình, Xã Hồng Sơn, Tỉnh Tuyên Quang';
      if (phone) phone.textContent = settings.sdtKX || '0913 709 115';
    } else if (branch.title.includes('Chân Mộng')) {
      if (addr) addr.textContent = settings.diachiCM || 'Khu 2, Xã Chân Mộng, Tỉnh Phú Thọ';
      if (phone) phone.textContent = settings.sdtCM || '0913 759 115';
    } else if (branch.title.includes('Thanh Ba')) {
      if (addr) addr.textContent = settings.diachiTB || 'Khu 4, Xã Thanh Ba, Tỉnh Phú Thọ';
      if (phone) phone.textContent = settings.sdtTB || '0913 704 115';
    } else {
      if (addr) addr.textContent = 'Hệ thống Y tế Hùng Vương';
      if (phone) phone.textContent = '1800 9415';
    }

    // Active class for thumbs
    document.querySelectorAll('#branchThumbnailsRow .branch-thumb-card').forEach((card, i) => {
      card.classList.toggle('active', i === currentBranchIndex);
    });
  }

  function startBranchTimer() {
    if (branchTimer) clearInterval(branchTimer);
    branchTimer = setInterval(() => {
      selectBranch(currentBranchIndex + 1);
    }, 5000);
  }

  // --------------------------------------------------------------------------
  // 8. ĐỐI TÁC CỦA CHÚNG TÔI (CLIENTS SLIDER)
  // --------------------------------------------------------------------------
  function initPartners() {
    const track = document.getElementById('partnersTrack');
    const clients = (data.clients || []).filter(c => c.isActive);

    if (!clients.length || !track) return;

    track.innerHTML = clients.map(client => `
      <div class="partner-card" title="${client.name}">
        <img src="${client.imgUrl}" alt="${client.name}" class="partner-logo" loading="lazy">
      </div>
    `).join('');
  }

  // --------------------------------------------------------------------------
  // 9. LIVE SEARCH AUTOCOMPLETE (DESKTOP & MOBILE)
  // --------------------------------------------------------------------------
  function initLiveSearch() {
    setupSearchInput('desktopSearchInput', 'desktopSearchDropdown');
    setupSearchInput('mobileSearchInput', 'mobileSearchDropdown');
  }

  function setupSearchInput(inputId, dropdownId) {
    const input = document.getElementById(inputId);
    const dropdown = document.getElementById(dropdownId);
    if (!input || !dropdown) return;

    input.addEventListener('input', function () {
      const q = this.value.trim().toLowerCase();
      if (!q) {
        dropdown.classList.remove('active');
        dropdown.innerHTML = '';
        return;
      }

      // Search across services, specialties, and branches
      const matchedServices = (data.services || []).filter(s => s.title.toLowerCase().includes(q));
      const matchedCk = (data.chuyenKhoas || []).filter(c => c.titleSmall.toLowerCase().includes(q) || (c.originalTitle && c.originalTitle.toLowerCase().includes(q)));
      const matchedBranches = (data.branches || []).filter(b => b.title.toLowerCase().includes(q));

      const combined = [
        ...matchedServices.map(s => ({ title: s.title, thumb: s.thumbnail, url: `https://benhvienhungvuong.vn/${s.slug || ''}` })),
        ...matchedCk.map(c => ({ title: c.titleSmall, thumb: c.iconUrl, url: `https://benhvienhungvuong.vn/${c.slug || ''}` })),
        ...matchedBranches.map(b => ({ title: b.title, thumb: b.thumbnail, url: `https://benhvienhungvuong.vn/${b.slug || ''}` }))
      ].slice(0, 5);

      if (!combined.length) {
        dropdown.innerHTML = `<div style="padding: 12px; font-size: 0.88rem; color: #64748b; text-align: center;">Không tìm thấy kết quả phù hợp cho "${q}"</div>`;
        dropdown.classList.add('active');
        return;
      }

      dropdown.innerHTML = combined.map(item => `
        <a href="${item.url}" target="_blank" class="search-result-item">
          <img src="${item.thumb}" alt="${item.title}" class="search-result-img">
          <span class="search-result-title">${item.title}</span>
        </a>
      `).join('');

      dropdown.classList.add('active');
    });

    // Close on click outside
    document.addEventListener('click', e => {
      if (!input.contains(e.target) && !dropdown.contains(e.target)) {
        dropdown.classList.remove('active');
      }
    });
  }

  // --------------------------------------------------------------------------
  // 10. BACK TO TOP BUTTON
  // --------------------------------------------------------------------------
  function initBackToTop() {
    const btn = document.getElementById('globalBackToTop');
    if (!btn) return;

    window.addEventListener('scroll', function () {
      if (window.scrollY > 300) {
        btn.classList.add('show');
      } else {
        btn.classList.remove('show');
      }
    });

    btn.addEventListener('click', function () {
      window.scrollTo({
        top: 0,
        behavior: 'smooth'
      });
    });
  }

  // Handle window resize for dynamic chunk recalculation
  window.addEventListener('resize', () => {
    initServices();
    initChuyenKhoas();
  });

  // --------------------------------------------------------------------------
  // INITIALIZE ALL COMPONENTS
  // --------------------------------------------------------------------------
  initNavigation();
  initHeroSlider();
  initWhyChooseUs();
  initServices();
  initChuyenKhoas();
  initGalleries();
  initBranches();
  initPartners();
  initLiveSearch();
  initBackToTop();

  console.log('Bệnh viện Đa khoa Hùng Vương Clone initialized successfully.');
});
