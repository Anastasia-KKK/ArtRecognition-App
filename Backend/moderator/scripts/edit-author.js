const API_BASE = 'http://localhost:8000';

// === Проверка авторизации ===
const managerData = localStorage.getItem('manager');
if (!managerData) window.location.href = 'index.html';
const manager = JSON.parse(managerData);
document.getElementById('moderatorName').textContent = manager.full_name || 'Модератор';

// === Логаут ===
document.querySelector('.logout-btn').addEventListener('click', () => {
  localStorage.removeItem('manager');
  window.location.href = 'index.html';
});

// === Получаем ID автора из URL ===
const params = new URLSearchParams(window.location.search);
const authorId = params.get('id');

if (!authorId) {
  alert('Ошибка: не найден ID автора.');
  window.location.href = 'dashboard.html';
}

const form = document.getElementById('editAuthorForm');
const message = document.getElementById('message');

// === Подгрузка данных автора ===
async function loadAuthor() {
  try {
    const res = await fetch(`${API_BASE}/authors/${authorId}`);
    if (!res.ok) throw new Error('Ошибка загрузки данных автора');

    const author = await res.json();

    document.getElementById('name').value = author.name || '';
    document.getElementById('name_en').value = author.name_en || '';
    document.getElementById('years_of_life').value = author.years_of_life || '';

    document.getElementById('biography').value = author.biography?.join('\n') || '';
    document.getElementById('biography_en').value = author.biography_en?.join('\n') || '';

    // 3 факта (RU)
    const facts = author.interesting_facts || [];
    document.getElementById('fact1').value = facts[0] || '';
    document.getElementById('fact2').value = facts[1] || '';
    document.getElementById('fact3').value = facts[2] || '';

    // 3 факта (EN)
    const factsEn = author.interesting_facts_en || [];
    document.getElementById('fact1_en').value = factsEn[0] || '';
    document.getElementById('fact2_en').value = factsEn[1] || '';
    document.getElementById('fact3_en').value = factsEn[2] || '';

    document.getElementById('portrait_url').value = author.portrait_url || '';

  } catch (err) {
    console.error(err);
    alert('Ошибка при загрузке автора.');
  }
}

loadAuthor();

// === Отправка изменений ===
form.addEventListener('submit', async (e) => {
  e.preventDefault();

  const data = {
    name: document.getElementById('name').value.trim(),
    name_en: document.getElementById('name_en').value.trim() || null,
    years_of_life: document.getElementById('years_of_life').value.trim() || null,
    biography: document.getElementById('biography').value.split('\n').filter(Boolean),
    biography_en: document.getElementById('biography_en').value.split('\n').filter(Boolean),
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
    portrait_url: document.getElementById('portrait_url').value.trim() || null,
  };

  Object.keys(data).forEach((key) => {
    if (!data[key] || (Array.isArray(data[key]) && data[key].length === 0)) delete data[key];
  });

  try {
    const res = await fetch(`${API_BASE}/authors/${authorId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    if (!res.ok) throw new Error('Ошибка при сохранении изменений');

    message.textContent = 'Изменения успешно сохранены!';
    message.style.color = 'green';

    setTimeout(() => (window.location.href = 'dashboard.html'), 1500);
  } catch (err) {
    message.textContent = err.message;
    message.style.color = 'red';
  }
});