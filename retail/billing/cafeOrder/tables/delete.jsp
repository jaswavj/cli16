<%@ page import="java.sql.*" %>
<%
String id = request.getParameter("id");

Connection conn = null;
PreparedStatement ps = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    conn.setAutoCommit(false);
    
    String sql = "DELETE FROM order_tables WHERE id=?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(id));
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
