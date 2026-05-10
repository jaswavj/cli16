<%@ page import="java.sql.*" %>
<%
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    String sql = "SELECT id, name FROM prod_category WHERE is_active = 1 ORDER BY name";
    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();
    
    while(rs.next()) {
        int id = rs.getInt("id");
        String name = rs.getString("name");
%>
        <button class="btn btn-sm btn-outline-primary category-btn" onclick="selectCategory(<%=id%>)">
            <%=name%>
        </button>
<%
    }
} catch(Exception e) {
    out.println("<span class='text-danger'>Error: " + e.getMessage() + "</span>");
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>
