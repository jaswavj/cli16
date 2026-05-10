<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    response.setContentType("application/json");
    try {
        Integer uid = (Integer) session.getAttribute("userId");
        if (uid == null) {
            out.print(new JSONObject().put("success", false).put("message", "Session expired. Please login again.").toString());
            return;
        }

        String noteIdStr = request.getParameter("noteId");
        if (noteIdStr == null || noteIdStr.trim().isEmpty()) {
            out.print(new JSONObject().put("success", false).put("message", "Note ID is required.").toString());
            return;
        }

        int noteId;
        try { noteId = Integer.parseInt(noteIdStr.trim()); }
        catch (NumberFormatException e) {
            out.print(new JSONObject().put("success", false).put("message", "Invalid note ID.").toString());
            return;
        }
        JSONObject result = bill.closeFollowNote(noteId, uid);
        out.print(result.toString());
    } catch (Exception e) {
        out.print(new JSONObject().put("success", false).put("message", "Error: " + e.getMessage()).toString());
    }
%>
