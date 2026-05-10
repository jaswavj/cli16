<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
try {
    request.setCharacterEncoding("UTF-8");
    
    // Debug: Log all parameters
    System.out.println("=== Attender Save Debug ===");
    System.out.println("Request Method: " + request.getMethod());
    System.out.println("Content Type: " + request.getContentType());
    
    Enumeration<String> paramNames = request.getParameterNames();
    while(paramNames.hasMoreElements()) {
        String paramName = paramNames.nextElement();
        System.out.println("Parameter: " + paramName + " = " + request.getParameter(paramName));
    }
    
    String action = request.getParameter("action");
    System.out.println("Action value: " + action);
    
    if (action == null || action.trim().isEmpty()) {
        out.print("ERROR: No action specified. Received parameters: " + request.getParameterMap().keySet());
        return;
    }
    
    if ("add".equals(action)) {
        String name = request.getParameter("name");
        String code = request.getParameter("code");
        
        if (name == null || name.trim().isEmpty()) {
            out.print("ERROR: Name is required");
            return;
        }
        
        boolean success = prod.addAttender(name.trim(), code != null ? code.trim() : "");
        if (success) {
            out.print("SUCCESS");
        } else {
            out.print("ERROR: Failed to add attender");
        }
        
    } else if ("edit".equals(action)) {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        String code = request.getParameter("code");
        
        if (idStr == null || name == null || name.trim().isEmpty()) {
            out.print("ERROR: ID and Name are required");
            return;
        }
        
        int id = Integer.parseInt(idStr);
        boolean success = prod.updateAttender(id, name.trim(), code != null ? code.trim() : "");
        if (success) {
            out.print("SUCCESS");
        } else {
            out.print("ERROR: Failed to update attender");
        }
        
    } else if ("block".equals(action)) {
        String idStr = request.getParameter("id");
        
        if (idStr == null) {
            out.print("ERROR: ID is required");
            return;
        }
        
        int id = Integer.parseInt(idStr);
        boolean success = prod.blockAttender(id);
        if (success) {
            out.print("SUCCESS");
        } else {
            out.print("ERROR: Failed to block attender");
        }
        
    } else if ("unblock".equals(action)) {
        String idStr = request.getParameter("id");
        
        if (idStr == null) {
            out.print("ERROR: ID is required");
            return;
        }
        
        int id = Integer.parseInt(idStr);
        boolean success = prod.unblockAttender(id);
        if (success) {
            out.print("SUCCESS");
        } else {
            out.print("ERROR: Failed to unblock attender");
        }
        
    } else {
        out.print("ERROR: Invalid action");
    }
    
} catch (Exception e) {
    e.printStackTrace();
    out.print("ERROR: " + e.getMessage());
}
%>
