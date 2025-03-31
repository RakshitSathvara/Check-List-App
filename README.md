# VGPL Factory Checklist App

A Flutter-based factory process checklist application for Vishakha Glass Pvt. Ltd. (VGPL) that works on Android phones and tablets with role-based authentication.

## Features

- Role-based login system with DarwinBox ID integration
- Different interfaces and permissions for Shift Incharges, HODs, and Plant Head
- Responsive UI for both Android phones and tablets
- Task management for Rolling Machine operations and maintenance
- Toggle between Operational and Maintenance tabs
- Task status tracking with time remaining indicators
- Toggle between Due Tasks and Completed Tasks
- Visual indicators for task completion status
- Notification system for overdue tasks

## User Roles

The application supports three user roles with different permissions:

1. **Shift Incharge**
   - Can view tasks specific to their department
   - Can mark tasks as completed
   - Limited to task execution and reporting

2. **HOD (Head of Department)**
   - Can view all tasks in their department
   - Can monitor task completion status
   - Receives alerts for overdue tasks
   - Can access department-specific analytics

3. **Plant Head**
   - Can view tasks across all departments
   - Has access to comprehensive analytics and reports
   - Can monitor overall factory efficiency

## Demo Credentials

For testing purposes, you can use the following credentials:

- **Shift Incharge**: Username: `incharge1`, Password: `password`
- **HOD**: Username: `hod1`, Password: `password`
- **Plant Head**: Username: `planthead`, Password: `password`

## Screenshots

The app design includes multiple screens:
- Login screen with DarwinBox ID authentication
- Process-specific dashboards with task lists
- Role-based navigation drawer with different options
- Task management interfaces with status indicators
- Notification and alert systems for task monitoring

## Project Structure

The project follows a structured organization:

```
lib/
├── main.dart              # Entry point for the application
├── models/
│   ├── task.dart          # Data model for tasks
│   ├── user.dart          # User model with roles and authentication
│   └── dummy_data.dart    # Dummy data for operational and maintenance tasks
├── screens/
│   ├── login_screen.dart  # DarwinBox login interface
│   └── home_screen.dart   # Main screen with tab navigation
└── widgets/
    ├── task_tab_view.dart      # Tab content view
    ├── task_item.dart          # Individual task item
    └── task_category_header.dart # Header for task categories
```

## Installation and Setup

1. Ensure you have Flutter installed (version 2.17.0 or higher)
2. Clone this repository
3. Navigate to the project directory
4. Run `flutter pub get` to install dependencies
5. Connect an Android device or start an emulator
6. Run `flutter run` to start the app

## Responsive Design

The app is designed to be responsive across different screen sizes:
- Adaptive layouts that work on both phones and tablets
- Properly sized UI elements for different screen densities
- Consistent user experience across devices

## Data Structure

The app currently uses dummy data based on the provided reference. In a production environment, this would be replaced with data from the XLSX files and potentially a backend API, with proper authentication integrated with DarwinBox.

## Role-Based Access Control

- **Task Updates**: Only Shift Incharges can mark tasks as completed
- **Alerts**: Only HODs and Plant Head receive alerts for overdue tasks
- **Analytics**: Only Plant Head has access to comprehensive analytics
- **Department Switching**: Plant Head can view data from all departments

## Future Enhancements

Potential enhancements for future versions:
- Integration with actual data sources
- Real DarwinBox authentication integration
- Implementation of email alerts for overdue tasks
- Data persistence with local or cloud storage
- Task history tracking and reporting features
- Advanced analytics for process optimization
