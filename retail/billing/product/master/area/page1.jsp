<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String areaName = request.getParameter("areaName");
    
    if (areaName != null && !areaName.trim().isEmpty()) {
        try {
            prod.addArea(areaName.trim());
            response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=Area added successfully&type=success");
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=" + e.getMessage() + "&type=danger");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/area/page.jsp?msg=Area name is required&type=warning");
    }
%>
