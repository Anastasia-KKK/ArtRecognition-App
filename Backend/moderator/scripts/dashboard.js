
const managerData = localStorage.getItem('manager');

if (!managerData) {
  window.location.href = 'index.html';
}

const manager = JSON.parse(managerData);


document.addEventListener('DOMContentLoaded', () => {
  const nameEl = document.querySelector('.moderator-info p');
  if (nameEl) nameEl.textContent = manager.full_name || 'Модератор';
});


const buttons = document.querySelectorAll('.side-btn[data-section]');
const sections = document.querySelectorAll('.section');

buttons.forEach((btn) => {
  btn.addEventListener('click', () => {

    buttons.forEach((b) => b.classList.remove('active'));
    sections.forEach((s) => s.classList.remove('active'));

    btn.classList.add('active');
    const sectionId = btn.getAttribute('data-section');
    document.getElementById(sectionId).classList.add('active');
  });
});


document.querySelector('.logout-btn').addEventListener('click', () => {
  localStorage.removeItem('manager');
  window.location.href = 'index.html';
});


const API_BASE = 'http://localhost:8000';

async function fetchData(url) {
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error('Ошибка загрузки данных');
    return await res.json();
  } catch (err) {
    console.error(err);
    return [];
  }
}


async function loadArtworks() {
  const artworks = await fetchData(`${API_BASE}/artworks`);
  const list = document.getElementById('artworksList');
  list.innerHTML = '';

  artworks.forEach((art) => {
    const card = document.createElement('div');
    card.className = 'card';
    card.innerHTML = `
      <img src="${art.image ? `${API_BASE}/${art.image}` : ''}" alt="${art.title || ''}">
      <h3>${art.title || 'Без названия'}</h3>
      <p>${art.year || ''}</p>
      <div class="actions">
        <a href="edit-artwork.html?id=${art.id}" class="action-btn edit">Редактировать</a>
        <button class="action-btn delete-artwork" data-id="${art.id}">Удалить</button>
      </div>
    `;
    list.appendChild(card);
  });

  
  list.querySelectorAll('.delete-artwork').forEach((btn) => {
    btn.addEventListener('click', () => deleteArtwork(btn.dataset.id));
  });
}



async function loadAuthors() {
  const authors = await fetchData(`${API_BASE}/authors`);
  const list = document.getElementById('authorsList');
  list.innerHTML = '';

  authors.forEach((a) => {
    const card = document.createElement('div');
    card.className = 'card';
    card.innerHTML = `
      <img src="${a.portrait_url || ''}" alt="${a.name || ''}">
      <h3>${a.name}</h3>
      <div class="actions">
        <a href="edit-author.html?id=${a.id}" class="action-btn edit">Редактировать</a>
        <button class="action-btn delete-author" data-id="${a.id}">Удалить</button>
      </div>
    `;
    list.appendChild(card);
  });

  list.querySelectorAll('.delete-author').forEach((btn) => {
    btn.addEventListener('click', () => deleteAuthor(btn.dataset.id));
  });
}

document.addEventListener('DOMContentLoaded', async () => {
  await loadArtworks();
  await loadAuthors();
});


async function deleteArtwork(id) {
  if (!confirm("Удалить эту картину?")) return;
  const res = await fetch(`${API_BASE}/artworks/${id}`, { method: "DELETE" });
  if (!res.ok) return alert("Ошибка при удалении картины");
  await loadArtworks();
}

async function deleteAuthor(id) {
  if (!confirm("Удалить этого автора?")) return;
  const res = await fetch(`${API_BASE}/authors/${id}`, { method: "DELETE" });
  if (!res.ok) return alert("Ошибка при удалении автора");
  await loadAuthors();
}

