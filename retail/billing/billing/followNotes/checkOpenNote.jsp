<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    try {
        String customerIdStr = request.getParameter("customerId");
        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            out.print(new JSONObject().put("hasOpen", false).toString());
            return;
        }

        int customerId;
        try { customerId = Integer.parseInt(customerIdStr.trim()); }
        catch (NumberFormatException e) {
            out.print(new JSONObject().put("hasOpen", false).toString());
            return;
        }
        JSONObject result = bill.checkOpenFollowNote(customerId);
        out.print(result.toString());
    } catch (Exception e) {
        out.print(new JSONObject().put("hasOpen", false).toString());
    }
%>
