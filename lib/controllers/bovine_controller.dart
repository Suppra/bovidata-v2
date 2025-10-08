import 'package:flutter/material.dart';
import '../models/bovine_model.dart';
import '../services/bovine_service.dart';

class BovineController extends ChangeNotifier {
  final BovineService _bovineService = BovineService();

  List<BovineModel> _bovines = [];
  BovineModel? _selectedBovine;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _statusCounts = {};
  List<String> _availableRaces = [];
  Map<String, dynamic> _statistics = {};

  // Getters
  List<BovineModel> get bovines => _bovines;
  BovineModel? get selectedBovine => _selectedBovine;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get statusCounts => _statusCounts;
  List<String> get availableRaces => _availableRaces;
  Map<String, dynamic> get statistics => _statistics;

  // Filtered lists
  List<BovineModel> get healthyBovines => 
      _bovines.where((b) => b.estado == 'Sano').toList();
  List<BovineModel> get sickBovines => 
      _bovines.where((b) => b.estado == 'Enfermo').toList();
  List<BovineModel> get recoveringBovines => 
      _bovines.where((b) => b.estado == 'En recuperación').toList();
  List<BovineModel> get deadBovines => 
      _bovines.where((b) => b.estado == 'Muerto').toList();

  List<BovineModel> get maleBovines => 
      _bovines.where((b) => b.sexo.toLowerCase() == 'macho').toList();
  List<BovineModel> get femaleBovines => 
      _bovines.where((b) => b.sexo.toLowerCase() == 'hembra').toList();

  // Initialize controller
  void initialize() {
    loadBovines();
    loadRaces();
    loadStatistics();
  }

  // Load all bovines
  void loadBovines() {
    _setLoading(true);
    _bovineService.getBovinesStream().listen(
      (bovines) {
        _bovines = bovines;
        _updateStatusCounts();
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error cargando bovinos: $error');
        _setLoading(false);
      },
    );
  }

  // Load bovines for veterinarian
  void loadBovinesForVeterinarian() {
    _setLoading(true);
    _bovineService.getBovinesForVeterinarian().listen(
      (bovines) {
        _bovines = bovines;
        _updateStatusCounts();
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setError('Error cargando bovinos: $error');
        _setLoading(false);
      },
    );
  }

  // Add new bovine
  Future<bool> addBovine(BovineModel bovine) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if identification number already exists
      final exists = await _bovineService.identificationExists(bovine.numeroIdentificacion);
      if (exists) {
        _setError('El número de identificación ya existe');
        _setLoading(false);
        return false;
      }

      await _bovineService.addBovine(bovine);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update bovine
  Future<bool> updateBovine(String id, BovineModel bovine) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if identification number already exists (excluding current bovine)
      final exists = await _bovineService.identificationExists(
        bovine.numeroIdentificacion, 
        excludeId: id,
      );
      if (exists) {
        _setError('El número de identificación ya existe');
        _setLoading(false);
        return false;
      }

      await _bovineService.updateBovine(id, bovine);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete bovine
  Future<bool> deleteBovine(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _bovineService.deleteBovine(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get bovine by ID
  Future<BovineModel?> getBovineById(String id) async {
    _clearError();
    try {
      return await _bovineService.getBovineById(id);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Select bovine
  void selectBovine(BovineModel? bovine) {
    _selectedBovine = bovine;
    notifyListeners();
  }

  // Search bovines
  Future<List<BovineModel>> searchBovines(String query) async {
    _clearError();
    try {
      return await _bovineService.searchBovines(query);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Filter bovines by status
  List<BovineModel> filterByStatus(String status) {
    return _bovines.where((bovine) => bovine.estado == status).toList();
  }

  // Filter bovines by race
  List<BovineModel> filterByRace(String race) {
    return _bovines.where((bovine) => bovine.raza == race).toList();
  }

  // Filter bovines by sex
  List<BovineModel> filterBySex(String sex) {
    return _bovines.where((bovine) => bovine.sexo == sex).toList();
  }

  // Update bovine status
  Future<bool> updateBovineStatus(String id, String newStatus) async {
    _clearError();
    try {
      await _bovineService.updateBovineStatus(id, newStatus);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update bovine weight
  Future<bool> updateBovineWeight(String id, double newWeight) async {
    _clearError();
    try {
      await _bovineService.updateBovineWeight(id, newWeight);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Load available races
  Future<void> loadRaces() async {
    try {
      _availableRaces = await _bovineService.getAllRaces();
      notifyListeners();
    } catch (e) {
      _setError('Error cargando razas: $e');
    }
  }

  // Load statistics
  Future<void> loadStatistics() async {
    try {
      _statistics = await _bovineService.getBovinesStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Error cargando estadísticas: $e');
    }
  }

  // Update status counts
  void _updateStatusCounts() {
    _statusCounts = {};
    for (var bovine in _bovines) {
      _statusCounts[bovine.estado] = (_statusCounts[bovine.estado] ?? 0) + 1;
    }
  }

  // Get bovines by age range
  List<BovineModel> getBovinesByAgeRange(int minAge, int maxAge) {
    return _bovines.where((bovine) {
      final age = bovine.edad;
      return age >= minAge && age <= maxAge;
    }).toList();
  }

  // Get bovines that need attention (sick or recovering)
  List<BovineModel> getBovinesNeedingAttention() {
    return _bovines.where((bovine) => 
        bovine.estado == 'Enfermo' || bovine.estado == 'En recuperación'
    ).toList();
  }

  // Get recently added bovines (within last 30 days)
  List<BovineModel> getRecentlyAddedBovines() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _bovines.where((bovine) => 
        bovine.fechaCreacion.isAfter(thirtyDaysAgo)
    ).toList();
  }

  // Get bovines by weight range
  List<BovineModel> getBovinesByWeightRange(double minWeight, double maxWeight) {
    return _bovines.where((bovine) => 
        bovine.peso >= minWeight && bovine.peso <= maxWeight
    ).toList();
  }

  // Validate identification number
  Future<bool> validateIdentification(String identification, {String? excludeId}) async {
    try {
      return !(await _bovineService.identificationExists(identification, excludeId: excludeId));
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
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

  // Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Refresh data
  void refresh() {
    loadBovines();
    loadRaces();
    loadStatistics();
  }


}