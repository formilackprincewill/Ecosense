// lib/screens/data_export_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  // Form State Values matching parameters
  String _exportFormat = 'csv';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _limitController = TextEditingController();

  // Operational Control Properties
  bool _isExporting = false;
  String? _statusMessage;
  bool _isError = false;
  final int _maxLimit = 10000;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _onReset() {
    setState(() {
      _exportFormat = 'csv';
      _startDate = null;
      _endDate = null;
      _limitController.clear();
      _statusMessage = null;
      _isError = false;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleExportExecution() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isExporting = true;
      _statusMessage = "Connecting to environmental nodes...";
      _isError = false;
    });

    try {
      // 1. Build Query against the target table 'data_points' matching your database logs
      PostgrestTransformBuilder<PostgrestList>? query;

      if (_startDate != null) {
        query = _supabase
            .from('data_points')
            .select()
            .gte('created_at', _startDate!.toIso8601String());
      }
      if (_endDate != null) {
        // Extend end date to the final hour string of that chosen calendar day block
        final endWindow = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          23,
          59,
          59,
        );
        query = _supabase
            .from('data_points')
            .select()
            .lte('created_at', endWindow.toIso8601String());
      }

      // Check and apply limits
      int parsedLimit = _maxLimit;
      if (_limitController.text.isNotEmpty) {
        parsedLimit = int.parse(_limitController.text);
      }
      query = query?.limit(parsedLimit);

      // Fetch dynamic runtime payload arrays
      final List<dynamic>? data = await query;

      if (data == null) {
        throw Exception(
          "No environmental recordings found matching those date conditions.",
        );
      }

      setState(() {
        _statusMessage = "Processing payload rows (${data.length} records)...";
      });

      // 2. Format Data Payload
      String formattedFileStringData;
      String fileExtension;

      if (_exportFormat == 'json') {
        formattedFileStringData = const JsonEncoder.withIndent(
          '  ',
        ).convert(data);
        fileExtension = 'json';
      } else {
        // Collect map keys accurately to build columns header lists
        List<String> headers = (data.first as Map<String, dynamic>).keys
            .toList();
        List<List<dynamic>> csvRows = [headers];

        for (var rowMap in data) {
          csvRows.add(headers.map((h) => rowMap[h]).toList());
        }
        formattedFileStringData = const CsvEncoder().convert(csvRows);
        fileExtension = 'csv';
      }

      // 3. Save Payload and Export to Mobile Share Sheet UI
      final dateStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final tempDirectory = await getTemporaryDirectory();
      final targetPath =
          '${tempDirectory.path}/ecosense_export_$dateStamp.$fileExtension';
      final fileNode = File(targetPath);

      await fileNode.writeAsString(formattedFileStringData);

      setState(() {
        _isExporting = false;
        _statusMessage =
            "Export compiled successfully! Initializing device share protocols.";
        _isError = false;
      });

      // Invoke OS native file dispatcher sheet
      final fileX = XFile(targetPath);
      await SharePlus.instance.share(
        ShareParams(
          files: [fileX],
          text: 'EcoSense Environmental Analysis Export',
        ),
      );
    } catch (error) {
      setState(() {
        _isExporting = false;
        _statusMessage = error.toString().replaceAll("Exception: ", "");
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final dateDisplayFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Export System Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF101910),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF101910)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Environmental Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101910),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Download collected environmental data for research or analysis.',
                style: TextStyle(
                  color: Color(0xFF101910).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Parameter Processing Card Box
              Card(
                color: Color(0xFFF9FBF9),
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      color: Colors
                          .green[700], // Matches Angular 'bg-success' paradigm
                      child: Text(
                        'Export Parameters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Format Selector Input Element
                          DropdownButtonFormField<String>(
                            dropdownColor: Color(0xFFF9FBF9),
                            initialValue: _exportFormat,
                            decoration: const InputDecoration(
                              labelText: 'Export Format',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'csv',
                                child: Text('CSV (Spreadsheet)'),
                              ),
                              DropdownMenuItem(
                                value: 'json',
                                child: Text('JSON Object Schema'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _exportFormat = val);
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          // Start Calendar Block UI Element
                          ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFFCCCCCC)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: Text(
                              _startDate == null
                                  ? 'Pick Start Date (Optional)'
                                  : 'Start Window: ${dateDisplayFormat.format(_startDate!)}',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, true),
                          ),
                          const SizedBox(height: 16),

                          // End Calendar Block UI Element
                          ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFFCCCCCC)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            title: Text(
                              _endDate == null
                                  ? 'Pick End Date (Optional)'
                                  : 'End Window: ${dateDisplayFormat.format(_endDate!)}',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                          ),
                          const SizedBox(height: 20),

                          // Max Records Limit Field Input Form Block
                          TextFormField(
                            controller: _limitController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Limit (Max Records)',
                              hintText: 'Defaults to maximum bounds',
                              helperText:
                                  'Maximum number of records to pull (up to $_maxLimit).',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return null;
                              final parsed = int.tryParse(val);
                              if (parsed == null) {
                                return 'Please supply a numerical integer value';
                              }
                              if (parsed < 1) {
                                return 'Limits must exceed zero records';
                              }
                              if (parsed > _maxLimit) {
                                return 'Max safe runtime block threshold is $_maxLimit records';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trigger Operation Button Array Row Elements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _isExporting ? null : _onReset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: Text('Reset', style: TextStyle(color: Colors.green[300])),
                  ),
                  ElevatedButton(
                    onPressed: _isExporting ? null : _handleExportExecution,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isExporting) ...[
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Exporting...'),
                        ] else ...[
                          const Icon(Icons.file_download),
                          const SizedBox(width: 8),
                          const Text('Export Data'),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Operational Notification Status Message Blocks
              if (_statusMessage != null) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isError
                        ? Colors.red.withOpacity(0.12)
                        : Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    // border: BorderSide(color: _isError ? Colors.red : Colors.green),
                  ),
                  child: Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: _isError ? Color(0xFFB00020) : Color(0xFF2E7D32),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
