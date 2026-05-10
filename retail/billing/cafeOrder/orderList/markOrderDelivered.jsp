<%@ page import="java.sql.*" %>
<%
String orderId = request.getParameter("orderId");

Connection conn = null;
PreparedStatement ps = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    
    // Mark all items as delivered
    String sql = "UPDATE prod_order_details SET is_delivered = 1 WHERE order_id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(orderId));
    ps.executeUpdate();
    ps.close();
    
    // Mark order as delivered
    sql = "UPDATE prod_order SET is_delivered = 1 WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(orderId));
    ps.executeUpdate();
    
    out.print("success");
    
} catch(Exception e) {
    out.print("error: " + e.getMessage());
} finally {
    if(ps != null) try { ps.close(); } catch(Exception e) { }
    if(conn != null) {
        try { conn.setAutoCommit(true); } catch(Exception e) { }
        try { conn.close(); } catch(Exception e) { }
    }
}
%>
