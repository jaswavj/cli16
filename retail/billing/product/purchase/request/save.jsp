<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="prBean" class="product.purchaseRequestBean" />
<%
    try {
        // Get session user ID
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            out.print("Error: User not logged in");
            return;
        }
        
        // Get parameters
        String reqArr = request.getParameter("reqArr");
        String prodArr = request.getParameter("prodArr");
        
        if (reqArr == null || prodArr == null) {
            out.print("Error: Missing required parameters");
            return;
        }
        
        // Create purchase request
        String reqNo = prBean.createPurchaseRequest(reqArr, prodArr, userId.intValue());
        
        // Return request number
        out.print(reqNo);
        
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
