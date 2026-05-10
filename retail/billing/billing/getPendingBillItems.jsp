<%@ page import="java.sql.*, org.json.*" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"error\":\"Session expired\"}");
        return;
    }

    String billIdStr = request.getParameter("billId");
    if (billIdStr == null || billIdStr.trim().isEmpty()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        out.print("{\"error\":\"Bill ID is required\"}");
        return;
    }

    int billId = Integer.parseInt(billIdStr);

    con = util.DBConnectionManager.getConnectionFromPool();
    String sql = "SELECT IFNULL(pp.name, '-') AS item_name, IFNULL(pbd.qty, 0) AS qty " +
                 "FROM prod_bill_details pbd " +
                 "LEFT JOIN prod_product pp ON pp.id = pbd.prod_id " +
                 "WHERE pbd.bill_id = ? " +
                 "ORDER BY pbd.id ASC";

    ps = con.prepareStatement(sql);
    ps.setInt(1, billId);
    rs = ps.executeQuery();

    JSONArray arr = new JSONArray();
    while (rs.next()) {
        JSONObject obj = new JSONObject();
        obj.put("itemName", rs.getString("item_name"));
        obj.put("qty", rs.getBigDecimal("qty"));
        arr.put(obj);
    }

    out.print(arr.toString());
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) { ; }
    if (ps != null) try { ps.close(); } catch (Exception e) { ; }
    if (con != null) try { con.close(); } catch (Exception e) { ; }
}
%>
