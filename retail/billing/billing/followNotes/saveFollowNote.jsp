<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    try {
        request.setCharacterEncoding("UTF-8");
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) {
            out.print(new JSONObject().put("success", false).put("message", "Session expired. Please login again.").toString());
            return;
        }

        JSONObject result = bill.saveFollowNote(
            request.getParameter("customerName"),
            request.getParameter("customerPhn"),
            request.getParameter("customerId"),
            request.getParameter("description"),
            uid
        );
        out.print(result.toString());
    } catch (Exception e) {
        out.print(new JSONObject().put("success", false).put("message", "Error: " + e.getMessage()).toString());
    }
%>
