import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/services/notification_service.dart';
import 'lib/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
    
    // Test notification creation
    await testNotificationSystem();
    
  } catch (e) {
    print('✗ Error initializing Firebase: $e');
  }
}

Future<void> testNotificationSystem() async {
  print('\n--- Testing Notification System ---');
  
  try {
    // Test 1: Test treatment notification
    print('\n1. Testing Treatment Notification...');
    
    await NotificationService.notifyTreatmentAdded(
      bovineId: 'test_bovino_001',
      bovineName: 'Toro Test 001',
      treatmentType: 'Vacunación',
      veterinarioNombre: 'Dr. Test Veterinario',
      ganaderoId: 'ganadero_test_001',
    );
    print('✓ Treatment notification sent successfully');
    
    // Test 2: Test bovine health change notification
    print('\n2. Testing Bovine Health Change Notification...');
    
    await NotificationService.notifyBovineHealthChange(
      bovineId: 'test_bovino_001',
      bovineName: 'Toro Test 001',
      newStatus: 'enfermo',
      userId: 'ganadero_test_001',
      veterinarioNombre: 'Dr. Test Veterinario',
    );
    print('✓ Bovine health change notification sent successfully');
    
    // Test 3: Test system notification
    print('\n3. Testing System Notification...');
    
    await NotificationService.notifySystemMaintenance(
      title: 'Mantenimiento Programado',
      message: 'Sistema de notificaciones funcionando correctamente',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      notifyUsers: ['ganadero_test_001'],
    );
    print('✓ System notification sent successfully');
    
    // Test 4: Test role change notification
    print('\n4. Testing Role Change Notification...');
    
    await NotificationService.notifyRoleChange(
      userId: 'user_test_001',
      newRole: 'veterinario',
      oldRole: 'empleado',
      changedBy: 'Administrador Test',
    );
    print('✓ Role change notification sent successfully');
    
    print('\n--- Notification System Tests Completed Successfully ---');
    print('Check the Firebase console to verify notifications were created.');
    
  } catch (e) {
    print('✗ Error testing notifications: $e');
  }
}