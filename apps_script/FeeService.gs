/**
 * MASTERED ERP v8.0 — Fee Service (FeeService.gs)
 */

var FeeService = {
  getInstallments: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Installments retrieved successfully',
      data: [],
      requestId: requestId,
      timestamp: timestamp
    };
  },

  recordPayment: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    var amount = parseFloat(payload.amount) || 0;
    if (!payload.studentId || amount <= 0) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'Valid Student ID and Payment Amount are required.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var receiptId = 'REC-' + Math.floor(1000 + Math.random() * 9000);
    return {
      success: true,
      message: 'Payment recorded and PDF Receipt generated',
      data: {
        paymentId: 'PAY-' + Math.floor(1000 + Math.random() * 9000),
        receiptId: receiptId,
        studentId: payload.studentId,
        amount: amount,
        mode: payload.mode || 'GPay / UPI',
        collectedBy: user.name,
        receiptPdfUrl: 'https://drive.google.com/file/d/sample-receipt-pdf/view'
      },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  extendDue: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    var days = parseInt(payload.extensionDays) || 0;
    if (days <= 0 || days > 10) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'Installment extension cannot exceed 10 days per request.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    if (!payload.reason) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'A valid justification reason is required for installment extensions.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    return {
      success: true,
      message: 'Installment due date extended by ' + days + ' days',
      data: {
        installmentId: payload.installmentId,
        extensionDays: days,
        reason: payload.reason,
        approvedBy: user.name
      },
      requestId: requestId,
      timestamp: timestamp
    };
  }
};
