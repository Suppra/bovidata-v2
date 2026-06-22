// Inyección de dependencias con get_it (reemplaza el ServiceLocator estático).
//
// Registra el grafo de dependencias por capas: factory de modelos →
// repositorios (puertos) → servicios de dominio → casos de uso. Las
// dependencias se resuelven por constructor, lo que las hace mockeables.
import 'package:get_it/get_it.dart';

import 'package:bovidata_new/core/interfaces/service_interface.dart';
import 'package:bovidata_new/core/services/solid_services.dart';
import 'package:bovidata_new/features/users/domain/ports/user_repository.dart';
import 'package:bovidata_new/features/users/infrastructure/repositories/user_repository_impl.dart';
import 'package:bovidata_new/core/factories/model_factory.dart';
import 'package:bovidata_new/core/access/farm_access_service.dart';
import 'package:bovidata_new/features/animals/domain/ports/bovine_repository.dart';
import 'package:bovidata_new/features/animals/infrastructure/repositories/bovine_repository_impl.dart';
import 'package:bovidata_new/features/animals/application/bovine_service.dart';
import 'package:bovidata_new/features/treatments/domain/ports/treatment_repository.dart';
import 'package:bovidata_new/features/treatments/infrastructure/repositories/treatment_repository_impl.dart';
import 'package:bovidata_new/features/treatments/application/treatment_service.dart';
import 'package:bovidata_new/features/inventory/domain/ports/inventory_repository.dart';
import 'package:bovidata_new/features/inventory/infrastructure/repositories/inventory_repository_impl.dart';
import 'package:bovidata_new/features/inventory/application/inventory_service.dart';
import 'package:bovidata_new/features/notifications/infrastructure/solid_notification_service.dart';
import 'package:bovidata_new/features/membership/domain/ports/membership_repository.dart';
import 'package:bovidata_new/features/membership/infrastructure/repositories/membership_repository_impl.dart';
import 'package:bovidata_new/features/membership/application/membership_interactor.dart';

/// Contenedor global de dependencias.
final GetIt getIt = GetIt.instance;

/// Configura el grafo de dependencias. Idempotente.
void configureDependencies() {
  if (getIt.isRegistered<ModelFactory>()) return;

  // Factory de modelos
  getIt.registerLazySingleton<ModelFactory>(() => ConcreteModelFactory());

  // Repositorios (puertos -> implementaciones)
  getIt.registerLazySingleton<IBovineRepository>(
      () => BovineRepository(modelFactory: getIt<ModelFactory>()));
  getIt.registerLazySingleton<ITreatmentRepository>(
      () => TreatmentRepository(modelFactory: getIt<ModelFactory>()));
  getIt.registerLazySingleton<IInventoryRepository>(
      () => InventoryRepository(modelFactory: getIt<ModelFactory>()));
  getIt.registerLazySingleton<IUserRepository>(
      () => UserRepository(modelFactory: getIt<ModelFactory>()));
  getIt.registerLazySingleton<MembershipRepository>(
      () => MembershipRepositoryImpl());

  // Servicios transversales
  getIt.registerLazySingleton<FarmAccessService>(() =>
      FarmAccessService(membershipRepository: getIt<MembershipRepository>()));
  getIt.registerLazySingleton<INotificationService>(
      () => ConcreteNotificationService());
  getIt.registerLazySingleton<IValidationService>(
      () => ConcreteValidationService());
  getIt.registerLazySingleton<SolidNotificationService>(
      () => SolidNotificationService());

  // Servicios de dominio (aplicación)
  getIt.registerLazySingleton<SolidBovineService>(() => SolidBovineService(
        repository: getIt<IBovineRepository>(),
        notificationService: getIt<INotificationService>(),
        validationService: getIt<IValidationService>(),
        farmAccess: getIt<FarmAccessService>(),
      ));
  getIt.registerLazySingleton<SolidTreatmentService>(() => SolidTreatmentService(
        repository: getIt<ITreatmentRepository>(),
        bovineRepository: getIt<IBovineRepository>(),
        notificationService: getIt<INotificationService>(),
        validationService: getIt<IValidationService>(),
        farmAccess: getIt<FarmAccessService>(),
      ));
  getIt.registerLazySingleton<SolidInventoryService>(() => SolidInventoryService(
        repository: getIt<IInventoryRepository>(),
        notificationService: getIt<INotificationService>(),
        validationService: getIt<IValidationService>(),
        farmAccess: getIt<FarmAccessService>(),
      ));

  // Casos de uso
  getIt.registerLazySingleton<MembershipInteractor>(() => MembershipInteractor(
        membershipRepository: getIt<MembershipRepository>(),
        userRepository: getIt<IUserRepository>(),
        notificationService: getIt<SolidNotificationService>(),
      ));
}

/// Limpia el contenedor (útil para tests).
Future<void> resetDependencies() => getIt.reset();
