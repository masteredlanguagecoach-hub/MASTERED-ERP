/**
 * MASTERED ERP v9.0 — Router (Router.gs)
 * Action routing and role permission enforcement across all 12 roles
 */

var Router = {
  routeAction: function(action, sessionToken, requestId, payload) {
    var timestamp = new Date().toISOString();

    if (action === 'healthCheck') {
      return {
        success: true,
        message: 'MASTERED ERP v9.0 Backend API operational',
        data: { apiVersion: '9.0.0', status: 'HEALTHY' },
        requestId: requestId,
        timestamp: timestamp
      };
    }

    if (action === 'login') {
      return AuthService.login(payload.email, payload.password, requestId);
    }

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

    switch (action) {
      case 'testConnectionsAdmin':
        if (['ADMIN', 'FOUNDER', 'COE'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return SheetRepository.testConnectionsAdmin(requestId);

      case 'getKpiDefinitions':
        return KpiEngine.getDefinitions(user, payload, requestId);

      case 'submitKpiEvidence':
        return KpiEngine.submitEvidence(user, payload, requestId);

      case 'auditKpi':
        if (['GROWTH_OFFICER', 'ADMIN', 'FOUNDER'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return KpiEngine.auditKpi(user, payload, requestId);

      case 'approveKpiAudit':
        if (['FOUNDER', 'ADMIN'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return KpiEngine.approveAndLockAudit(user, payload, requestId);

      case 'getPlacements':
        return PlacementService.getPlacements(user, payload, requestId);

      case 'recordPlacement':
        if (['SALES_HEAD', 'ADMIN', 'FOUNDER'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return PlacementService.recordPlacement(user, payload, requestId);

      case 'submitStaffDuty':
        return DutyService.submitDuty(user, payload, requestId);

      case 'getStaffDuties':
        return DutyService.getDuties(user, payload, requestId);

      case 'verifyStaffDuty':
        if (['HR', 'ADMIN', 'FOUNDER'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
        return DutyService.verifyDuty(user, payload, requestId);

      case 'setupDatabase':
        if (['ADMIN', 'FOUNDER'].indexOf(user.role) === -1) return Router.unauthorized(requestId);
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
