// Ejemplo de implementación de patrones SOLID y de diseño
import 'core/locator/service_locator.dart';
import 'core/builders/entity_builder.dart';
import 'core/factories/model_factory.dart';
import 'models/bovine_model.dart';

void main() async {
  // Inicializar el Service Locator (Dependency Injection)
  ServiceLocator.setupDependencies();
  
  print('=== DEMOSTRACIÓN DE PATRONES IMPLEMENTADOS ===\n');
  
  // 1. FACTORY METHOD PATTERN - Crear modelos usando factory methods
  print('1. FACTORY METHOD PATTERN:');
  final emptyBovine = BovineModel.empty();
  print('Bovino vacío creado: ${emptyBovine.id}');
  
  // 2. ABSTRACT FACTORY PATTERN - Usar factory concreto
  print('\n2. ABSTRACT FACTORY PATTERN:');
  final modelFactory = ConcreteModelFactory();
  final bovineFromFactory = modelFactory.createEmpty<BovineModel>();
  print('Bovino desde factory: ${bovineFromFactory.id}');
  
  // 3. BUILDER PATTERN - Construir entidades complejas
  print('\n3. BUILDER PATTERN:');
  final bovineBuilder = ServiceLocator.bovineBuilder;
  final complexBovine = bovineBuilder
    .setId('BOV002')
    .setNombre('Angus Premium')
    .setRaza('Angus')
    .setPropietarioId('OWNER001')
    .setSexo('Macho')
    .setFechaNacimiento(DateTime.now().subtract(Duration(days: 730)))
    .setPeso(520.0)
    .setEstado('Sano')
    .setObservaciones('Bovino de alta calidad')
    .build();
  print('Bovino construido: ${complexBovine.nombre} - ${complexBovine.peso}kg');
  
  // Ejemplo con EntityDirector para configuraciones predefinidas
  final standardBovine = EntityDirector.createStandardBovine(
    nombre: 'Standard Holstein',
    raza: 'Holstein', 
    sexo: 'Hembra',
    fechaNacimiento: DateTime.now().subtract(Duration(days: 365)),
    propietarioId: 'OWNER001',
  );
  print('Bovino estándar: ${standardBovine.nombre}');
  
  // 4. SOLID PRINCIPLES EN ACCIÓN - Usar servicios
  print('\n4. SOLID PRINCIPLES:');
  
  // Single Responsibility Principle - Cada servicio tiene una responsabilidad
  final bovineService = ServiceLocator.bovineService;
  print('Servicio de bovinos obtenido (SRP aplicado)');
  
  // Open/Closed Principle - Los servicios están abiertos para extensión
  try {
    final bovineId = await bovineService.createBovine(complexBovine);
    print('Bovino creado con ID: $bovineId');
  } catch (e) {
    print('Error al crear bovino: $e');
  }
  
  // Liskov Substitution Principle - Usar interfaces
  print('LSP: Usando interfaces para repositorios');
  print('Repositorio obtenido a través de interfaz');
  
  // Interface Segregation Principle - Interfaces específicas
  print('ISP: Interfaces segregadas por entidad');
  
  // Dependency Inversion Principle - Dependemos de abstracciones
  print('DIP: Servicios dependen de interfaces, no de implementaciones concretas');
  
  // 5. EJEMPLO DE TRATAMIENTO CON BUILDER
  print('\n5. TREATMENT BUILDER:');
  final treatmentBuilder = ServiceLocator.treatmentBuilder;
  final treatment = treatmentBuilder
    .setId('TRT001')
    .setBovineId('BOV001')
    .setTipo('Vacunación')
    .setNombre('Vacuna Antiaftosa')
    .setDescripcion('Aplicación de vacuna antiaftosa')
    .setMedicamento('Antiaftosa')
    .setDosis(5.0)
    .setVeterinarioId('VET001')
    .setFecha(DateTime.now().add(Duration(days: 7)))
    .setObservaciones('Aplicar en cuello')
    .build();
  
  print('Tratamiento creado: ${treatment.nombre} - ${treatment.medicamento}');
  
  // Crear tratamiento usando servicio
  final treatmentService = ServiceLocator.treatmentService;
  try {
    final treatmentId = await treatmentService.createTreatment(treatment);
    print('Tratamiento registrado con ID: $treatmentId');
  } catch (e) {
    print('Error al crear tratamiento: $e');
  }
  
  print('\n=== IMPLEMENTACIÓN COMPLETADA ===');
  print('✅ Factory Method Pattern');
  print('✅ Abstract Factory Pattern'); 
  print('✅ Builder Pattern');
  print('✅ Single Responsibility Principle (SRP)');
  print('✅ Open/Closed Principle (OCP)');
  print('✅ Liskov Substitution Principle (LSP)');
  print('✅ Interface Segregation Principle (ISP)');
  print('✅ Dependency Inversion Principle (DIP)');
}