import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import 'notification_service.dart';
import 'user_service.dart';
import 'inventory_service.dart';

class SchedulerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Timer? _dailyTimer;
  static Timer? _hourlyTimer;

  // Initialize scheduled tasks
  static void initializeScheduler() {
    // Run daily checks at 8 AM (or immediately if starting app after 8 AM)
    _scheduleDailyChecks();
    
    // Run hourly checks for urgent items
    _scheduleHourlyChecks();
  }

  // Stop all scheduled tasks
  static void dispose() {
    _dailyTimer?.cancel();
    _hourlyTimer?.cancel();
  }

  // Schedule daily checks
  static void _scheduleDailyChecks() {
    final now = DateTime.now();
    final nextRun = DateTime(now.year, now.month, now.day, 8, 0); // 8 AM
    
    Duration initialDelay;
    if (now.isBefore(nextRun)) {
      initialDelay = nextRun.difference(now);
    } else {
      // If it's already past 8 AM, schedule for tomorrow
      final tomorrow = nextRun.add(const Duration(days: 1));
      initialDelay = tomorrow.difference(now);
    }

    _dailyTimer = Timer.periodic(
      const Duration(days: 1),
      (timer) => _runDailyChecks(),
    );

    // Run initial check after delay
    Timer(initialDelay, () => _runDailyChecks());
  }

  // Schedule hourly checks
  static void _scheduleHourlyChecks() {
    _hourlyTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) => _runHourlyChecks(),
    );
    
    // Run initial check immediately
    _runHourlyChecks();
  }

  // Daily checks for treatments, inventory, and general notifications
  static Future<void> _runDailyChecks() async {
    print('Running daily scheduled checks...');
    
    try {
      await Future.wait([
        _checkUpcomingTreatments(),
        _checkInventoryExpirations(),
        _checkOverdueTreatments(),
      ]);
      
      print('Daily checks completed successfully');
    } catch (e) {
      print('Error in daily checks: $e');
    }
  }

  // Hourly checks for urgent items
  static Future<void> _runHourlyChecks() async {
    print('Running hourly scheduled checks...');
    
    try {
      await Future.wait([
        _checkUrgentTreatments(),
        _checkCriticalInventory(),
      ]);
      
      print('Hourly checks completed successfully');
    } catch (e) {
      print('Error in hourly checks: $e');
    }
  }

  // Check for treatments due soon (next 3 days)
  static Future<void> _checkUpcomingTreatments() async {
    try {
      final now = DateTime.now();
      final threeDaysFromNow = now.add(const Duration(days: 3));
      
      final snapshot = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .where('completado', isEqualTo: false)
          .where('proximaAplicacion', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .where('proximaAplicacion', isLessThanOrEqualTo: Timestamp.fromDate(threeDaysFromNow))
          .get();

      for (final doc in snapshot.docs) {
        final treatmentData = doc.data();
        final proximaAplicacion = (treatmentData['proximaAplicacion'] as Timestamp).toDate();
        final treatmentType = treatmentData['tipo'] ?? '';
        final bovineId = treatmentData['bovineId'] ?? '';
        final veterinarioId = treatmentData['veterinarioId'];
        
        // Get bovine information
        final bovineDoc = await _firestore
            .collection(AppConstants.bovinesCollection)
            .doc(bovineId)
            .get();
        
        final bovineName = bovineDoc.data()?['nombre'] ?? 'Desconocido';
        final ganaderoId = bovineDoc.data()?['propietarioId'];
        
        final daysUntil = proximaAplicacion.difference(now).inDays;
        
        // Notify veterinarian
        if (veterinarioId != null) {
          await NotificationService.notifyUpcomingTreatment(
            treatmentId: doc.id,
            treatmentType: treatmentType,
            bovineName: bovineName,
            scheduledDate: proximaAplicacion,
            userId: veterinarioId,
            daysUntil: daysUntil,
          );
        }
        
        // Notify ganadero
        if (ganaderoId != null && ganaderoId != veterinarioId) {
          await NotificationService.notifyUpcomingTreatment(
            treatmentId: doc.id,
            treatmentType: treatmentType,
            bovineName: bovineName,
            scheduledDate: proximaAplicacion,
            userId: ganaderoId,
            daysUntil: daysUntil,
          );
        }
      }
    } catch (e) {
      print('Error checking upcoming treatments: $e');
    }
  }

  // Check for overdue treatments
  static Future<void> _checkOverdueTreatments() async {
    try {
      final now = DateTime.now();
      
      final snapshot = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .where('completado', isEqualTo: false)
          .where('proximaAplicacion', isLessThan: Timestamp.fromDate(now))
          .get();

      for (final doc in snapshot.docs) {
        final treatmentData = doc.data();
        final proximaAplicacion = (treatmentData['proximaAplicacion'] as Timestamp).toDate();
        final treatmentType = treatmentData['tipo'] ?? '';
        final bovineId = treatmentData['bovineId'] ?? '';
        final veterinarioId = treatmentData['veterinarioId'];
        
        // Get bovine information
        final bovineDoc = await _firestore
            .collection(AppConstants.bovinesCollection)
            .doc(bovineId)
            .get();
        
        final bovineName = bovineDoc.data()?['nombre'] ?? 'Desconocido';
        final ganaderoId = bovineDoc.data()?['propietarioId'];
        
        final daysOverdue = now.difference(proximaAplicacion).inDays;
        
        // Notify veterinarian about overdue treatment
        if (veterinarioId != null) {
          await NotificationService.notifyUpcomingTreatment(
            treatmentId: doc.id,
            treatmentType: treatmentType,
            bovineName: bovineName,
            scheduledDate: proximaAplicacion,
            userId: veterinarioId,
            daysUntil: -daysOverdue, // Negative for overdue
          );
        }
        
        // Notify ganadero
        if (ganaderoId != null && ganaderoId != veterinarioId) {
          await NotificationService.notifyUpcomingTreatment(
            treatmentId: doc.id,
            treatmentType: treatmentType,
            bovineName: bovineName,
            scheduledDate: proximaAplicacion,
            userId: ganaderoId,
            daysUntil: -daysOverdue,
          );
        }
      }
    } catch (e) {
      print('Error checking overdue treatments: $e');
    }
  }

  // Check urgent treatments (due today or overdue)
  static Future<void> _checkUrgentTreatments() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      
      final snapshot = await _firestore
          .collection(AppConstants.treatmentsCollection)
          .where('completado', isEqualTo: false)
          .where('proximaAplicacion', isLessThan: Timestamp.fromDate(tomorrow))
          .get();

      for (final doc in snapshot.docs) {
        final treatmentData = doc.data();
        final proximaAplicacion = (treatmentData['proximaAplicacion'] as Timestamp).toDate();
        final treatmentType = treatmentData['tipo'] ?? '';
        final bovineId = treatmentData['bovineId'] ?? '';
        final veterinarioId = treatmentData['veterinarioId'];
        
        // Get bovine information
        final bovineDoc = await _firestore
            .collection(AppConstants.bovinesCollection)
            .doc(bovineId)
            .get();
        
        final bovineName = bovineDoc.data()?['nombre'] ?? 'Desconocido';
        final ganaderoId = bovineDoc.data()?['propietarioId'];
        
        final daysUntil = proximaAplicacion.difference(today).inDays;
        
        // Only notify for urgent cases (today or overdue)
        if (daysUntil <= 0) {
          if (veterinarioId != null) {
            await NotificationService.notifyUpcomingTreatment(
              treatmentId: doc.id,
              treatmentType: treatmentType,
              bovineName: bovineName,
              scheduledDate: proximaAplicacion,
              userId: veterinarioId,
              daysUntil: daysUntil,
            );
          }
          
          if (ganaderoId != null && ganaderoId != veterinarioId) {
            await NotificationService.notifyUpcomingTreatment(
              treatmentId: doc.id,
              treatmentType: treatmentType,
              bovineName: bovineName,
              scheduledDate: proximaAplicacion,
              userId: ganaderoId,
              daysUntil: daysUntil,
            );
          }
        }
      }
    } catch (e) {
      print('Error checking urgent treatments: $e');
    }
  }

  // Check for inventory items expiring soon
  static Future<void> _checkInventoryExpirations() async {
    try {
      await InventoryService.checkInventoryNotifications();
    } catch (e) {
      print('Error checking inventory expirations: $e');
    }
  }

  // Check critical inventory (out of stock or expired)
  static Future<void> _checkCriticalInventory() async {
    try {
      final now = DateTime.now();
      
      final snapshot = await _firestore
          .collection(AppConstants.inventoryCollection)
          .where('activo', isEqualTo: true)
          .get();

      final notificationUsers = await UserService.getInventoryNotificationUsers();
      
      for (final doc in snapshot.docs) {
        final itemData = doc.data();
        final cantidadActual = itemData['cantidadActual'] ?? 0;
        final fechaVencimiento = itemData['fechaVencimiento'];
        final nombre = itemData['nombre'] ?? 'Producto';
        final unidad = itemData['unidad'] ?? 'unidad';
        
        // Check for out of stock
        if (cantidadActual == 0) {
          for (final userId in notificationUsers) {
            await NotificationService.notifyLowInventory(
              itemId: doc.id,
              itemName: nombre,
              currentQuantity: cantidadActual,
              unit: unidad,
              userId: userId,
            );
          }
        }
        
        // Check for expired items
        if (fechaVencimiento != null) {
          final expirationDate = (fechaVencimiento as Timestamp).toDate();
          final daysUntilExpiry = expirationDate.difference(now).inDays;
          
          if (daysUntilExpiry <= 0) { // Expired
            await NotificationService.notifyInventoryExpiring(
              itemId: doc.id,
              itemName: nombre,
              expirationDate: expirationDate,
              daysUntilExpiry: daysUntilExpiry,
              notifyUsers: notificationUsers,
            );
          }
        }
      }
    } catch (e) {
      print('Error checking critical inventory: $e');
    }
  }

  // Manual trigger for all checks (useful for testing or immediate execution)
  static Future<void> runAllChecksNow() async {
    print('Running all checks manually...');
    
    try {
      await Future.wait([
        _runDailyChecks(),
        _runHourlyChecks(),
      ]);
      
      print('Manual checks completed successfully');
    } catch (e) {
      print('Error in manual checks: $e');
    }
  }
}