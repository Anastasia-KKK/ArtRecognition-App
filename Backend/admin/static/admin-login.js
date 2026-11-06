const API_URL = "http://localhost:8000/admin/login";

document.addEventListener("DOMContentLoaded", () => {
  const form = document.querySelector(".login-form");

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const email = document.getElementById("login").value.trim();
    const password = document.getElementById("password").value.trim();

    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({ email, password }),
      });

      const data = await res.json();

      if (!res.ok) {
        alert(data.detail || "Ошибка входа");
        return;
      }

      localStorage.setItem("admin_role", data.role);
      localStorage.setItem("admin_name", data.name);

      window.location.href = "admin-dashboard.html";

    } catch (err) {
      console.error(err);
      alert("Ошибка соединения с сервером");
    }
  });
});