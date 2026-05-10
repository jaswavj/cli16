<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());

// Get first day of current month
Calendar cal = Calendar.getInstance();
cal.set(Calendar.DAY_OF_MONTH, 1);
String firstDayOfMonth = new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profit & Loss Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
    <h3 class="mb-4">Profit & Loss Report</h3>

    <form action="<%=contextPath%>/reports/profitLoss/page0.jsp" method="post" class="row g-3">
        <!-- From Date -->
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=firstDayOfMonth%>" class="form-control" required>
        </div>

        <!-- To Date -->
        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- Report Type -->
        <div class="col-md-3">
            <label for="reportType" class="form-label">Report Type:</label>
            <select id="reportType" name="reportType" class="form-select">
                <option value="summary">Summary Report</option>
                <option value="productwise">Product Wise Report</option>
                <option value="detailed">Detailed Report</option>
            </select>
        </div>

        <!-- Submit -->
        <div class="col-md-3 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">Generate Report</button>
        </div>
    </form>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        attachDataUrlHandlers(document);
        attachAjaxForms(document);
    });
</script>

</body>
</html>