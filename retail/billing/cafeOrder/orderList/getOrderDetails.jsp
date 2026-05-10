<%@ page import="java.sql.*" %>
<%
String orderId = request.getParameter("orderId");
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    
    // Get order info
    String sql = "SELECT po.*, ot.name as table_name FROM prod_order po " +
                 "JOIN order_tables ot ON po.table_id = ot.id WHERE po.id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(orderId));
    rs = ps.executeQuery();
    
    if(rs.next()) {
        String orderNo = rs.getString("order_no");
        String tableName = rs.getString("table_name");
        String date = rs.getString("date");
        String time = rs.getString("time");
        
        out.println("<h5>Order: " + orderNo + "</h5>");
        out.println("<p><strong>Table:</strong> " + tableName + "</p>");
        out.println("<p><strong>Date:</strong> " + date + " <strong>Time:</strong> " + time + "</p>");
    }
    rs.close();
    ps.close();
    
    // Get order items
    sql = "SELECT pod.*, p.name, p.code FROM prod_order_details pod " +
          "JOIN prod_product p ON pod.prod_id = p.id WHERE pod.order_id = ?";
    ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(orderId));
    rs = ps.executeQuery();
    
    out.println("<table class='table table-bordered'>");
    out.println("<thead><tr><th>Product</th><th>Qty</th><th>Price</th><th>Total</th><th>Status</th><th>Action</th></tr></thead>");
    out.println("<tbody>");
    
    double grandTotal = 0;
    while(rs.next()) {
        int detailId = rs.getInt("id");
        String prodName = rs.getString("name");
        int qty = rs.getInt("qty");
        double price = rs.getDouble("price");
        double total = rs.getDouble("total");
        int isDelivered = rs.getInt("is_delivered");
        
        grandTotal += total;
        
        String statusBadge = isDelivered == 1 ? 
            "<span class='badge badge-success'>Delivered</span>" : 
            "<span class='badge badge-warning'>Pending</span>";
        
        String action = isDelivered == 0 ? 
            "<button class='btn btn-sm btn-success' onclick='updateItemDelivery(" + detailId + ", " + orderId + ")'>" +
            "<i class='fas fa-check'></i></button>" : "";
        
        out.println("<tr>");
        out.println("<td>" + prodName + "</td>");
        out.println("<td>" + qty + "</td>");
        out.println("<td>" + String.format("%.2f", price) + "</td>");
        out.println("<td>" + String.format("%.2f", total) + "</td>");
        out.println("<td>" + statusBadge + "</td>");
        out.println("<td>" + action + "</td>");
        out.println("</tr>");
    }
    
    out.println("<tr><th colspan='3'>Grand Total</th><th colspan='3'>" + String.format("%.2f", grandTotal) + "</th></tr>");
    out.println("</tbody></table>");
    
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>
