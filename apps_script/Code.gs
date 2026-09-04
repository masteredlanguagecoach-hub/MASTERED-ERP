/**
 * MASTERED ERP v8.0 — Main Entry Point (Code.gs)
 * Web App HTTP Request Handlers
 */

function doGet(e) {
  return handleHttpRequest('GET', e);
}

function doPost(e) {
  return handleHttpRequest('POST', e);
}

function handleHttpRequest(method, e) {
  try {
    var rawPayload = {};
    if (e && e.postData && e.postData.contents) {
      try {
        rawPayload = JSON.parse(e.postData.contents);
      } catch (err) {
        rawPayload = {};
      }
    } else if (e && e.parameter) {
      rawPayload = e.parameter;
    }

    var action = rawPayload.action || (e && e.parameter ? e.parameter.action : '') || 'healthCheck';
    var sessionToken = rawPayload.sessionToken || (e && e.parameter ? e.parameter.sessionToken : '');
    var requestId = rawPayload.requestId || 'REQ-' + Math.floor(Date.now() * Math.random());
    var payload = rawPayload.payload || rawPayload;

    var response = Router.routeAction(action, sessionToken, requestId, payload);
    
    return ContentService
      .createTextOutput(JSON.stringify(response))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    var errorResponse = {
      success: false,
      errorCode: 'SERVER_ERROR',
      message: error.toString(),
      requestId: (e && e.parameter && e.parameter.requestId) ? e.parameter.requestId : 'REQ-ERR',
      timestamp: new Date().toISOString()
    };
    return ContentService
      .createTextOutput(JSON.stringify(errorResponse))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
