import 'package:flutter/material.dart';
import '../data/models/batch_model.dart';
import '../data/services/gas_api_service.dart';

class BatchProvider extends ChangeNotifier {
  List<BatchModel> _batches = [
    BatchModel(batchId: 'BTC-101', batchName: 'Batch 2026-A (Full Stack)', course: 'Full Stack Development', startDate: '2026-09-10', schedule: 'Mon-Fri 10:00 AM', trainer: 'Vikram Sir', status: 'ACTIVE', createdAt: '2026-08-01'),
    BatchModel(batchId: 'BTC-102', batchName: 'Weekend UI/UX Batch 1', course: 'UI/UX Masterclass', startDate: '2026-09-12', schedule: 'Sat-Sun 02:00 PM', trainer: 'Neha Maam', status: 'ACTIVE', createdAt: '2026-08-05'),
    BatchModel(batchId: 'BTC-103', batchName: 'Data Science Evening Batch', course: 'Data Science & AI', startDate: '2026-09-15', schedule: 'Mon-Fri 06:00 PM', trainer: 'Dr. Rajesh', status: 'UPCOMING', createdAt: '2026-08-20'),
  ];

  bool _isLoading = false;
  String? _errorMessage;

  List<BatchModel> get batches => _batches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBatches() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('getBatches', {});
      if (res is List && res.isNotEmpty) {
        _batches = res.map((b) => BatchModel.fromJson(b)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBatch({
    required String batchName,
    required String course,
    required String startDate,
    required String schedule,
    required String trainer,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newBatchId = 'BTC-${101 + _batches.length}';
      final newBatch = BatchModel(
        batchId: newBatchId,
        batchName: batchName,
        course: course,
        startDate: startDate,
        schedule: schedule,
        trainer: trainer,
        status: 'ACTIVE',
        createdAt: DateTime.now().toIso8601String(),
      );

      _batches.insert(0, newBatch);
      await GasApiService().post('createBatch', newBatch.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reassignStudentBatch(String studentId, BatchModel targetBatch) async {
    _isLoading = true;
    notifyListeners();

    try {
      await GasApiService().post('updateStudentBatch', {
        'student_id': studentId,
        'batch_id': targetBatch.batchId,
        'batch_name': targetBatch.batchName,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
