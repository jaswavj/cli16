<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
String idStr = request.getParameter("id");
String action = request.getParameter("action");

try {
    if (idStr != null && action != null) {
        int id = Integer.parseInt(idStr);
        int newStatus = action.equals("block") ? 0 : 1;
        prod.updateUnitStatus(id, newStatus);
        
        String msg = action.equals("block") ? "Unit blocked successfully" : "Unit unblocked successfully";
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=" + msg + "&type=success");
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Invalid request&type=danger");
    }
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Error: " + e.getMessage() + "&type=danger");
}
%>
