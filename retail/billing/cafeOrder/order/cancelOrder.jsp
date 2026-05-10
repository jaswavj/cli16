<%@ page import="java.sql.*" %>
<%
String orderIdParam = request.getParameter("orderId");
String tableIdParam = request.getParameter("tableId");

if(orderIdParam == null || tableIdParam == null) {
    out.print("error: Missing parameters");
    return;
}

int orderId = Integer.parseInt(orderIdParam);
int tableId = Integer.parseInt(tableIdParam);

Connection conn = null;
PreparedStatement ps = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    conn.setAutoCommit(false);
    
    // Mark order as cancelled
    String sql = "UPDATE prod_order SET is_cancelled = 1 WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, orderId);
    ps.executeUpdate();
    ps.close();
    
    // Make table available again
    sql = "UPDATE order_tables SET is_occupied = 0 WHERE id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, tableId);
    ps.executeUpdate();
    
    conn.commit();
    out.print("success");
    
} catch(Exception e) {
    if(conn != null) {
        try { conn.rollback(); } catch(Exception ex) {}
    }
    out.print("error: " + e.getMessage());
} finally {
    if(ps != null) try { ps.close(); } catch(Exception e) { }
    if(conn != null) {
        try { conn.setAutoCommit(true); } catch(Exception e) { }
        try { conn.close(); } catch(Exception e) { }
    }
}
%>
