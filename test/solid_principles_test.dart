// Pruebas unitarias REALES de lógica de dominio pura (sin Firebase).
//
// Reemplaza el test anterior que solo comparaba literales de string
// (p. ej. `'SolidBovineController'.contains('Bovine')`) y no validaba
// comportamiento alguno (hallazgo I2/TD-09 de la auditoría).
import 'package:flutter_test/flutter_test.dart';
import 'package:bovidata_new/models/bovine_model.dart';
import 'package:bovidata_new/models/inventory_model.dart';
import 'package:bovidata_new/core/services/solid_services.dart';

void main() {
  group('BovineModel — cálculo de edad', () {
    test('edad en años se calcula correctamente', () {
      final nacimiento = DateTime.now().subtract(const Duration(days: 365 * 3 + 10));
      final bovine = BovineModel.empty().copyWith(fechaNacimiento: nacimiento);
      expect(bovine.edad, 3);
    });

    test('edad en meses para animales jóvenes', () {
      final nacimiento = DateTime(DateTime.now().year, DateTime.now().month - 5, 1);
      final bovine = BovineModel.empty().copyWith(fechaNacimiento: nacimiento);
      expect(bovine.edadMeses, greaterThanOrEqualTo(4));
    });
  });

  group('InventoryModel — reglas de negocio de stock', () {
    InventoryModel item({required int actual, required int minimo, double? precio}) {
      return InventoryModel.empty().copyWith(
        cantidadActual: actual,
        cantidadMinima: minimo,
        precioUnitario: precio,
      );
    }

    test('isLowStock es true cuando actual <= mínimo', () {
      expect(item(actual: 5, minimo: 10).isLowStock, isTrue);
      expect(item(actual: 10, minimo: 10).isLowStock, isTrue);
    });

    test('isLowStock es false cuando actual > mínimo', () {
      expect(item(actual: 11, minimo: 10).isLowStock, isFalse);
    });

    test('valorTotal multiplica precio por cantidad', () {
      expect(item(actual: 4, minimo: 1, precio: 2.5).valorTotal, 10.0);
    });

    test('valorTotal es 0 si no hay precio', () {
      expect(item(actual: 4, minimo: 1).valorTotal, 0.0);
    });
  });

  group('ConcreteValidationService — validaciones', () {
    final validator = ConcreteValidationService();

    test('valida emails correctos e incorrectos', () {
      expect(validator.validateEmail('user@example.com'), isTrue);
      expect(validator.validateEmail('no-es-email'), isFalse);
    });

    test('campo requerido detecta vacíos y nulos', () {
      expect(validator.validateRequired('algo'), isTrue);
      expect(validator.validateRequired('   '), isFalse);
      expect(validator.validateRequired(null), isFalse);
    });

    test('validateField aplica reglas en orden', () {
      expect(validator.validateField('', ['required']), 'Este campo es requerido');
      expect(validator.validateField('mal', ['email']), 'Ingrese un email válido');
      expect(validator.validateField('ok@mail.com', ['required', 'email']), isNull);
    });
  });
}
