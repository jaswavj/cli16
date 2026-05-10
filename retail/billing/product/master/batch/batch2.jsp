<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String catName = request.getParameter("catName");
int catId = Integer.parseInt(request.getParameter("catId"));
String batchName = request.getParameter("batchName");
double cost = Double.parseDouble(request.getParameter("cost"));
double mrp = Double.parseDouble(request.getParameter("mrp"));



int discType = Integer.parseInt(request.getParameter("discType"));

String discParam = request.getParameter("discValue");
double discValue = 0.00;
if (discParam != null && !discParam.trim().isEmpty()) {
    try {
        discValue = Double.parseDouble(discParam);
<%@ page import="java.math.BigDecimal" %>
<%
    } catch (NumberFormatException e) {
        discValue = 0.00;
    }
}

BigDecimal stock = new BigDecimal(request.getParameter("stock"));


try {
    // Check if product name already exists
    int existingbatchId = prod.checkTheBatchNameExist(batchName);

    if (existingbatchId != 0) {
        // Product already exists
        out.print("<b><br><br><br><br><br><br><br><center>BATCH NAME ALREADY EXISTS</center></b>");
        out.print("<p align='center'><a class=mainlevel href='batch1.jsp?catName=" + catName + "&catId=" + catId + "'>Back</a></p>");
        return;
    }
     else {
        // Add new product
        prod.addBatch(batchName,catId,cost,mrp,discType,discValue,stock );
        response.sendRedirect(request.getContextPath() + "/product/master/batch/batch.jsp");
    }
} catch (Exception e) {
    out.print("<b><br><br><br><br><br><br><br><center>Error Occurred While Adding Product</center></b><br>" + e);
    return;
}
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

    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p align="center"><b><font size="6" face="Garamond" color="#000080">
        Successfully Added batch . . . 
    </font></b></p>

    <p align="center">
        <font face="Batang"><a class=mainlevel href="batch.jsp">Back</a></font>
    </p>
</body>
</html>
