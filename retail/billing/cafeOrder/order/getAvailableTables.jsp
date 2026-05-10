<%@ page import="java.sql.*" %>
<%
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    String sql = "SELECT * FROM order_tables ORDER BY name";
    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();
    
    while(rs.next()) {
        int id = rs.getInt("id");
        String name = rs.getString("name");
        int isOccupied = rs.getInt("is_occupied");
        String status = isOccupied == 1 ? "Occupied" : "Available";
        String badgeClass = isOccupied == 1 ? "bg-danger" : "bg-success";
        String bgColor = isOccupied == 1 ? "background-color: #ffe0e0;" : "";
        String borderColor = isOccupied == 1 ? "border-danger" : "";
        String iconColor = isOccupied == 1 ? "text-danger" : "text-success";
        String clickEvent = isOccupied == 0 ? "selectTable(" + id + ", '" + name + "')" : "viewOccupiedTableOrder(" + id + ", '" + name + "')";
%>
        <div class="col-md-2 col-sm-3 col-4 mb-3">
            <div class="card <%=borderColor%> table-card" style="cursor: pointer; <%=bgColor%>" onclick="<%=clickEvent%>">
                <div class="card-body text-center p-2">
                    <i class="fas fa-chair fa-2x <%=iconColor%> mb-1"></i>
                    <h6 class="mb-1"><%=name%></h6>
                    <span class="badge <%=badgeClass%> badge-sm"><%=status%></span>
                </div>
            </div>
        </div>
<%
    }
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>
