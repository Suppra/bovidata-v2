class AppConstants {
  // App Information
  static const String appName = 'BoviData';
  static const String appVersion = '2.0.0';
  
  // Roles
  static const String roleGanadero = 'Ganadero';
  static const String roleVeterinario = 'Veterinario';
  static const String roleEmpleado = 'Empleado';
  
  // Collections
  static const String usersCollection = 'users';
  static const String bovinesCollection = 'bovines';
  static const String treatmentsCollection = 'treatments';
  static const String vaccinesCollection = 'vaccines';
  static const String inventoryCollection = 'inventory';
  static const String incidentsCollection = 'incidents';
  static const String complaintsCollection = 'complaints';
  static const String notificationsCollection = 'notifications';
  
  // Bovine Status
  static const String statusSano = 'Sano';
  static const String statusEnfermo = 'Enfermo';
  static const String statusRecuperacion = 'En recuperación';
  static const String statusMuerto = 'Muerto';
  
  // Treatment Types
  static const String treatmentVacuna = 'Vacuna';
  static const String treatmentMedicamento = 'Medicamento';
  static const String treatmentCirugia = 'Cirugía';
  static const String treatmentRevision = 'Revisión';
  
  // Notification Types
  static const String notificationVaccine = 'Vacunación pendiente';
  static const String notificationTreatment = 'Tratamiento pendiente';
  static const String notificationInventory = 'Inventario bajo';
  static const String notificationExpiry = 'Medicamento por vencer';
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Validation
  static const int maxBovineName = 50;
  static const int maxTreatmentDescription = 500;
  static const int maxComplaintDescription = 1000;
  static const int minPasswordLength = 6;
  
  // Default Values
  static const int defaultInventoryMinStock = 10;
  static const int defaultVaccineDaysNotice = 7;
  static const int defaultMedicineExpiryDaysNotice = 30;
}