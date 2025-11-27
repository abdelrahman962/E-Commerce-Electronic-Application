

# 🛒 E-Commerce App (Flutter + Firebase + Stripe + Admin Panel)

A complete e-commerce electronic devices application built with **Flutter** and powered by **Firebase**.
It includes a full shopping experience for users and a dedicated admin panel to manage products and track orders.
Perfect for learning, showcasing, or turning into a real store.

---

## ✨ Features

### 👤 Customer Side

* Smooth and clean modern UI
* Firebase Authentication (signup & login)
* Browse products by category
* Search with debounce for fast results
* Product detail page with images, pricing, and description
* Secure checkout using **Stripe**
* Order history with Firestore

### 🛠️ Admin Panel

* Separate admin login
* Add, edit products
* Categorize products
* Real-time view of all customer orders
* Dashboard showing product and order stats

---

## 🧰 Tech Stack

| Technology       | Used For                     |
| ---------------- | ---------------------------- |
| Flutter          | UI & app development         |
| Firebase Auth    | Authentication               |
| Cloud Firestore  | Products, orders, users data |
| Stripe API       | Secure online payments       |

---

## 📁 Project Structure

```
lib/
├── pages/            → Home, Login, Signup, Category, Product Detail
├── admin/            → Admin Login, Dashboard, Add Product
├── widget/           → Reusable widgets (tiles, buttons, inputs)
├── services/         → Database, Shared Pref, Stripe helpers
└── main.dart         → App entry point + routes
```

---

