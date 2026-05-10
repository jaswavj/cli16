<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<%
    int poId = 0;
    String idParam = request.getParameter("id");
    if (idParam != null && !idParam.isEmpty()) {
        try {
            poId = Integer.parseInt(idParam);
        } catch (Exception e) {
            out.print("<script>alert('Invalid PO ID'); window.location.href='" + request.getContextPath() + "/product/purchase/order/list.jsp';</script>");
            return;
        }
    } else {
        out.print("<script>alert('PO ID required'); window.location.href='" + request.getContextPath() + "/product/purchase/order/list.jsp';</script>");
        return;
    }
    
    try {
        boolean success = poBean.sendPurchaseOrder(poId);
        
        if (success) {
            out.print("<script>alert('Purchase Order sent successfully!'); window.location.href='" + request.getContextPath() + "/product/purchase/order/details.jsp?id=" + poId + "';</script>");
        } else {
            out.print("<script>alert('Failed to send Purchase Order'); window.location.href='" + request.getContextPath() + "/product/purchase/order/details.jsp?id=" + poId + "';</script>");
        }
    } catch (Exception e) {
        out.print("<script>alert('Error: " + e.getMessage() + "'); window.location.href='" + request.getContextPath() + "/product/purchase/order/details.jsp?id=" + poId + "';</script>");
        e.printStackTrace();
    }
%>
