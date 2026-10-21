/**
 * BỆNH VIỆN ĐA KHOA HÙNG VƯƠNG - AUTHENTICATION MODULE (SUPABASE)
 * Phone number + Password authentication with session management
 * Direct integration with Supabase (https://tfnxmcseexinbgkzwmwh.supabase.co)
 */

(function (window) {
  // SUPABASE CONFIGURATION
  const SUPABASE_URL = 'https://tfnxmcseexinbgkzwmwh.supabase.co';
  const SUPABASE_ANON_KEY = 'sb_publishable_TiioCrJ1dydHkTy3EyP9mg_gIeBphuV';

  let supabaseClient = null;

  function initSupabase() {
    if (window.supabase && SUPABASE_URL && SUPABASE_ANON_KEY) {
      try {
        supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        console.log('✅ Supabase client initialized with URL:', SUPABASE_URL);
      } catch (e) {
        console.warn('Could not initialize Supabase client:', e);
      }
    }
  }

  // Clean phone to Vietnamese national format (e.g. 0913529115)
  function cleanPhone(phone) {
    if (!phone) return '';
    let digits = phone.trim().replace(/\D/g, '');
    if (digits.startsWith('84')) {
      digits = '0' + digits.substring(2);
    }
    return digits;
  }

  // Map phone number to Supabase auth email identity (clean, 100% free, zero Twilio SMS cost)
  function phoneToEmail(phone) {
    const digits = cleanPhone(phone);
    return `${digits}@hungvuong.hospital`;
  }

  // Current user state
  let currentUser = null;

  // UI Elements
  function setupAuthUI() {
    const modalBackdrop = document.getElementById('authModalBackdrop');
    const authModal = document.getElementById('authModal');
    const openBtns = document.querySelectorAll('.open-auth-modal-btn');
    const closeBtn = document.getElementById('closeAuthModalBtn');

    const tabLogin = document.getElementById('authTabLogin');
    const tabRegister = document.getElementById('authTabRegister');
    const formLogin = document.getElementById('authFormLogin');
    const formRegister = document.getElementById('authFormRegister');
    const authAlert = document.getElementById('authAlertBox');

    function showAlert(msg, isSuccess = false) {
      if (!authAlert) return;
      authAlert.textContent = msg;
      authAlert.className = `auth-alert ${isSuccess ? 'success' : 'error'}`;
      authAlert.style.display = 'block';
    }

    function hideAlert() {
      if (authAlert) authAlert.style.display = 'none';
    }

    function openModal(defaultTab = 'login') {
      hideAlert();
      switchTab(defaultTab);
      modalBackdrop?.classList.add('active');
      authModal?.classList.add('active');
      document.body.style.overflow = 'hidden';
    }

    function closeModal() {
      modalBackdrop?.classList.remove('active');
      authModal?.classList.remove('active');
      document.body.style.overflow = '';
      hideAlert();
    }

    function switchTab(tab) {
      hideAlert();
      if (tab === 'login') {
        tabLogin?.classList.add('active');
        tabRegister?.classList.remove('active');
        if (formLogin) formLogin.style.display = 'block';
        if (formRegister) formRegister.style.display = 'none';
      } else {
        tabRegister?.classList.add('active');
        tabLogin?.classList.remove('active');
        if (formRegister) formRegister.style.display = 'block';
        if (formLogin) formLogin.style.display = 'none';
      }
    }

    tabLogin?.addEventListener('click', () => switchTab('login'));
    tabRegister?.addEventListener('click', () => switchTab('register'));

    openBtns.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        openModal(btn.dataset.tab || 'login');
      });
    });

    closeBtn?.addEventListener('click', closeModal);
    modalBackdrop?.addEventListener('click', closeModal);

    // Password visibility toggle
    document.querySelectorAll('.toggle-password-btn').forEach(btn => {
      btn.addEventListener('click', function () {
        const inputId = this.dataset.target;
        const input = document.getElementById(inputId);
        const icon = this.querySelector('i');
        if (input) {
          if (input.type === 'password') {
            input.type = 'text';
            icon?.classList.replace('ri-eye-line', 'ri-eye-off-line');
          } else {
            input.type = 'password';
            icon?.classList.replace('ri-eye-off-line', 'ri-eye-line');
          }
        }
      });
    });

    // Handle Login Form Submit
    formLogin?.addEventListener('submit', async function (e) {
      e.preventDefault();
      const phoneInput = document.getElementById('loginPhone').value.trim();
      const password = document.getElementById('loginPassword').value;
      const submitBtn = document.getElementById('btnLoginSubmit');

      if (!phoneInput || !password) {
        showAlert('Vui lòng nhập đầy đủ số điện thoại và mật khẩu.');
        return;
      }

      const phone = cleanPhone(phoneInput);
      const email = phoneToEmail(phoneInput);

      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="ri-loader-4-line fa-spin me-2"></i>Đang đăng nhập...';
      }

      try {
        let authSuccess = false;
        let userData = null;

        if (supabaseClient) {
          const { data, error } = await supabaseClient.auth.signInWithPassword({
            email: email,
            password: password
          });

          if (!error && data?.user) {
            authSuccess = true;
            userData = data.user;
          } else if (error) {
            console.warn('Supabase auth error:', error.message);
            if (error.message.includes('Invalid login credentials')) {
              showAlert('Số điện thoại hoặc mật khẩu không chính xác.');
            } else if (error.message.includes('Email not confirmed')) {
              showAlert('Tài khoản đang được kích hoạt, vui lòng thử lại sau giây lát...');
            } else {
              showAlert('Lỗi: ' + error.message);
            }
          }
        }

        // Local fallback cache if offline
        if (!authSuccess) {
          const localUsers = JSON.parse(localStorage.getItem('hospital_registered_users') || '[]');
          const found = localUsers.find(u => u.phone === phone && u.password === password);
          if (found) {
            authSuccess = true;
            userData = { phone: phone, user_metadata: { full_name: found.name, phone: phone } };
          }
        }

        if (authSuccess && userData) {
          currentUser = userData;
          const displayName = userData.user_metadata?.full_name || 'Bệnh nhân';
          localStorage.setItem('hospital_logged_user', JSON.stringify({
            phone: phone,
            user_metadata: { full_name: displayName, phone: phone }
          }));
          updateUserDisplay(currentUser);
          showAlert(`Đăng nhập thành công! Chào mừng ${displayName}.`, true);
          setTimeout(() => {
            closeModal();
            if (submitBtn) {
              submitBtn.disabled = false;
              submitBtn.innerHTML = 'Đăng nhập ngay';
            }
          }, 1000);
          return;
        }
      } catch (err) {
        showAlert('Có lỗi xảy ra: ' + err.message);
      } finally {
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.innerHTML = 'Đăng nhập ngay';
        }
      }
    });

    // Handle Register Form Submit
    formRegister?.addEventListener('submit', async function (e) {
      e.preventDefault();
      const name = document.getElementById('regName').value.trim();
      const phoneInput = document.getElementById('regPhone').value.trim();
      const password = document.getElementById('regPassword').value;
      const confirmPassword = document.getElementById('regConfirmPassword').value;
      const submitBtn = document.getElementById('btnRegisterSubmit');

      if (!name || !phoneInput || !password) {
        showAlert('Vui lòng điền đầy đủ các thông tin bắt buộc.');
        return;
      }

      if (password.length < 6) {
        showAlert('Mật khẩu phải có độ dài tối thiểu 6 ký tự.');
        return;
      }

      if (password !== confirmPassword) {
        showAlert('Mật khẩu nhập lại không khớp.');
        return;
      }

      const phone = cleanPhone(phoneInput);
      const email = phoneToEmail(phoneInput);

      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="ri-loader-4-line fa-spin me-2"></i>Đang khởi tạo tài khoản...';
      }

      try {
        let registerSuccess = false;
        let createdUserId = null;

        // 1. Try create pre-confirmed user via backend API (zero rate limits, zero email confirmation issues)
        let backendCreated = false;
        try {
          const apiRes = await fetch('/api/auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ phone, name, password })
          });
          const apiData = await apiRes.json();
          if (apiData && apiData.id) {
            backendCreated = true;
            registerSuccess = true;
          } else if (apiData && apiData.msg && apiData.msg.toLowerCase().includes('already registered')) {
            showAlert('Số điện thoại này đã được đăng ký. Vui lòng chuyển sang tab Đăng nhập.');
            if (submitBtn) {
              submitBtn.disabled = false;
              submitBtn.innerHTML = 'Tạo tài khoản';
            }
            return;
          }
        } catch (e) {
          console.warn('Backend register fallback:', e);
        }

        // 2. Direct Supabase client fallback
        if (!backendCreated && supabaseClient) {
          const { data, error } = await supabaseClient.auth.signUp({
            email: email,
            password: password,
            options: {
              data: {
                full_name: name,
                phone: phone
              }
            }
          });

          if (!error && data?.user) {
            registerSuccess = true;
            createdUserId = data.user.id;
            try {
              await fetch('/api/auth/auto-confirm', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ user_id: createdUserId })
              });
            } catch (e) {}
          } else if (error) {
            console.warn('Supabase register error:', error.message);
            if (error.message && error.message.toLowerCase().includes('already registered')) {
              showAlert('Số điện thoại này đã được đăng ký. Vui lòng chuyển sang tab Đăng nhập.');
              if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerHTML = 'Tạo tài khoản';
              }
              return;
            }
          }
        }

        // Always save to local storage as fallback
        const localUsers = JSON.parse(localStorage.getItem('hospital_registered_users') || '[]');
        localUsers.push({ phone: phone, password, name });
        localStorage.setItem('hospital_registered_users', JSON.stringify(localUsers));
        registerSuccess = true;

        if (registerSuccess) {
          showAlert('Đăng ký tài khoản thành công! Đang tự động đăng nhập...', true);

          // Try instant login with Supabase
          if (supabaseClient) {
            const loginRes = await supabaseClient.auth.signInWithPassword({
              email: email,
              password: password
            });

            if (!loginRes.error && loginRes.data?.user) {
              currentUser = loginRes.data.user;
              localStorage.setItem('hospital_logged_user', JSON.stringify({
                phone: phone,
                user_metadata: { full_name: name, phone: phone }
              }));
              updateUserDisplay(currentUser);
              setTimeout(() => {
                closeModal();
                if (submitBtn) {
                  submitBtn.disabled = false;
                  submitBtn.innerHTML = 'Tạo tài khoản';
                }
              }, 1200);
              return;
            }
          }

          // Fallback redirect to login tab
          setTimeout(() => {
            switchTab('login');
            const logPhone = document.getElementById('loginPhone');
            if (logPhone) logPhone.value = phone;
            const logPass = document.getElementById('loginPassword');
            if (logPass) logPass.value = password;
          }, 1500);
        }
      } catch (err) {
        showAlert('Có lỗi xảy ra: ' + err.message);
      } finally {
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.innerHTML = 'Tạo tài khoản';
        }
      }
    });

    // Check existing active Supabase session
    if (supabaseClient) {
      supabaseClient.auth.getSession().then(({ data }) => {
        if (data && data.session && data.session.user) {
          currentUser = data.session.user;
          updateUserDisplay(currentUser);
        }
      });
    }

    // Check existing session in localStorage
    const savedUser = localStorage.getItem('hospital_logged_user');
    if (savedUser && !currentUser) {
      try {
        currentUser = JSON.parse(savedUser);
        updateUserDisplay(currentUser);
      } catch (e) {}
    }
  }

  function updateUserDisplay(user) {
    const authTriggers = document.querySelectorAll('.header-auth-trigger-wrap');
    const name = user?.user_metadata?.full_name || user?.phone || 'Bệnh nhân';
    const phone = user?.user_metadata?.phone || user?.phone || '';

    authTriggers.forEach(wrap => {
      wrap.innerHTML = `
        <div class="user-logged-box">
          <div class="user-info-chip" onclick="toggleUserDropdown(this)">
            <div class="user-avatar-circle">
              <i class="ri-user-smile-line"></i>
            </div>
            <span class="user-name-text">${name}</span>
            <i class="ri-arrow-down-s-line"></i>
          </div>
          <div class="user-dropdown-menu">
            <div class="dropdown-header">
              <strong>${name}</strong>
              <small>${phone}</small>
            </div>
            <a href="/ho-so" class="user-dropdown-item">
              <i class="ri-file-user-line me-2"></i> Hồ sơ sức khỏe
            </a>
            <a href="/ho-so" class="user-dropdown-item">
              <i class="ri-calendar-event-line me-2"></i> Lịch hẹn của tôi
            </a>
            <div class="dropdown-divider"></div>
            <a href="javascript:void(0)" class="user-dropdown-item logout" onclick="window.hospitalAuth.logout()">
              <i class="ri-logout-box-r-line me-2"></i> Đăng xuất
            </a>
          </div>
        </div>
      `;
    });
  }

  window.toggleUserDropdown = function (el) {
    const parent = el.closest('.user-logged-box');
    parent?.classList.toggle('active');
    const menu = parent?.querySelector('.user-dropdown-menu');
    menu?.classList.toggle('active');
  };

  document.addEventListener('click', e => {
    if (!e.target.closest('.user-logged-box')) {
      document.querySelectorAll('.user-dropdown-menu').forEach(m => m.classList.remove('active'));
      document.querySelectorAll('.user-logged-box').forEach(b => b.classList.remove('active'));
    }
  });

  function logout() {
    currentUser = null;
    localStorage.removeItem('hospital_logged_user');
    if (supabaseClient) {
      supabaseClient.auth.signOut();
    }
    location.reload();
  }

  window.hospitalAuth = {
    logout: logout
  };

  document.addEventListener('DOMContentLoaded', () => {
    initSupabase();
    setupAuthUI();
  });

})(window);
