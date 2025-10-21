// Service Locator Pattern para inyección de dependencias (implementación simple)
// Implementa Dependency Inversion Principle (DIP)
import '../interfaces/repository_interface.dart';
import '../interfaces/service_interface.dart';
import '../repositories/concrete_repositories.dart';
import '../services/solid_services.dart';
import '../factories/model_factory.dart';
import '../builders/entity_builder.dart';

class ServiceLocator {
  static final Map<Type, dynamic> _services = {};
  static bool _isInitialized = false;

  static void setupDependencies() {
    if (_isInitialized) return;
    
    // Registrar Factory
    _services[ModelFactory] = ConcreteModelFactory();

    // Registrar Repositorios
    _services[IBovineRepository] = BovineRepository(
      modelFactory: _services[ModelFactory] as ModelFactory,
    );

    _services[ITreatmentRepository] = TreatmentRepository(
      modelFactory: _services[ModelFactory] as ModelFactory,
    );

    _services[IInventoryRepository] = InventoryRepository(
      modelFactory: _services[ModelFactory] as ModelFactory,
    );

    _services[IUserRepository] = UserRepository(
      modelFactory: _services[ModelFactory] as ModelFactory,
    );

    // Registrar Servicios
    _services[INotificationService] = ConcreteNotificationService();
    _services[IValidationService] = ConcreteValidationService();

    // Registrar Servicios de Dominio
    _services[SolidBovineService] = SolidBovineService(
      repository: _services[IBovineRepository] as IBovineRepository,
      notificationService: _services[INotificationService] as INotificationService,
      validationService: _services[IValidationService] as IValidationService,
    );

    _services[SolidTreatmentService] = SolidTreatmentService(
      repository: _services[ITreatmentRepository] as ITreatmentRepository,
      bovineRepository: _services[IBovineRepository] as IBovineRepository,
      notificationService: _services[INotificationService] as INotificationService,
      validationService: _services[IValidationService] as IValidationService,
    );

    _services[SolidInventoryService] = SolidInventoryService(
      repository: _services[IInventoryRepository] as IInventoryRepository,
      notificationService: _services[INotificationService] as INotificationService,
      validationService: _services[IValidationService] as IValidationService,
    );

    _isInitialized = true;
  }

  // Método genérico para obtener servicios
  static T get<T>() {
    if (!_isInitialized) setupDependencies();
    
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T is not registered');
    }
    return service as T;
  }

  // Métodos de acceso tipados para mayor seguridad
  static SolidBovineService get bovineService => get<SolidBovineService>();
  static SolidTreatmentService get treatmentService => get<SolidTreatmentService>();
  static SolidInventoryService get inventoryService => get<SolidInventoryService>();
  static IBovineRepository get bovineRepository => get<IBovineRepository>();
  static ITreatmentRepository get treatmentRepository => get<ITreatmentRepository>();
  static IInventoryRepository get inventoryRepository => get<IInventoryRepository>();
  static IUserRepository get userRepository => get<IUserRepository>();
  
  // Métodos para builders (nueva instancia cada vez)
  static BovineBuilder get bovineBuilder => BovineBuilder();
  static TreatmentBuilder get treatmentBuilder => TreatmentBuilder();

  // Método para limpiar servicios (útil para tests)
  static void reset() {
    _services.clear();
    _isInitialized = false;
  }
}
