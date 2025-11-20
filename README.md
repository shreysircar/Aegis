Here’s an upgraded version of the **README** with clean GitHub-style badges added at the top. I'll keep them relevant to your tech stack—Flutter, FastAPI, XGBoost, PostgreSQL, and platform status.

You can paste directly into `README.md`.

---

## **📍 Aegis — Predictive Crime Safety Mobile App (Flutter)**

### **Badges**

<p align="left">

<!-- Tech -->

<img src="https://img.shields.io/badge/Flutter-3.32.1-blue?logo=flutter&logoColor=white" />
<img src="https://img.shields.io/badge/Dart-3.8+-blue?logo=dart&logoColor=white" />
<img src="https://img.shields.io/badge/FastAPI-Backend-009688?logo=fastapi&logoColor=white" />
<img src="https://img.shields.io/badge/XGBoost-Model-orange" />
<img src="https://img.shields.io/badge/PostgreSQL-Database-316192?logo=postgresql&logoColor=white" />

<!-- Platform -->

<img src="https://img.shields.io/badge/Android-Supported-green?logo=android" />
<img src="https://img.shields.io/badge/iOS-Supported-lightgrey?logo=apple" />

<!-- Status -->

<img src="https://img.shields.io/badge/Status-Active%20Development-yellow" />
<img src="https://img.shields.io/badge/License-MIT-green" />

</p>

---

### **📌 Overview**

Aegis is a **cross-platform mobile safety application** that uses machine learning to **predict crime risk across Chicago’s 77 communities**, enabling proactive safety awareness rather than reactive reporting.

Unlike existing platforms like **SpotCrime** & **Citizen**, Aegis provides:

* Forward-looking risk prediction
* Community-level granular maps
* Temporal forecasting (year → month → hour)
* Visual heatmaps driven by ML

---

### **🧠 Motivation**

Chicago recorded **2.5M+ crimes (2015–2025)**. Existing safety apps only show past incidents—Aegis bridges this gap by offering **predictive insights powered by real data**, enabling:

* Safer commutes & informed navigation
* Data-driven municipal planning
* Transparent public safety analytics

Uses open data + ML:

* Chicago Open Data Portal
* XGBoost, scikit-learn
* Temporal + spatial engineered features

---

### **📱 Mobile App Features (Flutter)**

| Feature                     | Description                                              |
| --------------------------- | -------------------------------------------------------- |
| **Predictive Heatmap**      | Colored safety visualization (green → safe, red → risky) |
| **Community Search + Tabs** | Crime Map, Search, Routes, Trends                        |
| **Dynamic Time Controls**   | Predict by month, hour, year                             |
| **Custom SVG Rendering**    | 77-community Chicago map                                 |
| **API Fetch + Cache**       | Fast responses with reduced requests                     |

---

### **⚙️ Tech Stack**

#### **Mobile (This Repo)**

* Flutter 3.32.1
* Dart 3.8+
* CustomPainter (map rendering)
* Riverpod (state management)
* HTTP networking package

#### **Backend**

* Python 3.11 + FastAPI
* XGBoost + scikit-learn
* PostgreSQL + bcrypt auth

---

### **📂 Directory Structure**

```
/aegis
 ┣ /lib
 ┣ /assets
 ┣ /backend
     ┗ /src/server.js   <-- Start this first
```

---

### **🚀 Running the App**

#### **1️⃣ Clone**

```sh
git clone https://github.com/<your-org>/aegis.git
cd aegis
```

#### **2️⃣ Start Backend Proxy**

```sh
cd backend/src
node server.js
```

> **This must be running before launching the mobile app.**

#### **3️⃣ Launch App**

```sh
flutter pub get
flutter run
```

Supports:

* Android Emulator
* iOS Simulator
* Physical devices

---

### **🔮 Future Roadmap**

* Block-level GIS safety
* Offline caching + predictive prefetch
* Route safety scoring
* Push alerts based on real-time trends

---

### **📜 License**

MIT · Open Source Research Initiative

---

