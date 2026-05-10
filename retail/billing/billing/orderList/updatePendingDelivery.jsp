<%@ page import="java.sql.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

try {
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"success\":false,\"message\":\"Session expired\"}");
        return;
    }

    String billIdStr = request.getParameter("billId");
    String deliveryDate = request.getParameter("deliveryDate");
    String isDownloadedStr = request.getParameter("isDownloaded");
    String photoCountStr = request.getParameter("photoCount");

    if (billIdStr == null || billIdStr.trim().isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"success\":false,\"message\":\"Bill ID is required\"}");
        return;
    }

    int billId = Integer.parseInt(billIdStr);
    int isDownloaded = 0;
    if (isDownloadedStr != null) {
        String normalized = isDownloadedStr.trim().toLowerCase();
        if ("1".equals(normalized) || "true".equals(normalized) || "on".equals(normalized)) {
            isDownloaded = 1;
        }
    }
    int photoCount = 0;
    if (photoCountStr != null && !photoCountStr.trim().isEmpty()) {
        try { photoCount = Integer.parseInt(photoCountStr.trim()); } catch (NumberFormatException ignore) {}
    }

    String result = bill.updatePendingDelivery(billId, deliveryDate, isDownloaded, photoCount);
    if ("SUCCESS".equals(result)) {
        out.print("{\"success\":true,\"message\":\"Updated successfully\"}");
    } else {
        out.print("{\"success\":false,\"message\":\"" + result.replace("\"", "'") + "\"}");
    }
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("{\"success\":false,\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
}
%>
