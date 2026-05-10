<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%

	String supName=request.getParameter("supName");
	String supPhn=request.getParameter("supPhn");
	String supDesc=request.getParameter("supDesc");
	String gstin=request.getParameter("gstin");
	String isGstParam = request.getParameter("isGst");
	int isGst = (isGstParam != null && isGstParam.equals("on")) ? 1 : 0;
	int id 		   = Integer.parseInt(request.getParameter("id"));
	String block=request.getParameter("block");
	if(block!=null)
	{
	
	prod.blockSupplier(id);
	response.sendRedirect(request.getContextPath() + "/product/master/supplier/page.jsp");

	}
	else{
		try
			{	
			int prodId	= prod.checkTheSuppNameExist(supName, id);
			if (prodId != 0) 
			{
			out.println("<script type='text/javascript'>");
			out.println("alert('SUPPLIER NAME ALREADY EXISTS');");
			out.println("window.location.href = '" + request.getContextPath() + "/product/master/supplier/page.jsp';");
			out.println("</script>");
			return;
			}
				else
					{
					prod.editSupplier(id,supName,supPhn,supDesc,gstin,isGst);	
					response.sendRedirect(request.getContextPath() + "/product/master/supplier/page.jsp");
					}
			}
		catch (Exception e)
			{
			out.print("<b><br><br><br><br><br><br><br><center>Error Occured In Updating supplier </center></b>"+e);
			return;
			} 			 
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

<p align="center"><font size="6"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
</b></font><font face="Batang"><a class=mainlevel href="category.jsp">Back</a></font></p>



</body>

</html>