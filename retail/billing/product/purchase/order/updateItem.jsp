<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*" %>
<%
    response.setContentType("text/plain");
    
    try {
        String poDetailIdParam = request.getParameter("poDetailId");
        String qtyParam = request.getParameter("qty");
        String rateParam = request.getParameter("rate");
        
        if (poDetailIdParam == null || qtyParam == null || rateParam == null) {
            out.print("Missing required parameters");
            return;
        }
        
<%@ page import="java.math.BigDecimal" %>
<%
        int poDetailId = Integer.parseInt(poDetailIdParam);
        BigDecimal qty = new BigDecimal(qtyParam);
        double rate = Double.parseDouble(rateParam);
        
        if (qty < 1) {
            out.print("Quantity must be at least 1");
            return;
        }
        
        if (rate < 0) {
            out.print("Rate must be positive");
            return;
        }
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);  // Start transaction
            
            // Update the item - update quantity, ordered_qty, and pending_qty
            String sql = "UPDATE prod_purchase_details SET quantity = ?, ordered_qty = ?, pending_qty = ?, rate = ? WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, qty);
            ps.setInt(2, qty);  // ordered_qty = qty
            ps.setInt(3, qty);  // pending_qty = qty (since nothing has been received yet in draft PO)
            ps.setDouble(4, rate);
            ps.setInt(5, poDetailId);
            
            int updated = ps.executeUpdate();
            
            if (updated > 0) {
                // Get the PO ID from the detail record
                ps.close();
                ps = con.prepareStatement("SELECT prid FROM prod_purchase_details WHERE id = ?");
                ps.setInt(1, poDetailId);
                rs = ps.executeQuery();
                int poId = 0;
                if (rs.next()) {
                    poId = rs.getInt("prid");
                }
                rs.close();
                ps.close();
                
                // Update PO total
                ps = con.prepareStatement("SELECT SUM(quantity * rate) as total FROM prod_purchase_details WHERE prid = ?");
                ps.setInt(1, poId);
                rs = ps.executeQuery();
                double newTotal = 0;
                if (rs.next()) {
                    newTotal = rs.getDouble("total");
                }
                rs.close();
                ps.close();
                
                // Update the PO header
                ps = con.prepareStatement("UPDATE prod_purchase SET total = ?, balance = ? WHERE id = ?");
                ps.setDouble(1, newTotal);
                ps.setDouble(2, newTotal);
                ps.setInt(3, poId);
                ps.executeUpdate();
                
                con.commit();
                out.print("success");
            } else {
                con.rollback();
                out.print("Failed to update item");
            }
            
        } catch (SQLException e) {
            if (con != null) con.rollback();
            out.print("Database error: " + e.getMessage());
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
        
    } catch (NumberFormatException e) {
        out.print("Invalid number format");
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
    }
%>
