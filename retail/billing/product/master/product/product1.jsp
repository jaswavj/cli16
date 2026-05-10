<%@page language="java" import="java.util.*, java.math.BigDecimal" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
Integer userId = (Integer) session.getAttribute("userId");
String productName = request.getParameter("productName");
String categoryId = request.getParameter("categoryId");
String brandId = request.getParameter("brandId");
String productCode = request.getParameter("productCode");
if (productCode == null || productCode.trim().isEmpty()) {
    productCode = "0";
}
int unitId = Integer.parseInt(request.getParameter("unitId"));
String hsn = request.getParameter("hsn");
if (hsn != null && hsn.trim().isEmpty()) {
    hsn = null;
}
double cost = Double.parseDouble(request.getParameter("cost"));
double mrp = Double.parseDouble(request.getParameter("mrp"));
int gst = Integer.parseInt(request.getParameter("gst"));

String commissionParam = request.getParameter("commission");
double commission = 0.0;
if (commissionParam != null && !commissionParam.trim().isEmpty()) {
    try { commission = Double.parseDouble(commissionParam); } catch (NumberFormatException e) { commission = 0.0; }
}

int discType = Integer.parseInt(request.getParameter("discType"));
String discParam = request.getParameter("discValue");
double discValue = 0.00;

if (discParam != null && !discParam.trim().isEmpty()) {
    try {
        discValue = Double.parseDouble(discParam);
    } catch (NumberFormatException e) {
        discValue = 0.00;
    }
}

BigDecimal stock = new BigDecimal(request.getParameter("stock"));

// Convert stock, cost, mrp, and commission when unit has conversion setup.
Vector selectedUnit = prod.getUnitById(unitId);
if (selectedUnit != null && selectedUnit.size() > 3 && selectedUnit.elementAt(3) != null) {
    BigDecimal convertionCalculation = (BigDecimal) selectedUnit.elementAt(3);
    if (convertionCalculation.compareTo(BigDecimal.ZERO) > 0) {
        stock = stock.multiply(convertionCalculation);
        BigDecimal calcBD = convertionCalculation;
        cost = new BigDecimal(cost).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
        mrp = new BigDecimal(mrp).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
        commission = new BigDecimal(commission).divide(calcBD, 6, java.math.RoundingMode.HALF_UP).doubleValue();
    }
}

try {
    int existingProdId = prod.checkTheProductNameExist(productName);
    int existingCodeId = prod.checkTheProductCodeExist(productCode);

    /*if (existingProdId != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/product/product.jsp?msg=Product+name+already+exists!&type=warning");
        return;
    }

    if (existingCodeId != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/product/product.jsp?msg=Product+code+already+exists!&type=warning");
        return;
    }*/

    prod.addProduct(
        productName,
        Integer.parseInt(categoryId),
        Integer.parseInt(brandId),
        productCode,
        cost,
        mrp,
        discType,
        discValue,
        stock,
        userId,
        gst,
        unitId,
        hsn,
        commission
    );

    response.sendRedirect(request.getContextPath() + "/product/master/product/product.jsp?msg=Product+added+successfully!&type=success");
} catch (Exception e) {
    response.sendRedirect(
        "product.jsp?msg=Error+occurred+while+adding+product:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>


<html>
<head>
    <meta charset="UTF-8">
    <title>Product - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <link href="../dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>

    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p align="center"><b><font size="6" face="Garamond" color="#000080">
        Successfully Added Product . . . 
    </font></b></p>
    <table border="1">
        <tr>
            <td colspan="8">For checking the value from prev Page</td>
        </tr>
        <tr>
            <td>userId=<%=userId%></td>
            <td>productName=<%=productName%></td>
            <td>categoryId=<%=categoryId%></td>
            <td>brandId=<%=brandId%></td>
            <td>productCode=<%=productCode%></td>
            <td>cost=<%=cost%></td>
            <td>mrp=<%=mrp%></td>
            <td>discType=<%=discType%></td>
            <td>discValue=<%=discValue%></td>
            <td>stock=<%=stock%></td>
        </tr>
    </table>

    <p align="center">
        <font face="Batang"><a class=mainlevel href="products.jsp">Back</a></font>
    </p>
</body>
</html>
