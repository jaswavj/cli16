<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%

	String newCategory=request.getParameter("newCategory");
	int categoryId 		   = Integer.parseInt(request.getParameter("categoryId"));
	String block=request.getParameter("block");
	if(block!=null)
	{
	
	prod.blockCategory(categoryId);
	response.sendRedirect(request.getContextPath() + "/product/master/batch/category.jsp");

	}
	else{
		try
			{	
			int prodId	= prod.checkTheCateNameExist(newCategory);
			if (prodId != 0) 
			{
			out.println("<script type='text/javascript'>");
			out.println("alert('CATEGORY NAME ALREADY EXISTS');");
			out.println("window.location.href = '" + request.getContextPath() + "/product/master/batch/category.jsp';");
			out.println("</script>");
			return;
			}
				else
					{
					prod.editCategory(categoryId,newCategory);	
					response.sendRedirect(request.getContextPath() + "/product/master/batch/category.jsp");
					}
			}
		catch (Exception e)
			{
			out.print("<b><br><br><br><br><br><br><br><center>Error Occured In Updating Category </center></b>"+e);
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