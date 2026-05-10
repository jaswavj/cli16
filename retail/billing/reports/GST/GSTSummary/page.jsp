<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GST Sales Report</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-5">
    <h2 class="text-center mb-4">GST Summary</h2>
    <form action="<%=contextPath%>/reports/GST/GSTSummary/page1.jsp" method="get" class="row g-3 mb-4">
        <div class="col-md-4">
            <label for="startDate" class="form-label">Start Date</label>
            <input type="date" class="form-control" value="<%=today%>" id="startDate" name="startDate" required>
        </div>
        <div class="col-md-4">
            <label for="endDate" class="form-label">End Date</label>
            <input type="date" class="form-control" value="<%=today%>" id="endDate" name="endDate" required>
        </div>
        <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">Filter</button>
        </div>
    <!-- Filter Section -->
    

</div>



</body>
</html>
