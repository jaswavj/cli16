<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

String categoryIdParam = request.getParameter("category_id");
Integer categoryId = null;
if(categoryIdParam != null && !categoryIdParam.isEmpty()) {
    try {
        categoryId = Integer.parseInt(categoryIdParam);
    } catch(NumberFormatException e) {
        // Invalid category ID, ignore
    }
}

try {
    conn = util.DBConnectionManager.getConnectionFromPool();
    String sql = "SELECT p.id, p.name, p.code, IFNULL(MAX(b.mrp), 0) as mrp " +
                 "FROM prod_product p " +
                 "LEFT JOIN prod_batch b ON p.id = b.product_id " +
                 "WHERE p.is_active=1 ";
    
    if(categoryId != null) {
        sql += "AND p.category_id = ? ";
    }
    
    sql += "GROUP BY p.id, p.name, p.code " +
           "ORDER BY p.name";
           
    ps = conn.prepareStatement(sql);
    
    if(categoryId != null) {
        ps.setInt(1, categoryId);
    }
    
    rs = ps.executeQuery();
    
    while(rs.next()) {
        int id = rs.getInt("id");
        String name = rs.getString("name");
        String code = rs.getString("code");
        double price = rs.getDouble("mrp");
        
        out.println("<div class='product-item' onclick='addToOrder(" + id + ", \"" + name.replace("\"", "&quot;").replace("'", "\\'") + "\", " + price + ")'>");
        out.println("    <div>");
        out.println("        <strong>" + name + "</strong> <small class='text-muted'>(" + code + ")</small>");
        out.println("        <span class='float-right text-success'>₹ " + String.format("%.2f", price) + "</span>");
        out.println("    </div>");
        out.println("</div>");
    }
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
} finally {
    if(rs != null) rs.close();
    if(ps != null) ps.close();
    if(conn != null) conn.close();
}
%>
