<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String newCategory = request.getParameter("newCategory");
int categoryId = Integer.parseInt(request.getParameter("categoryId"));
String block = request.getParameter("block");

if (block != null) {
    prod.blockCategory(categoryId);
    response.sendRedirect(request.getContextPath() + "/product/master/category/category.jsp?msg=Object+blocked+successfully&type=info");
    return;
}

try {
    int prodId = prod.checkTheCateNameExist(newCategory);

    if (prodId != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/category/category.jsp?msg=Object+name+already+exists!&type=warning");
        return;
    }

    prod.editCategory(categoryId, newCategory);
    response.sendRedirect(request.getContextPath() + "/product/master/category/category.jsp?msg=Object+updated+successfully!&type=success");
} catch (Exception e) {
    response.sendRedirect(
        "category.jsp?msg=Error+occurred+while+updating+Object:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>

<html>
<head>
    <meta charset="UTF-8">
    <title> Billing App</title>
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
</b></font><font face="Batang"><a class=mainlevel href="category.jsp">Back</a></font></p>



</body>

</html>