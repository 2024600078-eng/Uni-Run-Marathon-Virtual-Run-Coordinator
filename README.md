# Uni-Run: Marathon & Virtual Run Coordinator

**CSC584 Enterprise Programming — Group Project**
CDCS240 Bachelor of Information Technology (Hons.)

| | |
|---|---|
| **Group** | NBCS2404A |
| **Prepared for** | Mr. Muhammad Ridhwan Mohamad Razali |
| **Submission date** | 31 July 2026 |

---

## 📁 Project submission

Everything for this submission is inside one folder:

### ➡️ **[CSC584-Uni-Run](CSC584-Uni-Run)**

| Item | Location |
|---|---|
| **Source code** | [`CSC584-Uni-Run/src`](CSC584-Uni-Run/src) and [`CSC584-Uni-Run/web`](CSC584-Uni-Run/web) |
| **Database** | [`CSC584-Uni-Run/unirun_db.sql`](CSC584-Uni-Run/unirun_db.sql) |
| **User manual** | [`CSC584-Uni-Run/User Manual`](CSC584-Uni-Run/User%20Manual) |
| **Setup and features** | [`CSC584-Uni-Run/README.md`](CSC584-Uni-Run/README.md) |
| **Database design** | [`CSC584-Uni-Run/DATABASE.md`](CSC584-Uni-Run/DATABASE.md) |
| **Interface storyboard** | [`CSC584-Uni-Run/Storyboard`](CSC584-Uni-Run/Storyboard) |

---

## About the system

Uni-Run is a web based system for managing marathon and virtual run events at
the university. Participants browse events, register online, submit their race
results with a proof image, follow the approval status, and download a finisher
certificate once a result is approved. Administrators manage the event
catalogue, review submitted results, oversee participant accounts and export
reports.

It is built with Java Servlets and JSP on Apache Tomcat with a MySQL database,
and follows the **Model View Controller** architecture:

| Layer | Package |
|---|---|
| **Model** | `model` (entity classes) and `dao` (data access objects) |
| **View** | `web` (JSP pages) |
| **Controller** | `controller` (servlets) |

Full setup instructions, demo accounts and feature documentation are in the
[project README](CSC584-Uni-Run/README.md).

---

## Group members

| No. | Name | Student ID |
|---|---|---|
| 1 | Muhammad Khairil Ilman Bin Ahmad Nazari | 2024600078 |
| 2 | Nor Amalina Binti Kamarulzaman | 2024635168 |
| 3 | Muhamad Nazhiim Bin Azman | 202419638 |
| 4 | Arif Sahlan Bin Khairul Anuar | 2025232882 |
| 5 | Muhammad Naim Bin Zahidi | 2024877316 |
