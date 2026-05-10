<%@ page import="java.sql.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

try {
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"success\":false,\"message\":\"Session expired\"}");
        return;
    }

    String billIdStr = request.getParameter("billId");
    String deliveryPlace = request.getParameter("deliveryPlace");
    String deliveredDate = request.getParameter("deliveredDate");
    String deliveryPerson = request.getParameter("deliveryPerson");

    if (billIdStr == null || billIdStr.trim().isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"success\":false,\"message\":\"Bill ID is required\"}");
        return;
    }

    int billId = Integer.parseInt(billIdStr);
    String result = bill.markBillDelivered(billId, deliveryPlace, deliveredDate, deliveryPerson);
    if ("SUCCESS".equals(result)) {
        out.print("{\"success\":true,\"message\":\"Marked as delivered successfully\"}");
    } else {
        out.print("{\"success\":false,\"message\":\"" + result.replace("\"", "'") + "\"}");
    }
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    String errMsg = (e.getMessage() != null) ? e.getMessage().replace("\"", "'") : "Internal server error";
    out.print("{\"success\":false,\"message\":\"" + errMsg + "\"}");
}
%>
