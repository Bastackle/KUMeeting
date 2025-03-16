# KUMeeting - University Meeting Room Reservation System

![Image](https://github.com/user-attachments/assets/5a12fb12-8268-48cf-a37d-15daa2019743)

As a part of 01418342-65 Mobile Application Design and Development at the Computer Science department of Kasetsart University Sriracha Campus

This project is a mobile application designed for university community to easily reserve meeting rooms within the campus. The app allows users to browse available meeting rooms, check the schedule, and make reservations directly from their mobile devices. Built with Flutter for the front-end, Firebase for backend functionality and data management, ensuring seamless user experience and real-time updates.

## Features

* **User Authentication (Email-based Login):** Users can log in using their organization-provided email addresses. **Registration is not available**, ensuring only university community can access the app with their institutional email accounts.
* **User Role Management:** The system categorizes users into different roles based on their status, such as students and staff. Each role has a different maximum booking duration, ensuring fair usage of meeting rooms.
* **Meeting Room Reservation:** Users can browse available meeting rooms, view details, and make reservations based on time and room availability.
* **Real-time Availability:** The app displays real-time availability of meeting rooms, ensuring that users can book rooms without conflicts.
* **Search and Filters:** Users can search and filter meeting rooms by location or capacity to find the best option for their needs.
* **Reservation Management:** Users can view, edit, or cancel their reservations easily through their reservation history.
* **User Profile Management:** Users can update their personal information, including their contact details, within their profile settings.
* **Room Details:** Users can view detailed information about each meeting room, including equipment, capacity, and the building's location on campus.
* **Reservation History:** Users can view their past reservations and track upcoming bookings for better planning.

## Screenshots

| ![Screenshot 1](screenshot/1.home) | ![Screenshot 2]() | ![Screenshot 3]() | ![Screenshot 4]() |
|----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|

## Technologies Used
#### Frontend
* Framework/Library: Flutter
#### Backend & Database
* Firebase Firestore: Cloud-based NoSQL database for managing reservations and user data.
* Firebase Authentication: Secure user authentication and authorization.
#### Other API
* Google Maps API: Displays building of meeting room locations within the university for easy navigation.
