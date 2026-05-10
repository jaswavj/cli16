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
    <title> Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
<%@ include file="/assets/common/head.jsp" %>
    

    <style>
        body {
            background: #f5f7fa;
        }
        .navbar {
            background-color: #4e73df;
        }
        .navbar-brand {
            color: #fff !important;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        .btn-edit, .btn-delete {
            margin: 0 2px;
        }

    </style>

</head>
<body onload="document.form.opregInput.focus();">

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h3 class="mb-4">Collection Report by Customer</h3>

    <form action="<%=contextPath%>/reports/salesByCustomer/page0.jsp" method="get" class="row g-3">
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>

        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>
        <div class="col-md-3">
            <label for="fromDate" class="form-label">Customer:</label>
            <select name="customerId" class="form-select" required>
                <option value="">Select Customer</option>
                <%
                    Vector customers = prod.getCustomerDetails();
                    for (int i = 0; i < customers.size(); i++) {
                        Vector cust = (Vector) customers.get(i);
                        String customerName = cust.elementAt(0).toString();
                        String customerId = cust.elementAt(1).toString();
                %>
                    <option value="<%=customerId%>"><%=customerName%></option>
                <% } %>
            </select>
        </div>
        

        <div class="col-md-4 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">Generate Report</button>
        </div>
    </form>
</div>
    <!-- Bootstrap JS -->

</body>
</html>
