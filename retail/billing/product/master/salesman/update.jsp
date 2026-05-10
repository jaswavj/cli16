<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String id = request.getParameter("id");
    String salesmanName = request.getParameter("salesmanName");
    
    if (id != null && salesmanName != null && !salesmanName.trim().isEmpty()) {
        try {
            prod.updateSalesman(Integer.parseInt(id), salesmanName.trim());
            response.sendRedirect(request.getContextPath() + "/product/master/salesman/page.jsp?msg=Salesman updated successfully&type=success");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/product/master/salesman/page.jsp?msg=" + e.getMessage() + "&type=danger");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/salesman/page.jsp?msg=Invalid data provided&type=warning");
    }
%>
