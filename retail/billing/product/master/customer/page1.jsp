<%@page language="java" import="java.util.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
String contextPath = request.getContextPath();
String custName = request.getParameter("custName");
String custAddress = request.getParameter("custAddress");
String custPhn  = request.getParameter("custPhn");
String gstin   = request.getParameter("gstin");
String isGstParam = request.getParameter("isGst");
String isEligibleParam = request.getParameter("isEligibleForCommission");

int isGst = (isGstParam != null && isGstParam.equals("1")) ? 1 : 0;
int isEligibleForCommission = (isEligibleParam != null && isEligibleParam.equals("1")) ? 1 : 0;

if (gstin == null) gstin = "";
if (custAddress == null) custAddress = "";
if (custPhn == null) custPhn = "";

try {
    int existing = prod.checkTheCustomerNameExist(custName);

    if (existing != 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/customer/page.jsp?msg=Customer+name+already+exists!&type=warning");
        return;
    }

    prod.AddCustomer(custName, custAddress, custPhn, gstin, isGst, isEligibleForCommission);
    response.sendRedirect(request.getContextPath() + "/product/master/customer/page.jsp?msg=Customer+added+successfully!&type=success");

} catch (Exception e) {
    response.sendRedirect(
        "page.jsp?msg=Error+occurred+while+adding+customer:+"
        + java.net.URLEncoder.encode(e.getMessage(), "UTF-8")
        + "&type=danger"
    );
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
<p align="center"><b><font size="6" face="Garamond" color="#000080">Successfully Added .&nbsp; .&nbsp; .&nbsp; .</font></b></p>
<%
out.print(custName +"<br>"+custAddress+"<br>"+custPhn);
%>
<p align="center"><font size="6"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <a href="<%=contextPath%>/product/master/customer/page.jsp">Continue</a></b></font></p>

</body>
</html>
