import 'package:flutter/material.dart';
import '../data/models/lead_model.dart';
import '../data/models/user_model.dart';
import '../data/services/gas_api_service.dart';

class LeadProvider extends ChangeNotifier {
  List<LeadModel> _leads = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';

  List<LeadModel> get leads => _filteredLeads();
  List<LeadModel> get rawLeads => _leads;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;

  List<LeadModel> _filteredLeads() {
    return _leads.where((l) {
      final matchesStatus = _selectedStatusFilter == 'All' || l.status == _selectedStatusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.phone.contains(_searchQuery) ||
          l.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.courseInterested.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchLeads(UserModel user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await GasApiService().post('getLeads', {'user': user.toJson()});
      if (res is List) {
        _leads = res.map((item) => LeadModel.fromJson(item)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createLead(Map<String, dynamic> leadData, UserModel currentUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      leadData['created_by'] = currentUser.email;
      await GasApiService().post('createLead', leadData);
      await fetchLeads(currentUser);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateLead(Map<String, dynamic> leadData, UserModel currentUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await GasApiService().post('updateLead', leadData);
      await fetchLeads(currentUser);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteLead(String leadId, UserModel currentUser) async {
    _isLoading = true;
    notifyListeners();
    try {
      await GasApiService().post('deleteLead', {'lead_id': leadId});
      await fetchLeads(currentUser);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignLead(String leadId, String assignedTo, UserModel currentUser) async {
    return updateLead({'lead_id': leadId, 'assigned_to': assignedTo}, currentUser);
  }

  Future<bool> convertLeadToStudent({
    required LeadModel lead,
    required double totalFee,
    required double paidFee,
    required String course,
    required UserModel currentUser,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await GasApiService().post('convertLead', {
        'lead_id': lead.leadId,
        'name': lead.name,
        'phone': lead.phone,
        'email': lead.email,
        'course': course,
        'total_fee': totalFee,
        'paid_fee': paidFee,
      });

      await fetchLeads(currentUser);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
