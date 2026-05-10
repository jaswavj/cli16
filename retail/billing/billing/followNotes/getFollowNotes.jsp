<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    try {
        JSONArray arr = bill.getFollowNotes();
        out.print(arr.toString());
    } catch (Exception e) {
        out.print(new JSONArray().toString());
    }
%>
