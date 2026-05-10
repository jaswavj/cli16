<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*" %>
<%
    response.setContentType("text/plain");
    
    try {
        String poDetailIdParam = request.getParameter("poDetailId");
        
        if (poDetailIdParam == null) {
            out.print("Missing item ID");
            return;
        }
        
        int poDetailId = Integer.parseInt(poDetailIdParam);
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);  // Start transaction
            
            // Get the PO ID first
            String getPoSql = "SELECT prid FROM prod_purchase_details WHERE id = ?";
            ps = con.prepareStatement(getPoSql);
            ps.setInt(1, poDetailId);
            rs = ps.executeQuery();
            
            int poId = 0;
            if (!rs.next()) {
                out.print("Item not found");
                return;
            }
            poId = rs.getInt("prid");
            rs.close();
            ps.close();
            
            // Check if item has been received
            String checkSql = "SELECT COALESCE(received_qty, 0) as received_qty FROM prod_purchase_details WHERE id = ?";
            ps = con.prepareStatement(checkSql);
            ps.setInt(1, poDetailId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                int receivedQty = rs.getInt("received_qty");
                if (receivedQty > 0) {
                    out.print("Cannot delete item that has been partially received");
                    return;
                }
            }
            rs.close();
            ps.close();
            
            // Delete the item
            String deleteSql = "DELETE FROM prod_purchase_details WHERE id = ?";
            ps = con.prepareStatement(deleteSql);
            ps.setInt(1, poDetailId);
            
            int deleted = ps.executeUpdate();
            
            if (deleted > 0) {
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
                out.print("Failed to delete item");
            }
            
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) {}
            }
            out.print("Database error: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                // Ignore close errors
            }
        }
        
    } catch (NumberFormatException e) {
        out.print("Invalid number format");
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
    }
%>
