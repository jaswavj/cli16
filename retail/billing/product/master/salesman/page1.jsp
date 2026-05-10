<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String salesmanName = request.getParameter("salesmanName");
    
    if (salesmanName != null && !salesmanName.trim().isEmpty()) {
        try {
            prod.addSalesman(salesmanName.trim());
            response.sendRedirect(request.getContextPath() + "/product/master/salesman/page.jsp?msg=Salesman added successfully&type=success");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/product/master/salesman/page.jsp?msg=" + e.getMessage() + "&type=danger");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/salesman/page.jsp?msg=Salesman name is required&type=warning");
    }
%>
