import 'package:flutter/material.dart';
import '../models/treatment_model.dart';
import '../services/treatment_service.dart';

class TreatmentController extends ChangeNotifier {
  List<TreatmentModel> _treatments = [];
  List<TreatmentModel> _filteredTreatments = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter parameters
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

  // Statistics
  int get totalTreatments => _treatments.length;
  int get completedTreatments => _treatments.where((t) => t.completado).length;
  int get pendingTreatments => _treatments.where((t) => !t.completado).length;
  int get overdueTreatments => _treatments.where((t) => t.isOverdue).length;
  
  List<TreatmentModel> get dueSoonTreatments => _treatments
      .where((t) => !t.completado && 
                   t.proximaAplicacion != null && 
                   t.diasParaProxima != null && 
                   t.diasParaProxima! <= 7)
      .toList();

  // Load all treatments
  Future<void> loadTreatments() async {
    _setLoading(true);
    try {
      TreatmentService.getAllTreatments().listen(
        (treatments) {
          _treatments = treatments;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar tratamientos: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar tratamientos: $e');
      _setLoading(false);
    }
  }

  // Load treatments for a specific bovine
  Future<void> loadTreatmentsByBovine(String bovineId) async {
    _setLoading(true);
    try {
      TreatmentService.getTreatmentsByBovine(bovineId).listen(
        (treatments) {
          _treatments = treatments;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar tratamientos: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar tratamientos: $e');
      _setLoading(false);
    }
  }

  // Load treatments by veterinarian
  Future<void> loadTreatmentsByVeterinarian(String veterinarioId) async {
    _setLoading(true);
    try {
      TreatmentService.getTreatmentsByVeterinarian(veterinarioId).listen(
        (treatments) {
          _treatments = treatments;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar tratamientos: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar tratamientos: $e');
      _setLoading(false);
    }
  }

  // Create treatment
  Future<bool> createTreatment(TreatmentModel treatment) async {
    _setLoading(true);
    try {
      final treatmentId = await TreatmentService.createTreatment(treatment);
      if (treatmentId != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al crear el tratamiento');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al crear el tratamiento: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update treatment
  Future<bool> updateTreatment(TreatmentModel treatment) async {
    _setLoading(true);
    try {
      final success = await TreatmentService.updateTreatment(treatment);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar el tratamiento');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al actualizar el tratamiento: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mark treatment as completed
  Future<bool> markTreatmentCompleted(String treatmentId) async {
    _setLoading(true);
    try {
      final success = await TreatmentService.markTreatmentCompleted(treatmentId);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al marcar tratamiento como completado');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al marcar tratamiento como completado: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete treatment
  Future<bool> deleteTreatment(String treatmentId) async {
    _setLoading(true);
    try {
      final success = await TreatmentService.deleteTreatment(treatmentId);
      if (success) {
        _setLoading(false);
        return true;
      } else {
        _setError('Error al eliminar el tratamiento');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error al eliminar el tratamiento: $e');
      _setLoading(false);
      return false;
    }
  }

  // Search treatments
  void searchTreatments(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by type
  void filterByType(String type) {
    _selectedType = type;
    _applyFilters();
  }

  // Toggle show completed
  void toggleShowCompleted(bool show) {
    _showCompleted = show;
    _applyFilters();
  }

  // Toggle show pending
  void toggleShowPending(bool show) {
    _showPending = show;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedType = '';
    _showCompleted = true;
    _showPending = true;
    _applyFilters();
  }

  // Apply filters to treatment list
  void _applyFilters() {
    _filteredTreatments = _treatments.where((treatment) {
      // Status filter
      if (!_showCompleted && treatment.completado) return false;
      if (!_showPending && !treatment.completado) return false;

      // Type filter
      if (_selectedType.isNotEmpty && treatment.tipo != _selectedType) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!treatment.nombre.toLowerCase().contains(query) &&
            !treatment.tipo.toLowerCase().contains(query) &&
            !(treatment.medicamento?.toLowerCase().contains(query) ?? false) &&
            !treatment.descripcion.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Load overdue treatments
  Future<void> loadOverdueTreatments() async {
    _setLoading(true);
    try {
      TreatmentService.getOverdueTreatments().listen(
        (treatments) {
          _treatments = treatments;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar tratamientos vencidos: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar tratamientos vencidos: $e');
      _setLoading(false);
    }
  }

  // Load treatments due soon
  Future<void> loadTreatmentsDueSoon() async {
    _setLoading(true);
    try {
      TreatmentService.getTreatmentsDueSoon().listen(
        (treatments) {
          _treatments = treatments;
          _applyFilters();
          _setLoading(false);
        },
        onError: (error) {
          _setError('Error al cargar tratamientos próximos: $error');
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError('Error al cargar tratamientos próximos: $e');
      _setLoading(false);
    }
  }

  // Get treatment statistics
  Future<Map<String, dynamic>> getTreatmentStatistics() async {
    try {
      return await TreatmentService.getTreatmentStatistics();
    } catch (e) {
      _setError('Error al obtener estadísticas: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'thisMonth': 0,
        'treatmentsByType': <String, int>{},
        'totalCost': 0.0,
      };
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}