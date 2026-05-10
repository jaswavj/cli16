<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String billIdParam = request.getParameter("billId");
String newDate = request.getParameter("newDate");
String returnUrl = request.getParameter("returnUrl");
int uid = (Integer)session.getAttribute("userId");

String message = "";
String messageType = "danger";

if (billIdParam != null && newDate != null) {
    try {
        int billId = Integer.parseInt(billIdParam);
        boolean success = bill.updateBillDate(billId, newDate, uid);
        
        if (success) {
            message = "Bill date updated successfully!";
            messageType = "success";
        } else {
            message = "Failed to update bill date.";
        }
    } catch (Exception e) {
        message = "Error: " + e.getMessage();
    }
} else {
    message = "Invalid parameters.";
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Update Bill Date</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
    <div class="alert alert-<%= messageType %>">
        <%= message %>
    </div>
    
    <% if (returnUrl != null && !returnUrl.isEmpty()) { %>
        <a href="<%= returnUrl %>" class="btn btn-primary">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    <% } else { %>
        <a href="<%= request.getContextPath() %>/admin/editBill/edit.jsp?billId=<%= billIdParam %>" class="btn btn-primary">
            <i class="fas fa-arrow-left"></i> Back to Bill Details
        </a>
        <a href="<%= request.getContextPath() %>/admin/editBill/changeBillDate.jsp" class="btn btn-secondary">
            <i class="fas fa-search"></i> Change Bill Date
        </a>
    <% } %>
</div>

</body>
</html>
