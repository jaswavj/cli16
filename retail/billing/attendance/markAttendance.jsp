<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
String action = request.getParameter("action");

if (uid == null || action == null) {
    out.print("{\"success\":false, \"message\":\"Invalid request\"}");
    return;
}

if (!action.equals("in") && !action.equals("out")) {
    out.print("{\"success\":false, \"message\":\"Invalid action\"}");
    return;
}

try {
    java.util.Map<String, Object> result = bill.markAttendance(uid, action);
    
    org.json.JSONObject json = new org.json.JSONObject();
    json.put("success", (Boolean) result.get("success"));
    if ((Boolean) result.get("success")) {
        json.put("time", result.get("time"));
    } else {
        json.put("message", result.get("message"));
    }
    out.print(json.toString());
} catch (Exception e) {
    out.print("{\"success\":false, \"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
}
%>
