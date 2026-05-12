<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    out.print("{\"hasEntry\":false}");
    return;
}

try {
    java.util.Map<String, Object> result = bill.checkAttendance(uid);
    
    org.json.JSONObject json = new org.json.JSONObject();
    json.put("hasEntry", (Boolean) result.get("hasEntry"));
    if ((Boolean) result.get("hasEntry")) {
        json.put("inTime", result.get("inTime") != null ? result.get("inTime").toString() : "");
        json.put("outTime", result.get("outTime") != null ? result.get("outTime").toString() : "");
    }
    out.print(json.toString());
} catch (Exception e) {
    out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
}
%>
