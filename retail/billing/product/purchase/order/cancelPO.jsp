<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*" %>
<%
    response.setContentType("text/plain");
    
    try {
        String poIdParam = request.getParameter("poId");
        
        if (poIdParam == null) {
            out.print("Missing PO ID");
            return;
        }
        
        int poId = Integer.parseInt(poIdParam);
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);  // Start transaction
            
            // Check if PO is in draft status
            String checkSql = "SELECT po_status FROM prod_purchase WHERE id = ?";
            ps = con.prepareStatement(checkSql);
            ps.setInt(1, poId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                int poStatus = rs.getInt("po_status");
                if (poStatus != 1) {
                    out.print("Can only cancel draft purchase orders");
                    return;
                }
            } else {
                out.print("Purchase order not found");
                return;
            }
            rs.close();
            ps.close();
            
            // Check if any items have been received
            String checkReceivedSql = "SELECT SUM(COALESCE(received_qty, 0)) as total_received FROM prod_purchase_details WHERE prid = ?";
            ps = con.prepareStatement(checkReceivedSql);
            ps.setInt(1, poId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                int totalReceived = rs.getInt("total_received");
                if (totalReceived > 0) {
                    out.print("Cannot cancel PO with received items");
                    return;
                }
            }
            rs.close();
            ps.close();
            
            // Delete PO details first (foreign key constraint)
            String deleteDetailsSql = "DELETE FROM prod_purchase_details WHERE prid = ?";
            ps = con.prepareStatement(deleteDetailsSql);
            ps.setInt(1, poId);
            ps.executeUpdate();
            ps.close();
            
            // Delete PO
            String deletePOSql = "DELETE FROM prod_purchase WHERE id = ?";
            ps = con.prepareStatement(deletePOSql);
            ps.setInt(1, poId);
            
            int deleted = ps.executeUpdate();
            
            if (deleted > 0) {
                con.commit();
                out.print("success");
            } else {
                con.rollback();
                out.print("Failed to cancel purchase order");
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
