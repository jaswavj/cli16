<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String supName = request.getParameter("supName");
String supDesc = request.getParameter("supDesc");
String supPhn  = request.getParameter("supPhn");
String gstin   = request.getParameter("gstin");
String isGstParam = request.getParameter("isGst");
int isGst = (isGstParam != null && isGstParam.equals("on")) ? 1 : 0;

try {
    int existing = prod.checkTheSupNameExist(supName);

    if (existing != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/supplier/page.jsp?msg=Supplier+name+already+exists!&type=warning");
        return;
    }

    prod.AddSupplier(supName, supDesc, supPhn, gstin, isGst);
    response.sendRedirect(request.getContextPath() + "/product/master/supplier/page.jsp?msg=Supplier+added+successfully!&type=success");

} catch (Exception e) {
    response.sendRedirect(
        "page.jsp?msg=Error+occurred+while+adding+supplier:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
}
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Category - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <link href="../dist/css/bootstrap.min.css" rel="stylesheet">
    
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p align="center"><b><font size="6" face="Garamond" color="#000080">Successfully Added .&nbsp; .&nbsp; .&nbsp; .</font></b></p>
<%
out.print(supName +"<br>"+supDesc+"<br>"+supPhn);
%>
<p align="center"><font size="6"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</b></font><font face="Batang"><a class=mainlevel href="category.jsp">Back</a></font></p>



</body>

</html>