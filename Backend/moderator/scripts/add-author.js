const API_BASE = 'http://localhost:8000';

const managerData = localStorage.getItem('manager');
if (!managerData) window.location.href = 'index.html';
const manager = JSON.parse(managerData);
document.getElementById('moderatorName').textContent = manager.full_name || 'Модератор';

document.querySelector('.logout-btn').addEventListener('click', () => {
  localStorage.removeItem('manager');
  window.location.href = 'index.html';
});

const form = document.getElementById('authorForm');
const message = document.getElementById('message');

form.addEventListener('submit', async (e) => {
  e.preventDefault();

  const data = {
    name: document.getElementById('name').value.trim(),
    name_en: document.getElementById('name_en').value.trim() || null,
    years_of_life: document.getElementById('years_of_life').value.trim() || null,
    biography: [document.getElementById('biography').value.trim()].filter(Boolean),
    biography_en: [document.getElementById('biography_en').value.trim()].filter(Boolean),
    interesting_facts: [
      document.getElementById('fact1').value.trim(),
      document.getElementById('fact2').value.trim(),
      document.getElementById('fact3').value.trim()
    ].filter(Boolean),
    interesting_facts_en: [
      document.getElementById('fact1_en').value.trim(),
      document.getElementById('fact2_en').value.trim(),
      document.getElementById('fact3_en').value.trim()
    ].filter(Boolean),
    portrait_url: document.getElementById('portrait_url').value.trim(),
  };

  Object.keys(data).forEach((key) => {
    if (!data[key] || (Array.isArray(data[key]) && data[key].length === 0)) delete data[key];
  });

  try {
    const res = await fetch(`${API_BASE}/authors`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    if (!res.ok) throw new Error('Ошибка при добавлении автора');

    message.textContent = 'Автор успешно добавлен!';
    message.style.color = 'green';
    form.reset();

    setTimeout(() => (window.location.href = 'dashboard.html'), 1500);
  } catch (err) {
    message.textContent = err.message;
    message.style.color = 'red';
  }
});