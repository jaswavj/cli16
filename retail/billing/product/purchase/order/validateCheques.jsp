<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
    String supplierId = request.getParameter("supplierId");
    
    if (supplierId == null || supplierId.trim().isEmpty()) {
        out.print("0");
        return;
    }
    
    try {
        String result = productBean.validateSupplierCheques(Integer.parseInt(supplierId));
        out.print(result);
    } catch (Exception e) {
        out.print("0");
        e.printStackTrace();
    }
%>
