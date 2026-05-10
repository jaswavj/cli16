<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
try {
    String categoryId = request.getParameter("categoryId");
    
    if (categoryId == null || categoryId.trim().isEmpty()) {
        out.print("");
        return;
    }
    
    Connection con = util.DBConnectionManager.getConnectionFromPool();
    
    String sql = "SELECT DISTINCT pb.id, pb.name " +
                 "FROM prod_brands pb " +
                 "INNER JOIN prod_product pp ON pb.id = pp.brand_id " +
                 "WHERE pp.category_id = ? AND pb.is_active = 1 " +
                 "ORDER BY pb.name";
    
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, Integer.parseInt(categoryId));
    
    ResultSet rs = ps.executeQuery();
    
    StringBuilder options = new StringBuilder();
    while (rs.next()) {
        int id = rs.getInt("id");
        String name = rs.getString("name");
        options.append("<option value=\"").append(id).append("\">").append(name).append("</option>");
    }
    
    rs.close();
    ps.close();
    con.close();
    
    out.print(options.toString());
    
} catch (Exception e) {
    e.printStackTrace();
    out.print("");
}
%>
