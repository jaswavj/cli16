<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<%
    try {
        // Get session user ID
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            out.print("Error: User not logged in");
            return;
        }
        
        // Get parameters
        String poArr = request.getParameter("poArr");
        String prodArr = request.getParameter("prodArr");
        
        if (poArr == null || prodArr == null) {
            out.print("Error: Missing required parameters");
            return;
        }
        
        // Create purchase order
        String poNo = poBean.createPurchaseOrder(poArr, prodArr, userId.intValue());
        
        // Return PO number
        out.print(poNo);
        
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
