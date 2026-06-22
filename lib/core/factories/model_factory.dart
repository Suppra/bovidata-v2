// Factory Method Pattern - Creación de modelos
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bovidata_new/models/bovine_model.dart';
import 'package:bovidata_new/models/treatment_model.dart';
import 'package:bovidata_new/models/inventory_model.dart';
import 'package:bovidata_new/models/user_model.dart';

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
    if (T == BovineModel) return BovineModel.fromFirestore(doc) as T;
    if (T == TreatmentModel) return TreatmentModel.fromFirestore(doc) as T;
    if (T == InventoryModel) return InventoryModel.fromFirestore(doc) as T;
    if (T == UserModel) return UserModel.fromFirestore(doc) as T;
    throw UnsupportedError('Tipo de modelo no soportado: $T');
  }

  @override
  T createEmpty<T>() {
    if (T == BovineModel) return BovineModel.empty() as T;
    if (T == TreatmentModel) return TreatmentModel.empty() as T;
    if (T == InventoryModel) return InventoryModel.empty() as T;
    if (T == UserModel) return UserModel.empty() as T;
    throw UnsupportedError('Tipo de modelo no soportado: $T');
  }

  @override
  T createFromMap<T>(Map<String, dynamic> data, String id) {
    if (T == BovineModel) return BovineModel.fromMap(data, id) as T;
    if (T == TreatmentModel) return TreatmentModel.fromMap(data, id) as T;
    if (T == InventoryModel) return InventoryModel.fromMap(data, id) as T;
    if (T == UserModel) return UserModel.fromMap(data, id) as T;
    throw UnsupportedError('Tipo de modelo no soportado: $T');
  }
}
