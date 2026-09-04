/**
 * MASTERED ERP v8.0 — Action Router (Router.gs)
 */

var Router = {
  routeAction: function(action, sessionToken, requestId, payload) {
    var timestamp = new Date().toISOString();

    // Public / Unauthenticated actions
    if (action === 'healthCheck') {
      return {
        success: true,
        message: 'MASTERED ERP v8.0 Backend API operational',
        data: { apiVersion: '8.0.0', status: 'HEALTHY' },
        requestId: requestId,
        timestamp: timestamp
      };
    }

    if (action === 'login') {
      return AuthService.login(payload.email, payload.password, requestId);
    }

    // Authenticated Actions Validation
    var session = AuthService.validateSession(sessionToken);
    if (!session.valid) {
      return {
        success: false,
        errorCode: 'UNAUTHORIZED',
        message: 'Invalid or expired session token. Please log in again.',
        requestId: requestId,
        timestamp: timestamp
      };
    }

    var user = session.user;

    // Action Routing Map
    switch (action) {
      case 'testConnectionsAdmin':
        if (user.role !== 'ADMIN') return Router.unauthorized(requestId);
        return SheetRepository.testConnectionsAdmin(requestId);

      case 'getLeads':
        return LeadService.getLeads(user, payload, requestId);

      case 'createLead':
        return LeadService.createLead(user, payload, requestId);

      case 'updateLeadStage':
        return LeadService.updateStage(user, payload, requestId);

      case 'logFollowup':
        return LeadService.logFollowup(user, payload, requestId);

      case 'importLeadsExcel':
        return LeadService.importLeadsExcel(user, payload, requestId);

      case 'convertLeadToStudent':
        return StudentService.convertLead(user, payload, requestId);

      case 'getStudents':
        return StudentService.getStudents(user, payload, requestId);

      case 'getFeeInstallments':
        return FeeService.getInstallments(user, payload, requestId);

      case 'recordPayment':
        if (['ADMIN', 'OPERATIONS'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return FeeService.recordPayment(user, payload, requestId);

      case 'extendInstallmentDue':
        if (['ADMIN', 'OPERATIONS'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return FeeService.extendDue(user, payload, requestId);

      case 'getExpenses':
        if (['SALES_EXECUTIVE', 'STAFF'].indexOf(user.role) !== -1) return Router.unauthorized(requestId);
        return ExpenseService.getExpenses(user, payload, requestId);

      case 'recordExpense':
        if (['SALES_EXECUTIVE'].indexOf(user.role) !== -1) return Router.unauthorized(requestId);
        return ExpenseService.recordExpense(user, payload, requestId);

      case 'submitStaffDuty':
        if (['STAFF', 'ADMIN', 'HR'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return DutyService.submitDuty(user, payload, requestId);

      case 'getStaffDuties':
        return DutyService.getDuties(user, payload, requestId);

      case 'verifyStaffDuty':
        if (['HR', 'ADMIN'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return DutyService.verifyDuty(user, payload, requestId);

      case 'setupDatabase':
        if (user.role !== 'ADMIN') return Router.unauthorized(requestId);
        return Setup.provisionDatabase(requestId);

      default:
        return {
          success: false,
          errorCode: 'INVALID_ACTION',
          message: 'Unknown API action: ' + action,
          requestId: requestId,
          timestamp: timestamp
        };
    }
  },

  unauthorized: function(requestId) {
    return {
      success: false,
      errorCode: 'FORBIDDEN',
      message: 'You do not have permission to execute this operation.',
      requestId: requestId,
      timestamp: new Date().toISOString()
    };
  }
};
