<%@ page import="org.json.JSONObject" contentType="application/json; charset=UTF-8" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setHeader("Cache-Control", "no-cache");
if (session.getAttribute("userId") == null) {
    out.print("{\"error\":\"Session expired\"}");
    return;
}

String billNo = request.getParameter("billNo");
if (billNo == null || billNo.trim().isEmpty()) {
    out.print("{\"error\":\"Missing billNo\"}");
    return;
}

try {
    JSONObject summary = bill.getBillPaymentSummary(billNo.trim());
    out.print(summary.toString());
} catch (Exception e) {
    out.print("{\"error\":\"" + (e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Failed to load payment summary") + "\"}");
}
%>
