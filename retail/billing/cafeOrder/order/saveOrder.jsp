<%@ page import="java.sql.*" %>
<%@ page import="org.json.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%
String tableId = request.getParameter("tableId");
String itemsJson = request.getParameter("items");

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    conn.setAutoCommit(false);
    
    // Get user ID from session
    Integer uid = (Integer)session.getAttribute("uid");
    if(uid == null) uid = 1;
    
    // Get current date and time
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
    String currentDate = dateFormat.format(new Date());
    String currentTime = timeFormat.format(new Date());
    
    // Check if table already has a pending order
    int orderId = 0;
    String checkSql = "SELECT id FROM prod_order WHERE table_id = ? AND is_billed = 0 AND is_cancelled = 0 LIMIT 1";
    ps = conn.prepareStatement(checkSql);
    ps.setInt(1, Integer.parseInt(tableId));
    rs = ps.executeQuery();
    if(rs.next()) {
        orderId = rs.getInt("id");
    }
    rs.close();
    ps.close();
    
    // If order exists, delete old items; otherwise create new order
    if(orderId > 0) {
        // Delete existing items
        String deleteSql = "DELETE FROM prod_order_details WHERE order_id = ?";
        ps = conn.prepareStatement(deleteSql);
        ps.setInt(1, orderId);
        ps.executeUpdate();
        ps.close();
    } else {
        // Generate daily order number (reset each day)
        String orderNo = "";
        String sql = "SELECT COALESCE(MAX(CAST(order_no AS UNSIGNED)), 0) as max_order FROM prod_order WHERE date = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, currentDate);
        rs = ps.executeQuery();
        int nextOrderNo = 1;
        if(rs.next()) {
            nextOrderNo = rs.getInt("max_order") + 1;
        }
        orderNo = String.valueOf(nextOrderNo);
        rs.close();
        ps.close();
        
        // Insert order
        sql = "INSERT INTO prod_order (order_no, table_id, is_delivered, is_billed, is_cancelled, date, time, uid) VALUES (?, ?, 0, 0, 0, ?, ?, ?)";
        ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, orderNo);
        ps.setInt(2, Integer.parseInt(tableId));
        ps.setString(3, currentDate);
        ps.setString(4, currentTime);
        ps.setInt(5, uid);
        ps.executeUpdate();
        
        rs = ps.getGeneratedKeys();
        if(rs.next()) {
            orderId = rs.getInt(1);
        }
        ps.close();
    }
    
    // Parse items and insert order details
    JSONArray items = new JSONArray(itemsJson);
    for(int i = 0; i < items.length(); i++) {
        JSONObject item = items.getJSONObject(i);
        int prodId = item.getInt("prodId");
        int qty = item.getInt("qty");
        double price = item.getDouble("price");
        double total = item.getDouble("total");
        
        String sql = "INSERT INTO prod_order_details (order_id, prod_id, qty, price, total, is_delivered) VALUES (?, ?, ?, ?, ?, 0)";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, orderId);
        ps.setInt(2, prodId);
        ps.setInt(3, qty);
        ps.setDouble(4, price);
        ps.setDouble(5, total);
        ps.executeUpdate();
        ps.close();
    }
    
    // Update table status to occupied
    String sql = "UPDATE order_tables SET is_occupied = 1 WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(tableId));
    ps.executeUpdate();
    
    conn.commit();
    out.print("success");
    
} catch(Exception e) {
    if(conn != null) {
        try { conn.rollback(); } catch(Exception ex) {}
    }
    out.print("error: " + e.getMessage());
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) { }
    if(ps != null) try { ps.close(); } catch(Exception e) { }
    if(conn != null) {
        try { conn.setAutoCommit(true); } catch(Exception e) { }
        try { conn.close(); } catch(Exception e) { }
    }
}
%>
