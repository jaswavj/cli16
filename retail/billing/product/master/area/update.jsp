<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String id = request.getParameter("id");
    String areaName = request.getParameter("areaName");
    
    if (id != null && areaName != null && !areaName.trim().isEmpty()) {
        try {
            prod.updateArea(Integer.parseInt(id), areaName.trim());
            response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=Area updated successfully&type=success");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=" + e.getMessage() + "&type=danger");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=Invalid data provided&type=warning");
    }
%>
