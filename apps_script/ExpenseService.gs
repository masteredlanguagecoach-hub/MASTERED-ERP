/**
 * MASTERED ERP v8.0 — Expense Service (ExpenseService.gs)
 */

var ExpenseService = {
  getExpenses: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Expenses retrieved successfully',
      data: [],
      requestId: requestId,
      timestamp: timestamp
    };
  },

  recordExpense: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    var title = payload.title;
    var amount = parseFloat(payload.amount) || 0;

    if (!title || amount <= 0) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'Expense Title and valid Amount are required.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var expenseId = 'EXP-' + Math.floor(1000 + Math.random() * 9000);
    return {
      success: true,
      message: 'Expense recorded successfully',
      data: {
        expenseId: expenseId,
        title: title,
        category: payload.category || 'Petty Cash',
        amount: amount,
        enteredBy: user.name,
        approvalStatus: 'Approved'
      },
      requestId: requestId,
      timestamp: timestamp
    };
  }
};
