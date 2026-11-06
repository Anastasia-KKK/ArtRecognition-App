const API_BASE = 'http://localhost:8000';

const managerData = localStorage.getItem('manager');
if (!managerData) window.location.href = 'index.html';
const manager = JSON.parse(managerData);
document.getElementById('moderatorName').textContent = manager.full_name || 'Модератор';

document.querySelector('.logout-btn').addEventListener('click', () => {
  localStorage.removeItem('manager');
  window.location.href = 'index.html';
});

const params = new URLSearchParams(window.location.search);
const artworkId = params.get('id');

if (!artworkId) {
  alert('Ошибка: не найден ID картины.');
  window.location.href = 'dashboard.html';
}

const form = document.getElementById('editForm');
const message = document.getElementById('message');

async function loadArtwork() {
  try {
    const res = await fetch(`${API_BASE}/artworks/${artworkId}`);
    if (!res.ok) throw new Error('Ошибка загрузки данных картины');

    const art = await res.json();

    document.getElementById('title').value = art.title || '';
    document.getElementById('title_en').value = art.title_en || '';
    document.getElementById('author_id').value = art.author_id || '';
    document.getElementById('year').value = art.year || '';
    document.getElementById('material').value = art.material || '';
    document.getElementById('material_en').value = art.material_en || '';
    document.getElementById('size').value = art.size || '';
    document.getElementById('size_en').value = art.size_en || '';
    document.getElementById('description').value = art.description || '';
    document.getElementById('description_en').value = art.description_en || '';
    document.getElementById('creation_history').value = art.creation_history || '';
    document.getElementById('creation_history_en').value = art.creation_history_en || '';
    document.getElementById('image').value = art.image || '';

  } catch (err) {
    console.error(err);
    alert('Ошибка при загрузке картины.');
  }
}

loadArtwork();

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
    image: document.getElementById('image').value.trim() || null,
  };

  Object.keys(data).forEach((key) => {
    if (!data[key]) delete data[key];
  });

  try {
    const res = await fetch(`${API_BASE}/artworks/${artworkId}`, {
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