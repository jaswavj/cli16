<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String catName = request.getParameter("catName");

try {
    int prodId = prod.checkTheBrandsNameExist(catName);

    if (prodId != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/brands/brands.jsp?msg=Brand+name+already+exists!&type=warning");
        return;
    } else {
        prod.AddBrands(catName);
        response.sendRedirect(request.getContextPath() + "/product/master/brands/brands.jsp?msg=Brand+added+successfully!&type=success");
        return;
    }
} catch (Exception e) {
    response.sendRedirect(
        "brands.jsp?msg=Error+occurred+while+inserting+brand:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Products - Billing App</title>
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
<p align="center"><b><font size="6" face="Garamond" color="#000080">Successfully Added .&nbsp; .&nbsp; .&nbsp; .</font></b></p>

<p align="center"><font size="6"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</b></font><font face="Batang"><a class=mainlevel href="brands.jsp">Back</a></font></p>



</body>

</html>