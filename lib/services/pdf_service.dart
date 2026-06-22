import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class PdfService {
  static Future<Uint8List> generateMedicalHistoryPdf({
    required BovineModel bovine,
    required List<TreatmentModel> treatments,
    required List<IncidentModel> incidents,
    required List<ActivityModel> activities,
    required UserModel veterinarian,
    required UserModel owner,
  }) async {
    final pdf = pw.Document();
    
    // Cargar fuente
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          // Header
          _buildHeader(bovine, boldFont, font),
          pw.SizedBox(height: 20),
          
          // Información del bovino
          _buildBovineInfo(bovine, boldFont, font),
          pw.SizedBox(height: 20),
          
          // Información del veterinario
          _buildVeterinarianInfo(veterinarian, boldFont, font),
          pw.SizedBox(height: 20),
          
          // Información del ganadero
          _buildOwnerInfo(owner, boldFont, font),
          pw.SizedBox(height: 20),
          
          // Resumen estadístico
          _buildStatsSummary(treatments, incidents, activities, boldFont, font),
          pw.SizedBox(height: 20),
          
          // Tratamientos
          if (treatments.isNotEmpty) ...[
            _buildTreatmentsSection(treatments, boldFont, font),
            pw.SizedBox(height: 20),
          ],
          
          // Incidentes
          if (incidents.isNotEmpty) ...[
            _buildIncidentsSection(incidents, boldFont, font),
            pw.SizedBox(height: 20),
          ],
          
          // Actividades veterinarias
          if (activities.isNotEmpty) ...[
            _buildActivitiesSection(activities, boldFont, font),
          ],
          
          // Footer
          pw.SizedBox(height: 30),
          _buildFooter(font),
        ],
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Widget _buildHeader(BovineModel bovine, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'HISTORIAL MÉDICO VETERINARIO',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Bovino: ${bovine.nombre}',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: PdfColors.blue700,
            ),
          ),
          pw.Text(
            'ID: ${bovine.numeroIdentificacion}',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.blue700,
            ),
          ),
          pw.Text(
            'Fecha de generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildBovineInfo(BovineModel bovine, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL BOVINO',
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.blue800),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nombre:', bovine.nombre, font, boldFont),
                    _buildInfoRow('Identificación:', bovine.numeroIdentificacion, font, boldFont),
                    _buildInfoRow('Raza:', bovine.raza, font, boldFont),
                    _buildInfoRow('Sexo:', bovine.sexo, font, boldFont),
                    _buildInfoRow('Color:', bovine.color, font, boldFont),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Edad:', '${bovine.edad} años', font, boldFont),
                    _buildInfoRow('Peso:', '${bovine.peso.toStringAsFixed(1)} kg', font, boldFont),
                    _buildInfoRow('Estado:', bovine.estado, font, boldFont),
                    _buildInfoRow('Fecha nacimiento:', DateFormat('dd/MM/yyyy').format(bovine.fechaNacimiento), font, boldFont),
                    _buildInfoRow('Fecha registro:', DateFormat('dd/MM/yyyy').format(bovine.fechaCreacion), font, boldFont),
                  ],
                ),
              ),
            ],
          ),
          if (bovine.observaciones?.isNotEmpty == true) ...[
            pw.SizedBox(height: 10),
            _buildInfoRow('Observaciones:', bovine.observaciones!, font, boldFont),
          ],
        ],
      ),
    );
  }
  
  static pw.Widget _buildVeterinarianInfo(UserModel veterinarian, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL VETERINARIO',
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.green800),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nombre:', '${veterinarian.nombre} ${veterinarian.apellido}', font, boldFont),
                    _buildInfoRow('Cédula:', veterinarian.cedula ?? 'No disponible', font, boldFont),
                    _buildInfoRow('Email:', veterinarian.email, font, boldFont),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Teléfono:', veterinarian.telefono.isEmpty ? 'No disponible' : veterinarian.telefono, font, boldFont),
                    _buildInfoRow('Rol:', veterinarian.rol, font, boldFont),
                    if (veterinarian.cedula?.isNotEmpty == true)
                      _buildInfoRow('Cédula:', veterinarian.cedula!, font, boldFont),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildOwnerInfo(UserModel owner, pw.Font boldFont, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL GANADERO',
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.orange800),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nombre:', '${owner.nombre} ${owner.apellido}', font, boldFont),
                    _buildInfoRow('Cédula:', owner.cedula ?? 'No disponible', font, boldFont),
                    _buildInfoRow('Email:', owner.email, font, boldFont),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Teléfono:', owner.telefono.isEmpty ? 'No disponible' : owner.telefono, font, boldFont),
                    _buildInfoRow('Rol:', owner.rol, font, boldFont),
                    if (owner.direccion?.isNotEmpty == true)
                      _buildInfoRow('Dirección:', owner.direccion!, font, boldFont),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildStatsSummary(
    List<TreatmentModel> treatments,
    List<IncidentModel> incidents,
    List<ActivityModel> activities,
    pw.Font boldFont,
    pw.Font font,
  ) {
    final completedTreatments = treatments.where((t) => t.completado).length;
    final pendingTreatments = treatments.where((t) => !t.completado).length;
    final criticalIncidents = incidents.where((i) => i.gravedad.toLowerCase() == 'alta' || i.gravedad.toLowerCase() == 'crítica').length;
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMEN ESTADÍSTICO',
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.grey800),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tratamientos\nTotales', treatments.length.toString(), font, boldFont),
              _buildStatItem('Tratamientos\nCompletados', completedTreatments.toString(), font, boldFont),
              _buildStatItem('Tratamientos\nPendientes', pendingTreatments.toString(), font, boldFont),
              _buildStatItem('Incidentes\nTotales', incidents.length.toString(), font, boldFont),
              _buildStatItem('Incidentes\nCríticos', criticalIncidents.toString(), font, boldFont),
              _buildStatItem('Actividades\nVeterinarias', activities.length.toString(), font, boldFont),
            ],
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTreatmentsSection(List<TreatmentModel> treatments, pw.Font boldFont, pw.Font font) {
    // Ordenar por fecha más reciente
    final sortedTreatments = treatments..sort((a, b) => b.fecha.compareTo(a.fecha));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HISTORIAL DE TRATAMIENTOS',
          style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 10),
        
        // Tabla de tratamientos
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: const {
            0: pw.FractionColumnWidth(0.2),
            1: pw.FractionColumnWidth(0.25),
            2: pw.FractionColumnWidth(0.15),
            3: pw.FractionColumnWidth(0.2),
            4: pw.FractionColumnWidth(0.2),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                _buildTableCell('Fecha', boldFont, isHeader: true),
                _buildTableCell('Nombre', boldFont, isHeader: true),
                _buildTableCell('Tipo', boldFont, isHeader: true),
                _buildTableCell('Medicamento', boldFont, isHeader: true),
                _buildTableCell('Estado', boldFont, isHeader: true),
              ],
            ),
            // Datos
            ...sortedTreatments.map((treatment) => pw.TableRow(
              children: [
                _buildTableCell(DateFormat('dd/MM/yy').format(treatment.fecha), font),
                _buildTableCell(treatment.nombre, font),
                _buildTableCell(treatment.tipo, font),
                _buildTableCell(treatment.medicamento ?? 'N/A', font),
                _buildTableCell(treatment.completado ? 'Completado' : 'Pendiente', font),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  static pw.Widget _buildIncidentsSection(List<IncidentModel> incidents, pw.Font boldFont, pw.Font font) {
    final sortedIncidents = incidents..sort((a, b) => b.fecha.compareTo(a.fecha));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HISTORIAL DE INCIDENTES',
          style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.red800),
        ),
        pw.SizedBox(height: 10),
        
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: const {
            0: pw.FractionColumnWidth(0.15),
            1: pw.FractionColumnWidth(0.2),
            2: pw.FractionColumnWidth(0.35),
            3: pw.FractionColumnWidth(0.15),
            4: pw.FractionColumnWidth(0.15),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.red50),
              children: [
                _buildTableCell('Fecha', boldFont, isHeader: true),
                _buildTableCell('Tipo', boldFont, isHeader: true),
                _buildTableCell('Descripción', boldFont, isHeader: true),
                _buildTableCell('Gravedad', boldFont, isHeader: true),
                _buildTableCell('Estado', boldFont, isHeader: true),
              ],
            ),
            ...sortedIncidents.map((incident) => pw.TableRow(
              children: [
                _buildTableCell(DateFormat('dd/MM/yy').format(incident.fecha), font),
                _buildTableCell(incident.tipo, font),
                _buildTableCell(incident.descripcion, font),
                _buildTableCell(incident.gravedad, font),
                _buildTableCell(incident.estado, font),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  static pw.Widget _buildActivitiesSection(List<ActivityModel> activities, pw.Font boldFont, pw.Font font) {
    final sortedActivities = activities..sort((a, b) => b.fecha.compareTo(a.fecha));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'ACTIVIDADES VETERINARIAS',
          style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.green800),
        ),
        pw.SizedBox(height: 10),
        
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: const {
            0: pw.FractionColumnWidth(0.2),
            1: pw.FractionColumnWidth(0.25),
            2: pw.FractionColumnWidth(0.55),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.green50),
              children: [
                _buildTableCell('Fecha', boldFont, isHeader: true),
                _buildTableCell('Tipo', boldFont, isHeader: true),
                _buildTableCell('Descripción', boldFont, isHeader: true),
              ],
            ),
            ...sortedActivities.map((activity) => pw.TableRow(
              children: [
                _buildTableCell(DateFormat('dd/MM/yy').format(activity.fecha), font),
                _buildTableCell(activity.tipo, font),
                _buildTableCell(activity.descripcion, font),
              ],
            )),
          ],
        ),
      ],
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: boldFont, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildStatItem(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
  
  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          color: isHeader ? PdfColors.grey800 : PdfColors.grey700,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
  
  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'Este documento fue generado automáticamente por el Sistema BoviData',
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Para más información, contacte al veterinario o ganadero responsable',
            style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey500),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  static Future<void> savePdfToDevice(Uint8List pdfData, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfData);
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }
  
  static Future<void> sharePdf(Uint8List pdfData, String fileName) async {
    await Printing.sharePdf(
      bytes: pdfData,
      filename: fileName,
    );
  }
  
  static Future<void> printPdf(Uint8List pdfData) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
    );
  }
}