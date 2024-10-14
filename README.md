# StoreLink Web App

### A web platform for connecting storage finders and lenders

This project is a prototype built using **Flutter** and **Firebase** as part of the "Innovation in Science and Engineering: Entrepreneurship" class group project. The platform helps users find available storage spaces based on their needs and allows individuals to lend out their unused storage space.

## Features

- **User Authentication**: Simple email-password authentication using Firebase.
- **Storage Finder**: Users can input their zip code, number of storage boxes, and date range to find suitable storage options.
- **Storage Lender**: Users can upload storage space information, including dimensions, pricing, and availability, as well as photos of the space.
- **Real-Time Data**: Storage listings are stored and retrieved from Firebase Firestore in real-time.
- **Responsive Design**: The app is built with responsive web design in mind, ensuring a smooth user experience across different devices.

## Technologies Used

- **Frontend**: Flutter Web
- **Backend**: Firebase Firestore for database, Firebase Authentication for user login, and Firebase Storage for image hosting
- **State Management**: Flutter's built-in state management with `setState`

## Getting Started

### Prerequisites

- Flutter SDK installed (Flutter 2.0 or later)
- A Firebase project set up with Firestore, Authentication, and Storage enabled

### Setup Instructions

1. **Clone the Repository**:

   ```sh
   git clone https://github.com/your-username/storelink.git
   ```

2. **Navigate to the Project Directory**:

   ```sh
   cd storelink
   ```

3. **Install Dependencies**:

   Run the following command to install the necessary Flutter packages:

   ```sh
   flutter pub get
   ```

4. **Configure Firebase**:

   - Create a new Firebase project on the [Firebase Console](https://console.firebase.google.com/).
   - Add your Firebase project’s configuration file (`google-services.json` for Android and `firebase-config.js` for the web) to your Flutter project.
   - Update your Firebase settings in the `lib/firebase_options.dart` file or generate the configuration via the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

5. **Run the App**:

   ```sh
   flutter run -d chrome
   ```

6. **Build for Web**:

   To build the web version for deployment:

   ```sh
   flutter build web
   ```

   The compiled files will be in the `build/web/` directory.

## Contributing

Contributions are welcome! If you'd like to improve the app or add new features, feel free to submit a pull request or open an issue.

1. Fork the repo
2. Create your feature branch: `git checkout -b feature/YourFeature`
3. Commit your changes: `git commit -m 'Add Your Feature'`
4. Push to the branch: `git push origin feature/YourFeature`
5. Open a pull request
