const form = document.getElementById('loginForm');
const errorMsg = document.getElementById('error');

form.addEventListener('submit', async (e) => {
  e.preventDefault();

  const email = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value.trim();

  try {
    const response = await fetch('http://localhost:8000/managers/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email, password }),
    });

    if (!response.ok) {
      throw new Error('Неверный логин или пароль');
    }

    const manager = await response.json();

    localStorage.setItem('manager', JSON.stringify(manager));

    window.location.href = 'dashboard.html';

  } catch (err) {
    errorMsg.textContent = err.message;
    errorMsg.style.color = 'red';
  }
});