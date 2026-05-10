<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, org.json.*" %>
<%
    response.setContentType("text/plain");
    
    try {
        String poIdParam = request.getParameter("poId");
        String supplierIdParam = request.getParameter("supplierId");
        String expectedDate = request.getParameter("expectedDate");
        String poNotes = request.getParameter("poNotes");
        String existingItemsJson = request.getParameter("existingItems");
        String newItemsJson = request.getParameter("newItems");
        
        if (poIdParam == null || supplierIdParam == null) {
            out.print("Missing required parameters");
            return;
        }
        
        int poId = Integer.parseInt(poIdParam);
        int supplierId = Integer.parseInt(supplierIdParam);
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            // Check if PO is in draft status
            String checkSql = "SELECT po_status FROM prod_purchase WHERE id = ?";
            ps = con.prepareStatement(checkSql);
            ps.setInt(1, poId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                int poStatus = rs.getInt("po_status");
                if (poStatus != 1) {
                    out.print("Can only edit draft purchase orders");
                    return;
                }
            } else {
                out.print("Purchase order not found");
                return;
            }
            rs.close();
            ps.close();
            
            // Parse existing items (items to keep)
            JSONArray existingItems = new JSONArray(existingItemsJson);
            
            // Delete items not in the existing list
            StringBuilder inClause = new StringBuilder();
            for (int i = 0; i < existingItems.length(); i++) {
                if (i > 0) inClause.append(",");
                inClause.append(existingItems.getInt(i));
            }
            
            String deleteSql;
            if (existingItems.length() > 0) {
                deleteSql = "DELETE FROM prod_purchase_details WHERE prid = ? AND id NOT IN (" + inClause.toString() + ")";
            } else {
                deleteSql = "DELETE FROM prod_purchase_details WHERE prid = ?";
            }
            ps = con.prepareStatement(deleteSql);
            ps.setInt(1, poId);
            ps.executeUpdate();
            ps.close();
            
            // Parse and insert new items
            JSONArray newItems = new JSONArray(newItemsJson);
            for (int i = 0; i < newItems.length(); i++) {
                JSONObject item = newItems.getJSONObject(i);
                int prodId = item.getInt("prodId");
                double rate = item.getDouble("rate");
                double qty = item.getDouble("qty");
                
                String insertSql = "INSERT INTO prod_purchase_details(" +
                    "prid, prods_id, quantity, rate, ordered_qty, pending_qty, received_qty, is_fully_received) " +
                    "VALUES(?, ?, ?, ?, ?, ?, 0, 0)";
                ps = con.prepareStatement(insertSql);
                ps.setInt(1, poId);
                ps.setInt(2, prodId);
                ps.setDouble(3, qty);
                ps.setDouble(4, rate);
                ps.setDouble(5, qty);
                ps.setDouble(6, qty);
                ps.executeUpdate();
                ps.close();
            }
            
            // Calculate new total
            String totalSql = "SELECT SUM(quantity * rate) as total FROM prod_purchase_details WHERE prid = ?";
            ps = con.prepareStatement(totalSql);
            ps.setInt(1, poId);
            rs = ps.executeQuery();
            
            double newTotal = 0;
            if (rs.next()) {
                newTotal = rs.getDouble("total");
            }
            rs.close();
            ps.close();
            
            // Update PO header
            String updateSql = "UPDATE prod_purchase SET deal_id = ?, expected_date = ?, po_notes = ?, total = ?, balance = ? WHERE id = ?";
            ps = con.prepareStatement(updateSql);
            ps.setInt(1, supplierId);
            ps.setString(2, expectedDate);
            ps.setString(3, poNotes);
            ps.setDouble(4, newTotal);
            ps.setDouble(5, newTotal);
            ps.setInt(6, poId);
            ps.executeUpdate();
            
            con.commit();
            out.print("success");
            
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
        
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
    }
%>
