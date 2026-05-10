<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String contextPath = request.getContextPath();
	String custName = request.getParameter("custName");
	String custPhn = request.getParameter("custPhn");
	String custAddress = request.getParameter("custAddress");
	String gstin = request.getParameter("gstin");
	String isGstParam = request.getParameter("isGst");
	String isEligibleForCommissionParam = request.getParameter("isEligibleForCommission");
	int id = Integer.parseInt(request.getParameter("customerId"));
	String block = request.getParameter("block");
	
	int isGst = (isGstParam != null && isGstParam.equals("1")) ? 1 : 0;
	int isEligibleForCommission = (isEligibleForCommissionParam != null && isEligibleForCommissionParam.equals("1")) ? 1 : 0;
	
	if (gstin == null) gstin = "";
	if (custAddress == null) custAddress = "";
	if (custPhn == null) custPhn = "";
	
	if(block != null)
	{
		prod.blockCustomer(id);
		response.sendRedirect(request.getContextPath() + "/product/master/customer/page.jsp?msg=Customer+blocked+successfully&type=success");
	}
	else{
		try
			{	
			int custId	= prod.checkTheCustomerNameExist(custName, id);
			if (custId != 0) 
			{
				response.sendRedirect(request.getContextPath() + "/product/master/customer/page.jsp?msg=Customer+name+already+exists&type=warning");
				return;
			}
			else
			{
				prod.editCustomer(id, custName, custPhn, custAddress, gstin, isGst, isEligibleForCommission);	
				response.sendRedirect(request.getContextPath() + "/product/master/customer/page.jsp?msg=Customer+updated+successfully&type=success");
			}
		}
		catch (Exception e)
		{
			response.sendRedirect(request.getContextPath() + "/product/master/customer/page.jsp?msg=Error+occurred+while+updating+customer&type=danger");
			return;
		} 			 
	}
%>
<html>
<head>
    <meta charset="UTF-8">
    <title>Customer - Billing App</title>
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
<p align="center"><b><font size="6" face="Garamond" color="#000080">Successfully Saved .&nbsp; .&nbsp; .&nbsp; .</font></b></p>
<%
out.print(custName +"<br>"+custAddress+"<br>"+custPhn);
%>
<p align="center"><font size="6"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="<%=contextPath%>/product/master/customer/page.jsp">Continue</a></b></font></p>

</body>
</html>
