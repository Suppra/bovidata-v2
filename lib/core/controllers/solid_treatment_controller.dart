// Controller moderno para tratamientos usando arquitectura SOLID
import 'package:flutter/material.dart';
import '../locator/service_locator.dart';
import '../services/solid_services.dart';
import '../../models/treatment_model.dart';

/// Controller moderno para tratamientos usando arquitectura SOLID
/// Reemplaza TreatmentController legacy con principios SOLID aplicados
class SolidTreatmentController extends ChangeNotifier {
  final SolidTreatmentService _treatmentService = ServiceLocator.treatmentService;
  
  List<TreatmentModel> _treatments = [];
  List<TreatmentModel> _filteredTreatments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String _searchQuery = '';
  String _selectedType = '';
  bool _showCompleted = true;
  bool _showPending = true;

  // Getters
  List<TreatmentModel> get treatments => _filteredTreatments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  bool get showCompleted => _showCompleted;
  bool get showPending => _showPending;

  // Statistics usando principios SOLID
  int get totalTreatments => _treatments.length;
  int get completedTreatments => _treatments.where((t) => t.completado).length;
  int get pendingTreatments => _treatments.where((t) => !t.completado).length;

  // Tipos de tratamiento disponibles
  List<String> get availableTypes {
    return _treatments.map((t) => t.tipo).toSet().toList()..sort();
  }

  /// Inicializar controller usando servicios SOLID
  void initialize() {
    loadTreatments();
  }

  /// Cargar tratamientos usando servicio SOLID
  Future<void> loadTreatments() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Usar getPendingTreatments para obtener todos los tratamientos
      _treatments = await _treatmentService.getPendingTreatments();
      _applyFilters();
    } catch (e) {
      _setError('Error al cargar tratamientos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cargar tratamientos por bovino
  Future<void> loadTreatmentsByBovine(String bovineId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _treatments = await _treatmentService.getTreatmentsByBovine(bovineId);
      _applyFilters();
    } catch (e) {
      _setError('Error al cargar tratamientos del bovino: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear tratamiento usando Builder pattern y servicio SOLID
  Future<bool> createTreatment(TreatmentModel treatment) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _treatmentService.createTreatment(treatment);
      await loadTreatments(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al crear tratamiento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar tratamiento usando servicio SOLID
  Future<bool> updateTreatment(TreatmentModel treatment) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _treatmentService.updateTreatment(treatment.id, treatment);
      await loadTreatments(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al actualizar tratamiento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar tratamiento usando servicio SOLID
  Future<bool> deleteTreatment(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _treatmentService.deleteTreatment(id);
      await loadTreatments(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al eliminar tratamiento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar tratamientos
  void searchTreatments(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Filtrar por tipo
  void filterByType(String type) {
    _selectedType = type;
    _applyFilters();
  }

  /// Alternar mostrar completados
  void toggleShowCompleted(bool show) {
    _showCompleted = show;
    _applyFilters();
  }

  /// Alternar mostrar pendientes  
  void toggleShowPending(bool show) {
    _showPending = show;
    _applyFilters();
  }

  /// Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedType = '';
    _showCompleted = true;
    _showPending = true;
    _applyFilters();
  }

  /// Aplicar filtros usando principios SOLID
  void _applyFilters() {
    _filteredTreatments = _treatments.where((treatment) {
      bool matchesSearch = _searchQuery.isEmpty ||
          treatment.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          treatment.tipo.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesType = _selectedType.isEmpty || treatment.tipo == _selectedType;
      
      bool matchesStatus = (_showCompleted && treatment.completado) || 
                          (_showPending && !treatment.completado);

      return matchesSearch && matchesType && matchesStatus;
    }).toList();
    
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Refrescar datos
  void refresh() {
    loadTreatments();
  }

  /// Limpiar error
  void clearError() {
    _clearError();
    notifyListeners();
  }
}