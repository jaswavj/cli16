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
        String prIdStr = request.getParameter("prId");
        String actionStr = request.getParameter("action");
        String notes = request.getParameter("notes");
        
        if (prIdStr == null || actionStr == null) {
            out.print("Error: Missing required parameters");
            return;
        }
        
        int prId = Integer.parseInt(prIdStr);
        int action = Integer.parseInt(actionStr);
        
        // Validate action (3=Approve, 4=Reject)
        if (action != 3 && action != 4) {
            out.print("Error: Invalid action");
            return;
        }
        
        // Update PR status
        prBean.updatePRStatus(prId, action, userId.intValue(), notes);
        
        // Return success
        out.print("success");
        
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
