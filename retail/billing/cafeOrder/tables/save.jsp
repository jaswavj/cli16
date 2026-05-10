<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");
String name = request.getParameter("name");

Connection conn = null;
PreparedStatement ps = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    conn.setAutoCommit(false);
    
    if(id != null && !id.isEmpty()) {
        // Update
        String sql = "UPDATE order_tables SET name=? WHERE id=?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, name);
        ps.setInt(2, Integer.parseInt(id));
    } else {
        // Insert
        String sql = "INSERT INTO order_tables (name, is_occupied) VALUES (?, 0)";
        ps = conn.prepareStatement(sql);
        ps.setString(1, name);
    }
    
    ps.executeUpdate();
    conn.commit();
    out.print("success");
    
} catch(Exception e) {
    if(conn != null) {
        try { conn.rollback(); } catch(Exception ex) { }
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
