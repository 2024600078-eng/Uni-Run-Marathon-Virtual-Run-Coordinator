# Uni-Run: Marathon & Virtual Run Coordinator

Uni-Run is a web-based system for managing marathon and virtual run events. The system allows users to view events, register for runs and manage participation details. Admin users can manage event information and view participant registrations.

## Project Module

This repository contains the base project setup for the Uni-Run full system.

## Technologies Used

- Java
- JSP
- Servlet
- MySQL
- Apache Tomcat
- NetBeans IDE
- HTML
- CSS

## Main Features

- Homepage
- Database connection setup
- MySQL database integration
- Event data structure
- User data structure
- Registration data structure
- Result data structure

## Project Structure

```text
UniRunSystem/
├── nbproject/
├── src/
│   └── util/
│       └── DBConnection.java
├── web/
│   ├── css/
│   │   └── style.css
│   ├── WEB-INF/
│   │   └── web.xml
│   ├── index.jsp
│   └── testConnection.jsp
├── build.xml
├── database.sql
└── README.md
```

## Database Setup

1. Open phpMyAdmin.
2. Create a database named:

```sql
unirun_db
```

3. Import the file:

```text
database.sql
```

4. Make sure the following tables are created:

```text
users
events
registrations
results
```

## Database Connection

The database connection file is located at:

```text
src/util/DBConnection.java
```

Default database settings:

```java
URL: jdbc:mysql://localhost:3306/unirun_db
Username: root
Password: 
```

## How to Run the Project

1. Open NetBeans IDE.
2. Open the project folder:

```text
UniRunSystem
```

3. Make sure Apache Tomcat is configured.
4. Make sure MySQL is running in XAMPP.
5. Clean and Build the project.
6. Run the project.

Homepage URL example:

```text
http://localhost:8084/UniRunSystem/
```

Database test page:

```text
http://localhost:8084/UniRunSystem/testConnection.jsp
```

## Group Task Division

- Khairil : Project setup, database, GitHub, integration, homepage, DBConnection
- Nina : Login, register, logout, session handling
- Arif : Event listing, event details, event registration
- Naim : Participant dashboard, registration history, result submission
- Nazim : Admin dashboard, manage events, manage participants, reports

## Current Status

- Project structure created
- Database created
- Tables created
- Database connection tested
- Homepage completed
- Ready for team members to continue module development

## Author

Muhammad Khairil Ilman Bin Ahmad Nazari
````
