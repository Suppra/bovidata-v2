// Factory Method Pattern - Creación de modelos
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bovine_model.dart';
import '../../models/treatment_model.dart';
import '../../models/inventory_model.dart';
import '../../models/user_model.dart';

// Abstract Factory para modelos
abstract class ModelFactory {
  T createFromFirestore<T>(DocumentSnapshot doc);
  T createEmpty<T>();
  T createFromMap<T>(Map<String, dynamic> data, String id);
}

// Factory concreto para diferentes tipos de modelos
class ConcreteModelFactory implements ModelFactory {
  @override
  T createFromFirestore<T>(DocumentSnapshot doc) {
    switch (T) {
      case BovineModel:
        return BovineModel.fromFirestore(doc) as T;
      case TreatmentModel:
        return TreatmentModel.fromFirestore(doc) as T;
      case InventoryModel:
        return InventoryModel.fromFirestore(doc) as T;
      case UserModel:
        return UserModel.fromFirestore(doc) as T;
      default:
        throw UnsupportedError('Tipo de modelo no soportado: $T');
    }
  }

  @override
  T createEmpty<T>() {
    switch (T) {
      case BovineModel:
        return BovineModel.empty() as T;
      case TreatmentModel:
        return TreatmentModel.empty() as T;
      case InventoryModel:
        return InventoryModel.empty() as T;
      case UserModel:
        return UserModel.empty() as T;
      default:
        throw UnsupportedError('Tipo de modelo no soportado: $T');
    }
  }

  @override
  T createFromMap<T>(Map<String, dynamic> data, String id) {
    switch (T) {
      case BovineModel:
        return BovineModel.fromMap(data, id) as T;
      case TreatmentModel:
        return TreatmentModel.fromMap(data, id) as T;
      case InventoryModel:
        return InventoryModel.fromMap(data, id) as T;
      case UserModel:
        return UserModel.fromMap(data, id) as T;
      default:
        throw UnsupportedError('Tipo de modelo no soportado: $T');
    }
  }
}

// Factory específico para cada modelo (Factory Method Pattern)
abstract class BovineFactory {
  BovineModel createBovine();
}

class StandardBovineFactory extends BovineFactory {
  @override
  BovineModel createBovine() {
    return BovineModel.empty();
  }
}

class BreedBovineFactory extends BovineFactory {
  final String breed;
  
  BreedBovineFactory(this.breed);
  
  @override
  BovineModel createBovine() {
    return BovineModel.withBreed(breed);
  }
}
