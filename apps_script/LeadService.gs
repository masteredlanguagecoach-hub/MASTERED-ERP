/**
 * MASTERED ERP v8.0 — Lead Service (LeadService.gs)
 */

var LeadService = {
  getLeads: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Leads retrieved successfully',
      data: [],
      requestId: requestId,
      timestamp: timestamp
    };
  },

  createLead: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    if (!payload.name || !payload.phone) {
      return {
        success: false,
        errorCode: 'VALIDATION_ERROR',
        message: 'Lead Name and Primary Phone are required.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var leadId = 'LD-2026-' + Math.floor(1000 + Math.random() * 9000);
    return {
      success: true,
      message: 'Lead created successfully',
      data: {
        id: leadId,
        name: payload.name,
        phone: payload.phone,
        email: payload.email || '',
        city: payload.city || 'Kochi',
        course: payload.course || 'BCA-1Y',
        source: payload.source || 'Meta Ad',
        assigned: user.name,
        status: 'New'
      },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  updateStage: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Lead stage updated successfully',
      data: { leadId: payload.leadId, newStage: payload.stage },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  logFollowup: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Follow-up logged successfully',
      data: { followupId: 'FOL-' + Math.floor(1000 + Math.random() * 9000), leadId: payload.leadId },
      requestId: requestId,
      timestamp: timestamp
    };
  },

  importLeadsExcel: function(user, payload, requestId) {
    var timestamp = new Date().toISOString();
    return {
      success: true,
      message: 'Excel leads imported successfully',
      data: { batchId: 'IMP-' + Math.floor(1000 + Math.random() * 9000), count: (payload.leads ? payload.leads.length : 0) },
      requestId: requestId,
      timestamp: timestamp
    };
  }
};
