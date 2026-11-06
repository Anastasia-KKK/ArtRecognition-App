const API_URL = "http://localhost:8000/admin/recent-artworks";
const API_BASE = "http://localhost:8000/admin";

async function loadDashboardStats() {
  try {
    const res = await fetch(`${API_BASE}/stats`);
    const data = await res.json();

    document.getElementById("usersCount").textContent = data.users;
    document.getElementById("artworksCount").textContent = data.artworks;
    document.getElementById("favoritesCount").textContent = data.favorites;
  } catch (err) {
    console.error("Ошибка загрузки статистики:", err);
  }
}

loadDashboardStats();

async function loadRecentArtworks() {
  try {
    const res = await fetch(API_URL);
    const artworks = await res.json();
    renderRecentArtworks(artworks);
  } catch (err) {
    console.error("Ошибка загрузки картин:", err);
  }
}

function renderRecentArtworks(artworks) {
  const tbody = document.querySelector("#recentArtworksTable tbody");
  tbody.innerHTML = "";

  if (!artworks || artworks.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;">Нет данных</td></tr>`;
    return;
  }

  artworks.forEach(art => {
    const row = document.createElement("tr");
    const imageCell = art.image
      ? `<img src="${art.image}" alt="${art.title}" style="width:60px; height:60px; object-fit:cover; border-radius:6px;">`
      : `<div style="width:60px; height:60px; background:#ddd; border-radius:6px;"></div>`;

    row.innerHTML = `
      <td>${art.id}</td>
      <td>${imageCell}</td>
      <td>${art.title}</td>
      <td>${art.author || "—"}</td>
      <td>${art.year || "—"}</td>
    `;
    tbody.appendChild(row);
  });
}

loadRecentArtworks();