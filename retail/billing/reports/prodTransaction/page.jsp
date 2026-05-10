<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
Vector productList = prod.getAllProduct(); 
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Brands - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
<%@ include file="/assets/common/head.jsp" %>

</head>
<body onload="document.form.opregInput.focus();">

    <!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h3 class="mb-4">Collection Report Filter</h3>

    <form action="<%=contextPath%>/reports/prodTransaction/page0.jsp" method="get" class="row g-3">
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>

        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>
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

        <div class="col-md-3 d-flex align-items-end">
            <button type="submit" class="btn btn-primary w-100">Generate Report</button>
        </div>
    </form>
</div>
    <!-- Bootstrap JS -->
<script>
    document.addEventListener("DOMContentLoaded", function () {
    attachDataUrlHandlers(document);  // for <a data-url>
    attachAjaxForms(document);        // for <form class="ajax-form">
});

</script>
</body>
</html>
