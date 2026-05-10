<%@ page import="java.sql.*" %>
<%@ page import="org.json.simple.*" %>
<%
response.setContentType("application/json");
String tableIdParam = request.getParameter("tableId");

if(tableIdParam == null) {
    out.print("{\"error\": \"Table ID is required\"}");
    return;
}

int tableId = Integer.parseInt(tableIdParam);
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

JSONObject result = new JSONObject();
JSONArray itemsArray = new JSONArray();

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    
    // Get the pending order for this table
    String orderSql = "SELECT id FROM prod_order WHERE table_id = ? AND is_billed = 0 AND is_cancelled = 0 LIMIT 1";
    ps = conn.prepareStatement(orderSql);
    ps.setInt(1, tableId);
    rs = ps.executeQuery();
    
    int orderId = 0;
    if(rs.next()) {
        orderId = rs.getInt("id");
    }
    rs.close();
    ps.close();
    
    if(orderId == 0) {
        result.put("items", itemsArray);
        out.print(result.toString());
        return;
    }
    
    // Get order items
    String itemsSql = "SELECT pod.*, pp.name as product_name, pp.code FROM prod_order_details pod " +
                      "JOIN prod_product pp ON pod.prod_id = pp.id " +
                      "WHERE pod.order_id = ?";
    ps = conn.prepareStatement(itemsSql);
    ps.setInt(1, orderId);
    rs = ps.executeQuery();
    
    while(rs.next()) {
        JSONObject item = new JSONObject();
        item.put("prodId", rs.getInt("prod_id"));
        item.put("prodName", rs.getString("product_name"));
        item.put("code", rs.getString("code"));
        item.put("price", rs.getDouble("price"));
        item.put("qty", rs.getInt("qty"));
        item.put("total", rs.getDouble("total"));
        item.put("orderDetailId", rs.getInt("id")); // Store the detail ID for updates
        itemsArray.add(item);
    }
    
    result.put("items", itemsArray);
    result.put("orderId", orderId);
    out.print(result.toString());
    
} catch(Exception e) {
    result.put("error", e.getMessage());
    out.print(result.toString());
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>
