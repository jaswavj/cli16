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
    <title>CASH BANK</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>

<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4 ">
    <h3 class="mb-4">Edit Bill</h3>

    <form action="<%=contextPath%>/admin/editBill/page0.jsp" method="post" class="row g-3">
        <!-- From Date -->
        <div class="col-md-2">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- To Date -->
        <div class="col-md-2">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>

        <!-- Product -->
        <!-- Mode -->
<!--div class="col-md-2">
    <label for="mode" class="form-label">Select Mode:</label>
    <select id="mode" name="mode" class="form-select">
        <option value="0">-- All Mode --</option>
        <option value="1">Cash</option>
        <option value="2">Bank</option>
        
    </select>
</div>


<div class="col-md-2">
    <label for="type" class="form-label">Select Type:</label>
    <select id="type" name="type" class="form-select" disabled>
        <option value="0">-- All Type --</option>
        <option value="1">UPI</option>
        <option value="2">Debit Card</option>
        <option value="3">Credit Card</option>
        <option value="4">Net Banking</option>
        <option value="5">Wallet</option>
    </select>
</div-->
<div class="col-md-2">
    <label for="mode" class="form-label">Select User:</label>
    <select name="userId" class="form-select" required>
            <option value="0">-- All User --</option>
            <%
            Vector userList = prod.getAllUser(); 

            for(int i=0; i<userList.size(); i++){
                Vector row = (Vector) userList.elementAt(i);
                String userId = row.get(0).toString();
                String  uname= row.get(1).toString();
        %>
            <option value="<%=userId%>"><%=uname%></option>
        <%
            }
        %>
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
<script>
    document.getElementById("mode").addEventListener("change", function () {
    const mode = this.value;
    const typeSelect = document.getElementById("type");

    if (mode === "1") {
        // Cash → disable Type
        typeSelect.disabled = true;
        typeSelect.value = 0;
    } 
    else if (mode === "2" || mode === "3") {
        // Bank or Mixed → enable Type & auto-select UPI
        typeSelect.disabled = false;
        typeSelect.value = 0;
    } 
    else {
        // Reset
        typeSelect.disabled = true;
        typeSelect.value = "";
    }
});

</script>

</body>
</html>
