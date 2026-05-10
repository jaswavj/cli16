<%@page import="product.productBean"%>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    Integer userId = (Integer) session.getAttribute("userId");
    
    try {
        if (userId == null) {
            out.print("{\"hasPermission\":false}");
            return;
        }
        
        productBean prod = new productBean();
        boolean hasPermission = prod.checkUserSpecialPermission(userId, 1);
        out.print("{\"hasPermission\":" + hasPermission + "}");
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"hasPermission\":false}");
    }
%>
