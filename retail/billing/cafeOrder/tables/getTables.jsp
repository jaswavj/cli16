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
        String badgeClass = isOccupied == 1 ? "badge-danger" : "badge-success";
%>
        <div class="col-md-3 mb-3">
            <div class="card <%= isOccupied == 1 ? "border-danger" : "" %>" style="cursor: pointer; <%= isOccupied == 1 ? "background-color: #ffe0e0;" : "" %>" onclick="<%= isOccupied == 0 ? "createOrder(" + id + ", \\'" + name + "\\')" : "alert('Table is occupied')" %>">
                <div class="card-body text-center">
                    <i class="fas fa-chair fa-3x <%= isOccupied == 1 ? "text-danger" : "text-success" %> mb-2"></i>
                    <h5 class="card-title"><%=name%></h5>
                    <span class="badge <%=badgeClass%>"><%=status%></span>
                    <div class="mt-2">
                        <button class="btn btn-sm btn-info" onclick="event.stopPropagation(); editTable(<%=id%>, '<%=name%>')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="event.stopPropagation(); deleteTable(<%=id%>)">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
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
