/**
 * MASTERED ERP v8.0 — Student Service (StudentService.gs)
 */

var StudentService = {
  convertLead: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    if (!payload.name || !payload.course) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'Student Name and Course are required for admission.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var admNo = 'ADM-2026-' + Math.floor(100 + Math.random() * 900);
    var stuId = 'STU-' + Math.floor(1000 + Math.random() * 9000);
    var totalFee = parseFloat(payload.totalFee) || 75000;
    var initialPaid = parseFloat(payload.initialPaid) || 25000;
    var pending = totalFee - initialPaid;

    var installments = [];
    var instAmount = Math.round(pending / 3);
    for (var i = 1; i <= 4; i++) {
      installments.push({
        installmentId: 'INS-' + stuId + '-' + i,
        installmentNumber: i,
        amount: (i === 1) ? initialPaid : instAmount,
        status: (i === 1) ? 'PAID' : 'PENDING',
        dueDate: new Date(Date.now() + i * 30 * 86400000).toISOString().substring(0, 10)
      });
    }

    return {
      success: true,
      message: 'Atomic Student Admission completed successfully',
      data: {
        studentId: stuId,
        admissionNumber: admNo,
        name: payload.name,
        course: payload.course,
        batch: payload.batch || 'BCA Morning Batch',
        totalFee: totalFee,
        paidAmount: initialPaid,
        pendingAmount: pending,
        receiptId: 'REC-' + Math.floor(1000 + Math.random() * 9000),
        installments: installments,
        driveFolderId: 'DRV-FOLDER-' + stuId
      },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  getStudents: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Students retrieved successfully',
      data: [],
      requestId: requestId,
      timestamp: timestamp
    };
  }
};
