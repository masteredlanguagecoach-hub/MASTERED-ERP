class AppConstants {
  static const String appName = 'MASTERED ERP';
  static const String academyName = 'MASTERED';
  static const String logoPath = 'assets/logo.png';
  static const String defaultCurrency = '₹';

  // Local Storage Keys
  static const String prefsUserKey = 'mastered_user_data';
  static const String prefsTokenKey = 'mastered_auth_token';
  static const String prefsGasUrlKey = 'mastered_gas_url';

  static const String defaultGasApiUrl = '';

  // User Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleCeo = 'CEO';
  static const String roleSalesHead = 'SALES_HEAD';
  static const String roleSalesExecutive = 'SALES_EXECUTIVE';
  static const String roleOperations = 'OPERATIONS';

  // Lead Statuses
  static const List<String> leadStatuses = [
    'New',
    'Contacted',
    'Interested',
    'Demo',
    'Follow-up',
    'Converted',
    'Lost',
  ];

  // Student Statuses
  static const List<String> studentStatuses = [
    'ACTIVE',
    'DROPPED',
    'GRADUATED',
    'SUSPENDED',
  ];

  // Lead Sources
  static const List<String> leadSources = [
    'Website',
    'Google Ads',
    'Social Media',
    'Referral',
    'Walk-in',
    'Phone Call',
    'Other',
  ];

  // Expense Categories
  static const List<String> expenseCategories = [
    'Salary',
    'Rent',
    'Marketing',
    'Electricity',
    'Internet',
    'Office',
    'Travel',
    'Maintenance',
    'Other',
  ];

  // Payment Modes
  static const List<String> paymentModes = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Razorpay',
    'Cheque',
  ];
}
