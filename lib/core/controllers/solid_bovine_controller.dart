// Controllers modernos que implementan la arquitectura SOLID
import 'package:flutter/material.dart';
import '../locator/service_locator.dart';
import '../services/solid_services.dart';
import '../../models/bovine_model.dart';

/// Controller moderno para bovinos usando arquitectura SOLID
/// Reemplaza BovineController legacy con principios SOLID aplicados
class SolidBovineController extends ChangeNotifier {
  final SolidBovineService _bovineService = ServiceLocator.bovineService;
  
  List<BovineModel> _bovines = [];
  List<BovineModel> _filteredBovines = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedRace = '';
  String _selectedStatus = '';

  // Getters
  List<BovineModel> get bovines => _filteredBovines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedRace => _selectedRace;
  String get selectedStatus => _selectedStatus;

  // Statistics usando principios SOLID
  List<BovineModel> get healthyBovines => _bovines.where((b) => b.estado == 'Sano').toList();
  List<BovineModel> get sickBovines => _bovines.where((b) => b.estado == 'Enfermo').toList();
  List<BovineModel> get recoveringBovines => _bovines.where((b) => b.estado == 'En recuperación').toList();
  List<BovineModel> get maleBovines => _bovines.where((b) => b.sexo.toLowerCase() == 'macho').toList();
  List<BovineModel> get femaleBovines => _bovines.where((b) => b.sexo.toLowerCase() == 'hembra').toList();

  // Razas disponibles
  List<String> get availableRaces {
    return _bovines.map((b) => b.raza).toSet().toList()..sort();
  }

  /// Inicializar controller usando servicios SOLID
  void initialize() {
    loadBovines();
  }

  /// Cargar bovinos usando servicio SOLID
  Future<void> loadBovines() async {
    _setLoading(true);
    _clearError();
    
    try {
      _bovines = await _bovineService.getAllBovines();
      _applyFilters();
    } catch (e) {
      _setError('Error al cargar bovinos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crear bovino usando Builder pattern
  Future<bool> createBovine(BovineModel bovine) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _bovineService.createBovine(bovine);
      await loadBovines(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al crear bovino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Actualizar bovino usando servicio SOLID
  Future<bool> updateBovine(String id, BovineModel bovine) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _bovineService.updateBovine(id, bovine);
      await loadBovines(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al actualizar bovino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Eliminar bovino usando servicio SOLID
  Future<bool> deleteBovine(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _bovineService.deleteBovine(id);
      await loadBovines(); // Recargar lista
      return true;
    } catch (e) {
      _setError('Error al eliminar bovino: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buscar bovinos
  void searchBovines(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Filtrar por raza
  void filterByRace(String race) {
    _selectedRace = race;
    _applyFilters();
  }

  /// Filtrar por estado
  void filterByStatus(String status) {
    _selectedStatus = status;
    _applyFilters();
  }

  /// Limpiar filtros
  void clearFilters() {
    _searchQuery = '';
    _selectedRace = '';
    _selectedStatus = '';
    _applyFilters();
  }

  /// Aplicar filtros usando principios SOLID
  void _applyFilters() {
    _filteredBovines = _bovines.where((bovine) {
      bool matchesSearch = _searchQuery.isEmpty ||
          bovine.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          bovine.numeroIdentificacion.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesRace = _selectedRace.isEmpty || bovine.raza == _selectedRace;
      
      bool matchesStatus = _selectedStatus.isEmpty || bovine.estado == _selectedStatus;

      return matchesSearch && matchesRace && matchesStatus;
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
    loadBovines();
  }

  /// Limpiar error
  void clearError() {
    _clearError();
    notifyListeners();
  }
}