// Capa de DOMINIO (mortality) — puerto del repositorio de incidencias/mortalidad.
import 'package:bovidata_new/models/incident_model.dart';

abstract class IIncidentRepository {
  Future<List<IncidentModel>> getByBovine(String bovineId);
  Future<List<IncidentModel>> getByOwners(List<String> ownerIds);
}
