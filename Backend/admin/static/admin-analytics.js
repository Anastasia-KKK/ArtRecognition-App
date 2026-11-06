const API_URL = "http://localhost:8000/admin/analytics";

async function loadAnalytics() {
  try {
    const res = await fetch(API_URL);
    const data = await res.json();

    renderTable("artistsTable", data.artworks_per_author, ["name", "artworks_count"]);
    renderTable("popularArtworksTable", data.popular_artworks, ["title", "author", "count"]);
    renderTable("popularAuthorsTable", data.popular_authors, ["name", "count"]);

  } catch (err) {
    console.error("Ошибка загрузки аналитики:", err);
  }
}

function renderTable(tableId, items, keys) {
  const tbody = document.querySelector(`#${tableId} tbody`);
  tbody.innerHTML = "";

  if (!items || items.length === 0) {
    tbody.innerHTML = `<tr><td colspan="${keys.length + 1}" style="text-align:center; color:#777;">Нет данных</td></tr>`;
    return;
  }

  items.forEach((item, index) => {
    const row = document.createElement("tr");
    row.innerHTML = `<td>${index + 1}</td>` + keys.map(k => `<td>${item[k]}</td>`).join("");
    tbody.appendChild(row);
  });
}

loadAnalytics();