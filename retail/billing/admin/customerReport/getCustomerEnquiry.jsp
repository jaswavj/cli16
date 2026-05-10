<%@ page import="org.json.JSONArray, org.json.JSONObject" contentType="application/json; charset=UTF-8" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setHeader("Cache-Control", "no-cache");
if (session.getAttribute("userId") == null) {
    out.print("{\"error\":\"Session expired\"}");
    return;
}

String customerIdStr = request.getParameter("customerId");
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");

if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
    out.print("{\"error\":\"Missing customerId\"}");
    return;
}

int customerId;
try {
    customerId = Integer.parseInt(customerIdStr.trim());
} catch (NumberFormatException e) {
    out.print("{\"error\":\"Invalid customerId\"}");
    return;
}

try {
    JSONArray rows = bill.getCustomerEnquiry(customerId, fromDate, toDate);
    JSONObject outJson = new JSONObject();
    outJson.put("rows", rows);
    out.print(outJson.toString());

} catch (Exception e) {
    out.print("{\"error\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Failed to load customer enquiry") + "\"}");
}
%>
