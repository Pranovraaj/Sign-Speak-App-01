# Sign-Speak-App-01

SignSpeak is a comprehensive application designed to provide users with an intuitive interface for sign language translation, practice, and tutorials. It features a Flutter-based mobile frontend, a Java/Spring Boot backend, and a dedicated testing suite.

## Project Structure

This repository is divided into the following main components:

- **[Frontend](./Frontend/)**: A cross-platform mobile application built with Flutter/Dart. It uses a custom Heuristic Engine for local sign language gesture recognition without relying on external cloud AI APIs.
- **[Backend](./Backend/)**: A robust REST API built with Java (Spring Boot) and PostgreSQL, providing authentication, data persistence, and business logic.
- **[Testing](./Testing/)**: A dedicated suite containing automated UI tests, mobile tests, and load testing scripts.

## Core Technologies

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Local AI:** Custom Heuristic Engine with local landmark detection for privacy-preserving translation
- **Other:** Dio, flutter_tts, camera, image_picker

### Backend
- **Framework:** Spring Boot (Java 17)
- **Database:** PostgreSQL (production) & H2 (local/testing)
- **Security:** Spring Security
- **Build Tool:** Maven

## Getting Started

- **Backend:** Navigate to the `Backend/` directory and use Maven: `./mvnw spring-boot:run`.
- **Frontend:** Navigate to the `Frontend/` directory and use Flutter: `flutter run`.
