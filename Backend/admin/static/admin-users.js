const API_URL = "http://localhost:8000/admin/users";

async function loadUsers() {
  try {
    const res = await fetch(API_URL);
    const users = await res.json();

    const usersList = users.filter(u => u.role === "Пользователь");
    const moderatorsList = users.filter(u => u.role === "Модератор");
    const adminsList = users.filter(u => u.role === "Администратор");

    renderTable("usersTable", usersList);
    renderTable("moderatorsTable", moderatorsList);
    renderTable("adminsTable", adminsList);
  } catch (err) {
    console.error("Ошибка загрузки пользователей:", err);
  }
}

function renderTable(tableId, users) {
  const tbody = document.querySelector(`#${tableId} tbody`);
  tbody.innerHTML = "";

  if (!users || users.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center;">Нет данных</td></tr>`;
    return;
  }

  users.forEach(u => {
    const tr = document.createElement("tr");
    const actionBtn =
      u.role === "Администратор"
        ? `<button class="btn disabled" disabled>Нет действий</button>`
        : `<button class="btn delete" onclick="deleteUser('${u.role}', ${u.id})">Удалить</button>`;

    tr.innerHTML = `
      <td>${u.id}</td>
      <td>${u.name}</td>
      <td>${u.email}</td>
      <td>${u.role}</td>
      <td>${actionBtn}</td>
    `;
    tbody.appendChild(tr);
  });
}

async function deleteUser(role, id) {
  if (!confirm(`Удалить ${role.toLowerCase()} с ID ${id}?`)) return;

  try {
    const res = await fetch(`${API_URL}/${role}/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error("Ошибка при удалении");
    loadUsers();
  } catch (err) {
    alert("Не удалось удалить пользователя");
  }
}

loadUsers();