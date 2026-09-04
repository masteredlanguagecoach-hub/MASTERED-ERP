/**
 * MASTERED ERP v8.0 — Staff Duty & HR Verification Service (DutyService.gs)
 */

var DutyService = {
  submitDuty: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    var title = payload.title;
    var category = payload.category || 'General Operations';
    
    if (!title) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'Duty Title is required.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var dutyId = 'DUTY-' + Math.floor(1000 + Math.random() * 9000);
    var dutyRecord = {
      dutyId: dutyId,
      staffId: user.id,
      staffName: user.name,
      title: title,
      category: category,
      priority: payload.priority || 'Medium',
      progress: payload.progress || '100%',
      status: 'Submitted',
      submittedAt: timestamp
    };

    return {
      success: true,
      message: 'Staff Duty Log submitted successfully for HR verification',
      data: dutyRecord,
      requestId: requestId,
      timestamp: timestamp
    };
  },

  getDuties: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    
    // Sample duties database output for verification
    var sampleDuties = [
      {
        dutyId: 'DUTY-1001',
        staffId: 'USR-1006',
        staffName: 'Demo Staff',
        title: 'Complete Lead Phone Verification Batch #14',
        category: 'Outreach & Verification',
        priority: 'High',
        progress: '100%',
        status: 'Submitted',
        submittedAt: timestamp,
        hrVerified: false
      },
      {
        dutyId: 'DUTY-1002',
        staffId: 'USR-1006',
        staffName: 'Demo Staff',
        title: 'Review Admission Certificates for BCA Batch',
        category: 'Documentation',
        priority: 'Medium',
        progress: '50%',
        status: 'Carried Forward',
        submittedAt: timestamp,
        hrVerified: false,
        parentDutyId: 'DUTY-0988'
      }
    ];

    return {
      success: true,
      message: 'Staff Duties retrieved successfully',
      data: sampleDuties,
      requestId: requestId,
      timestamp: timestamp
    };
  },

  verifyDuty: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    var dutyId = payload.dutyId;
    var decision = payload.decision; // Verified Completed, Correction Required, Carried Forward

    if (user.role === 'HR' && payload.staffId === user.id) {
      return {
        success: false,
        errorCode: 'SELF_VERIFICATION_FORBIDDEN',
        message: 'HR Manager cannot verify their own staff duties. Verification requires Admin approval.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    return {
      success: true,
      message: 'Staff Duty ' + dutyId + ' verified as ' + decision,
      data: {
        dutyId: dutyId,
        verificationId: 'VER-' + Math.floor(1000 + Math.random() * 9000),
        decision: decision,
        verifiedBy: user.name,
        verifiedAt: timestamp
      },
      requestId: requestId,
      timestamp: timestamp
    };
  }
};
