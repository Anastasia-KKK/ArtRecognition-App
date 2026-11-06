const API_URL = "http://localhost:8000/admin/add-user";

document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("addUserForm");
  const messageBox = document.getElementById("formMessage");

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const formData = new FormData(form);
    const name = formData.get("name");
    const email = formData.get("email");
    const password = formData.get("password");
    const role = formData.get("role");

    messageBox.textContent = "";
    messageBox.style.color = "";

    try {
      const res = await fetch(API_URL, {
        method: "POST",
        body: new URLSearchParams({ name, email, password, role }),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      });

      const data = await res.json();

      if (!res.ok) throw new Error(data.detail || "Ошибка при добавлении");

      messageBox.textContent = "Пользователь успешно добавлен!";
      messageBox.style.color = "green";
      form.reset();
    } catch (err) {
      console.error(err);
      messageBox.textContent = `${err.message}`;
      messageBox.style.color = "red";
    }
  });
});