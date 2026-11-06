const API_BASE = 'http://localhost:8000';

const managerData = localStorage.getItem('manager');
if (!managerData) {
  window.location.href = 'index.html';
}
const manager = JSON.parse(managerData);
document.getElementById('moderatorName').textContent = manager.full_name || 'Модератор';

document.querySelector('.logout-btn').addEventListener('click', () => {
  localStorage.removeItem('manager');
  window.location.href = 'index.html';
});

const form = document.getElementById('uploadForm');
const message = document.getElementById('message');

form.addEventListener('submit', async (e) => {
  e.preventDefault();

  const data = {
    title: document.getElementById('title').value.trim(),
    title_en: document.getElementById('title_en').value.trim() || null,
    author_id: document.getElementById('author_id').value || null,
    year: document.getElementById('year').value.trim() || null,
    material: document.getElementById('material').value.trim() || null,
    material_en: document.getElementById('material_en').value.trim() || null,
    size: document.getElementById('size').value.trim() || null,
    size_en: document.getElementById('size_en').value.trim() || null,
    description: document.getElementById('description').value.trim() || null,
    description_en: document.getElementById('description_en').value.trim() || null,
    creation_history: document.getElementById('creation_history').value.trim() || null,
    creation_history_en: document.getElementById('creation_history_en').value.trim() || null,
    image: document.getElementById('image').value.trim(),
  };

  // удаляем пустые поля
  Object.keys(data).forEach((key) => {
    if (!data[key]) delete data[key];
  });

  try {
    const res = await fetch(`${API_BASE}/artworks`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    if (!res.ok) throw new Error('Ошибка при добавлении картины');

    const result = await res.json();
    message.textContent = `${result.message || 'Картина добавлена успешно!'}`;
    message.style.color = 'green';

    form.reset();
    setTimeout(() => (window.location.href = 'dashboard.html'), 1500);
  } catch (err) {
    message.textContent = err.message;
    message.style.color = 'red';
  }
});