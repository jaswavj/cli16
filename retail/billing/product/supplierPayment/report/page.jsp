<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
String contextPath = request.getContextPath();
    Integer uidObj = (Integer) session.getAttribute("userId");
    if (uidObj == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    int uid = uidObj.intValue();
    String userNameUni = (String) session.getAttribute("userName");
    String today = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html>
<head>
    <title>Supplier Payment Report</title>
    <jsp:include page="../../../assets/common/head.jsp" />
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
    </style>
</head>
<body>
    <jsp:include page="../../../assets/navbar/navbar.jsp" />
    
    <div class="container mt-4">
        <h3 class="mb-4">Supplier Payment Report</h3>
        
        <form action="<%=contextPath%>/product/supplierPayment/report/page0.jsp" method="get" class="row g-3">
            <div class="col-md-3">
                <label for="fromDate" class="form-label">From Date:</label>
                <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
            </div>
            
            <div class="col-md-3">
                <label for="toDate" class="form-label">To Date:</label>
                <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
            </div>
            
            <div class="col-md-3">
                <label for="supplierId" class="form-label">Supplier:</label>
                <select name="supplierId" class="form-select">
                    <option value="0">All Suppliers</option>
                    <%
                        Vector suppliers = productBean.GetSupplier();
                        for (int i = 0; i < suppliers.size(); i++) {
                            Vector suppRow = (Vector) suppliers.elementAt(i);
                            int supId = Integer.parseInt(suppRow.elementAt(0).toString());
                            String supName = suppRow.elementAt(1).toString();
                    %>
                    <option value="<%=supId%>"><%=supName%></option>
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
</body>
</html>
