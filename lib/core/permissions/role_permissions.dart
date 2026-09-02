import '../constants/app_constants.dart';

/// Centralized Role-Based Access Control (RBAC) permission validator.
class RolePermissions {
  static bool canAccessNavItem(String role, String navId) {
    switch (navId) {
      case 'dashboard':
        return true;

      case 'leads':
        // ADMIN, SALES HEAD, SALES EXECUTIVE ONLY
        return role == AppConstants.roleAdmin ||
            role == AppConstants.roleSalesHead ||
            role == AppConstants.roleSalesExecutive;

      case 'followups':
        // SALES EXECUTIVE, SALES HEAD, ADMIN ONLY
        return role == AppConstants.roleAdmin ||
            role == AppConstants.roleSalesHead ||
            role == AppConstants.roleSalesExecutive;

      case 'due_reminders':
        // OPERATIONS, ADMIN ONLY
        return role == AppConstants.roleAdmin || role == AppConstants.roleOperations;

      case 'students':
        return true;

      case 'batches':
        return role == AppConstants.roleAdmin ||
            role == AppConstants.roleSalesHead ||
            role == AppConstants.roleOperations;

      case 'sales_team':
        return role == AppConstants.roleAdmin || role == AppConstants.roleSalesHead;

      case 'fee_collection':
        return role == AppConstants.roleAdmin || role == AppConstants.roleOperations;

      case 'accounting':
        return role == AppConstants.roleAdmin ||
            role == AppConstants.roleCeo ||
            role == AppConstants.roleOperations;

      case 'reports':
        return role == AppConstants.roleAdmin ||
            role == AppConstants.roleCeo ||
            role == AppConstants.roleSalesHead ||
            role == AppConstants.roleOperations;

      case 'user_management':
        return role == AppConstants.roleAdmin;

      case 'courses':
        return role == AppConstants.roleAdmin;

      case 'audit_logs':
        return role == AppConstants.roleAdmin;

      case 'ai_analysis':
        return role == AppConstants.roleAdmin;

      case 'settings':
        return role == AppConstants.roleAdmin;

      default:
        return false;
    }
  }

  static bool canEnterExpense(String role) {
    return role == AppConstants.roleAdmin ||
        role == AppConstants.roleCeo ||
        role == AppConstants.roleOperations;
  }

  static bool canCreateBatch(String role) {
    return role == AppConstants.roleAdmin || role == AppConstants.roleSalesHead;
  }

  static bool canReassignLeads(String role) {
    return role == AppConstants.roleAdmin || role == AppConstants.roleSalesHead;
  }

  static bool canUpdateDueDate(String role) {
    return role == AppConstants.roleAdmin || role == AppConstants.roleOperations;
  }

  static String getRoleLabel(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'System Owner (Admin)';
      case AppConstants.roleCeo:
        return 'CEO (Rasheed)';
      case AppConstants.roleSalesHead:
        return 'Sales Head (Ashif)';
      case AppConstants.roleSalesExecutive:
        return 'Sales Executive';
      case AppConstants.roleOperations:
        return 'Operations (Operations)';
      default:
        return role;
    }
  }
}
