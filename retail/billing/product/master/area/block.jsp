<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String id = request.getParameter("id");
    String action = request.getParameter("action");
    
    if (id != null && action != null) {
        try {
            int isActive = action.equals("block") ? 0 : 1;
            prod.updateAreaStatus(Integer.parseInt(id), isActive);
            String msg = action.equals("block") ? "Area blocked successfully" : "Area unblocked successfully";
            response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=" + msg + "&type=success");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=" + e.getMessage() + "&type=danger");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=Invalid request&type=warning");
    }
%>
