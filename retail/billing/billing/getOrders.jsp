<%@ page import="cafeorder.CafeOrderBean" %>
<%
response.setContentType("application/json");

try {
    CafeOrderBean bean = new CafeOrderBean();
    String json = bean.getPendingOrdersJSON();
    out.print(json);
} catch(Exception e) {
    out.print("[{\"error\":\"" + e.getMessage() + "\"}]");
}
%>
