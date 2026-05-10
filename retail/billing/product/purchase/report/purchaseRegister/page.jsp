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
    <title>Billing App</title>
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

    <!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h3 class="mb-4">Purchase Report</h3>

    <form action="<%=contextPath%>/product/purchase/report/purchaseRegister/page0.jsp" method="get" class="row g-3">
        <div class="col-md-3">
            <label for="fromDate" class="form-label">From Date:</label>
            <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
        </div>

        <div class="col-md-3">
            <label for="toDate" class="form-label">To Date:</label>
            <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
        </div>
        <div class="col-md-3">
            <label for="fromDate" class="form-label">Supplier:</label>
            <select name="supId" class="form-select" >
                <option value="0">Select Supplier</option>
                <%
                    Vector vec		= prod.GetSupplier();
                    ///////////////Supplier////////
                    for(int n=0;n< vec.size();n++)
                        {
                        Vector sub	 	= (Vector)vec.elementAt(n);
                        int ID			= Integer.parseInt(sub.elementAt(0).toString());
                        String name 	= sub.elementAt(1).toString();
                %>
                    <option value="<%=ID%>"><%=name%></option>
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
