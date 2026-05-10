<%@ page import="java.sql.*" %>
<%
String type = request.getParameter("type");
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    String sql = "";
    
    if("pending".equals(type)) {
        sql = "SELECT po.*, ot.name as table_name FROM prod_order po " +
              "JOIN order_tables ot ON po.table_id = ot.id " +
              "WHERE po.is_delivered = 0 AND po.is_billed = 0 AND po.is_cancelled = 0 " +
              "ORDER BY po.date DESC, po.time DESC";
    } else if("delivered".equals(type)) {
        sql = "SELECT po.*, ot.name as table_name FROM prod_order po " +
              "JOIN order_tables ot ON po.table_id = ot.id " +
              "WHERE po.is_delivered = 1 AND po.is_billed = 0 AND po.is_cancelled = 0 " +
              "ORDER BY po.date DESC, po.time DESC";
    } else if("billed".equals(type)) {
        sql = "SELECT po.*, ot.name as table_name FROM prod_order po " +
              "JOIN order_tables ot ON po.table_id = ot.id " +
              "WHERE po.is_billed = 1 " +
              "ORDER BY po.date DESC, po.time DESC";
    }
    
    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();
    
    out.println("<table class='table table-bordered table-hover'>");
    out.println("<thead><tr><th>Order No</th><th>Table</th><th>Date</th><th>Time</th><th>Actions</th></tr></thead>");
    out.println("<tbody>");
    
    while(rs.next()) {
        int orderId = rs.getInt("id");
        String orderNo = rs.getString("order_no");
        String tableName = rs.getString("table_name");
        String date = rs.getString("date");
        String time = rs.getString("time");
        
        out.println("<tr>");
        out.println("<td>" + orderNo + "</td>");
        out.println("<td>" + tableName + "</td>");
        out.println("<td>" + date + "</td>");
        out.println("<td>" + time + "</td>");
        out.println("<td>");
        out.println("<button class='btn btn-sm btn-info' onclick='viewOrderDetails(" + orderId + ")'>");
        out.println("<i class='fas fa-eye'></i> View</button>");
        
        if("pending".equals(type)) {
            out.println("<button class='btn btn-sm btn-success ml-2' onclick='markOrderDelivered(" + orderId + ")'>");
            out.println("<i class='fas fa-check'></i> Mark Delivered</button>");
        }
        
        out.println("</td>");
        out.println("</tr>");
    }
    
    out.println("</tbody></table>");
    
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>
