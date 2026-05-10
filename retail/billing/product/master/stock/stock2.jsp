<%@page language="java" import="java.util.*, java.math.BigDecimal" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String contextPath = request.getContextPath();
Integer uid = (Integer) session.getAttribute("userId");

String prodName = request.getParameter("catName");
int prodId = Integer.parseInt(request.getParameter("catId"));
String reason = request.getParameter("reason");
String reasonCategory = request.getParameter("reasonCategory");
if(reasonCategory == null) reasonCategory = "";

BigDecimal curStock = new BigDecimal(request.getParameter("curStock"));
int proBatch = Integer.parseInt(request.getParameter("proBatch"));

int discType = Integer.parseInt(request.getParameter("discType"));
BigDecimal discValue = new BigDecimal(request.getParameter("discValue"));

// Convert quantity if unit has a conversion calculation
String convertionCalcStr = request.getParameter("convertionCalculation");
if (convertionCalcStr != null && !convertionCalcStr.trim().isEmpty()) {
    try {
        BigDecimal convertionCalc = new BigDecimal(convertionCalcStr.trim());
        if (convertionCalc.compareTo(BigDecimal.ZERO) > 0) {
            discValue = discValue.multiply(convertionCalc);
        }
    } catch (NumberFormatException e) { /* ignore */ }
}

// Append reason category to reason for Damage and Internal Use
String fullReason = reason;
if((discType == 3 || discType == 4) && !reasonCategory.isEmpty()) {
    fullReason = "[" + reasonCategory + "] " + reason;
}

if(discType==1){
    prod.addProductStock(prodId,discValue,fullReason,curStock,proBatch,discType,uid);
}
else if(discType==2){
    prod.removeProductStock(prodId,discValue,fullReason,curStock,proBatch,discType,uid);
}
else if(discType==3){
    prod.removeStockForDamage(prodId,discValue,fullReason,curStock,proBatch,discType,uid);
}
else if(discType==4){
    prod.removeStockForInternalUse(prodId,discValue,fullReason,curStock,proBatch,discType,uid);
}
response.sendRedirect(request.getContextPath() + "/product/master/stock/stock.jsp");

   
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Product - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <link href="../../../dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p align="center"><b><font size="6" face="Garamond" color="#000080">
        Successfully Added batch . . . 
    </font></b></p>

    <p align="center">
        <font face="Batang"><a class=mainlevel href="stock.jsp">Back</a></font>
    </p>
</body>
</html>
