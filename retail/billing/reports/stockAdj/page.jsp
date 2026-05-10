<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());

// Fetch product list for dropdown
Vector productList = prod.getAllProduct(); 
// (Assuming productBean has a method getAllProducts() returning Vector<Vector> with id + name)
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stock Adjustment Report Filter</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>

<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4 ">
    <h3 class="mb-4">Stock Adjustment Report Filter</h3>

    <form action="<%=contextPath%>/reports/stockAdj/page0.jsp" method="post" class="row g-3">
        <!-- From Date -->
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- To Date -->
        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- Product -->
        <div class="col-md-3">
            <label for="productId" class="form-label"><%=head3%>:</label>
            <select id="productId" name="productId" class="form-select">
                <option value="">-- All <%=head3%> --</option>
                <%
                    for(int i=0; i<productList.size(); i++){
                        Vector row = (Vector) productList.elementAt(i);
                        String pid = row.get(0).toString();
                        String  pname= row.get(1).toString();
                %>
                    <option value="<%=pid%>"><%=pname%></option>
                <%
                    }
                %>
            </select>
        </div>

        <!-- Stock Type Filter -->
        <div class="col-md-3">
            <label for="stockType" class="form-label">Stock Type:</label>
            <select id="stockType" name="stockType" class="form-select">
                <option value="">-- All Types --</option>
                <option value="1">Stock Add</option>
                <option value="2">Stock Remove</option>
                <option value="3">Damage</option>
                <option value="4">Internal Use</option>
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
    attachDataUrlHandlers(document);  // for <a data-url>
    attachAjaxForms(document);        // for <form class="ajax-form">
});

</script>
</body>
</html>
