<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
try {
    String categoryId = request.getParameter("categoryId");
    String brandId = request.getParameter("brandId");
    
    Connection con = util.DBConnectionManager.getConnectionFromPool();
    
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT id, name FROM prod_product WHERE is_active = 1 ");
    
    List<Object> params = new ArrayList<Object>();
    
    if (categoryId != null && !categoryId.trim().isEmpty()) {
        sql.append("AND category_id = ? ");
        params.add(Integer.parseInt(categoryId));
    }
    
    if (brandId != null && !brandId.trim().isEmpty()) {
        sql.append("AND brand_id = ? ");
        params.add(Integer.parseInt(brandId));
    }
    
    sql.append("ORDER BY name");
    
    PreparedStatement ps = con.prepareStatement(sql.toString());
    for (int i = 0; i < params.size(); i++) {
        ps.setObject(i + 1, params.get(i));
    }
    
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
    out.print("<option value=\"\">Error loading products</option>");
}
%>
