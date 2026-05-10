package cheque;

import java.sql.*;
import java.util.*;
import java.text.*;

public class supplierChequeBean {
    
    public supplierChequeBean() {}
    
    // Add new cheque issued to supplier
    public void addSupplierCheque(int supplierId, String chequeNumber, String bankName, int uid) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false); // Start transaction
            
            System.out.println("Adding supplier cheque - SupplierId: " + supplierId + 
                             ", ChequeNumber: " + chequeNumber);
            
            String sql = "INSERT INTO prod_supplier_cheque_stock " +
                        "(supplier_id, cheque_number, bank_name, status, entry_date, entry_time, entry_uid) " +
                        "VALUES (?, ?, ?, 'AVAILABLE', CURDATE(), CURTIME(), ?)";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, supplierId);
            ps.setString(2, chequeNumber);
            ps.setString(3, bankName);
            ps.setInt(4, uid);
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                con.commit(); // Commit transaction
                System.out.println("Supplier cheque inserted successfully - Rows affected: " + rowsAffected);
            } else {
                con.rollback();
                throw new Exception("No rows inserted - operation failed");
            }
            
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                    System.err.println("Transaction rolled back due to SQL error");
                } catch (SQLException rollbackEx) {
                    System.err.println("Rollback failed: " + rollbackEx.getMessage());
                }
            }
            System.err.println("SQL Error in addSupplierCheque: " + e.getMessage());
            e.printStackTrace();
            throw new Exception("Database error: " + e.getMessage(), e);
        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                    System.err.println("Transaction rolled back due to error");
                } catch (SQLException rollbackEx) {
                    System.err.println("Rollback failed: " + rollbackEx.getMessage());
                }
            }
            throw e;
        } finally {
            if (ps != null) try { ps.close(); } catch (SQLException e) { ; }
            if (con != null) {
                try {
                    con.setAutoCommit(true); // Restore default
                } catch (SQLException e) { ; }
                try { 
                    con.close(); 
                } catch (SQLException e) { ; }
            }
        }
    }
    
    // Get available cheques for a supplier
    public Vector getAvailableSupplierCheques(int supplierId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector cheques = new Vector();
            
            String sql = "SELECT id, cheque_number, status, entry_date " +
                        "FROM prod_supplier_cheque_stock " +
                        "WHERE supplier_id = ? AND status IN ('AVAILABLE', 'PARTIAL') " +
                        "AND is_active = 1 " +
                        "ORDER BY entry_date ASC, id ASC";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, supplierId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getInt("id"));                      // 0
                row.add(rs.getString("cheque_number"));         // 1
                row.add(rs.getString("status"));                // 2
                row.add(rs.getString("entry_date"));            // 3
                cheques.add(row);
            }
            
            return cheques;
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (ps != null) try { ps.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Allocate available cheques to a credit purchase
    public void allocatePendingChequesToPurchase(int supplierId, int purchaseId, double purchaseBalance) throws Exception {
        Connection con = null;
        PreparedStatement selectPS = null;
        PreparedStatement insertPS = null;
        PreparedStatement updatePS = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            System.out.println("Allocating supplier cheque - SupplierId: " + supplierId + 
                             ", PurchaseId: " + purchaseId + ", Balance: " + purchaseBalance);
            
            // Get available cheques
            String selectSql = "SELECT id FROM prod_supplier_cheque_stock " +
                              "WHERE supplier_id = ? AND status = 'AVAILABLE' " +
                              "AND is_active = 1 " +
                              "ORDER BY entry_date ASC, id ASC";
            
            selectPS = con.prepareStatement(selectSql);
            selectPS.setInt(1, supplierId);
            rs = selectPS.executeQuery();
            
            int uid = 1; // Default user ID
            int allocatedCount = 0;
            
            // Allocate one cheque per credit purchase
            if (rs.next()) {
                int chequeId = rs.getInt("id");
                
                System.out.println("Found available cheque ID: " + chequeId);
                
                try {
                    // Insert allocation record with allocated_amount
                    String insertSql = "INSERT INTO prod_supplier_cheque_allocation " +
                                      "(cheque_id, purchase_id, allocated_amount, allocated_date, allocated_time, " +
                                      "due_date, credit_days, status, allocated_uid) " +
                                      "VALUES (?, ?, ?, CURDATE(), CURTIME(), " +
                                      "DATE_ADD(CURDATE(), INTERVAL 10 DAY), 10, 'ALLOCATED', ?)";
                    
                    insertPS = con.prepareStatement(insertSql);
                    insertPS.setInt(1, chequeId);
                    insertPS.setInt(2, purchaseId);
                    insertPS.setDouble(3, purchaseBalance);
                    insertPS.setInt(4, uid);
                    int insertRows = insertPS.executeUpdate();
                    
                    if (insertRows == 0) {
                        System.err.println("ERROR: INSERT failed - no rows inserted!");
                        con.rollback();
                        throw new Exception("Failed to insert allocation record - no rows affected");
                    }
                    
                    insertPS.close();
                    
                    // Update cheque stock status to FULLY_USED
                    String updateSql = "UPDATE prod_supplier_cheque_stock " +
                                      "SET status = 'FULLY_USED' " +
                                      "WHERE id = ?";
                    
                    updatePS = con.prepareStatement(updateSql);
                    updatePS.setInt(1, chequeId);
                    int updateRows = updatePS.executeUpdate();
                    
                    if (updateRows == 0) {
                        System.err.println("ERROR: UPDATE failed - no rows updated!");
                        con.rollback();
                        throw new Exception("Failed to update cheque status - no rows affected");
                    }
                    
                    updatePS.close();
                    
                    allocatedCount++;
                    System.out.println("Successfully allocated cheque to purchase");
                } catch (SQLException sqle) {
                    System.err.println("SQL Error during allocation: " + sqle.getMessage());
                    System.err.println("SQL State: " + sqle.getSQLState());
                    System.err.println("Error Code: " + sqle.getErrorCode());
                    con.rollback();
                    throw sqle;
                }
            } else {
                System.out.println("No available cheques found for supplier " + supplierId);
            }
            
            con.commit();
            System.out.println("Transaction committed - Allocated " + allocatedCount + 
                             " cheque(s) for purchase " + purchaseId);
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            System.err.println("Error allocating supplier cheques: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (selectPS != null) try { selectPS.close(); } catch (SQLException e) { ; }
            if (insertPS != null) try { insertPS.close(); } catch (SQLException e) { ; }
            if (updatePS != null) try { updatePS.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Reverse cheque allocation when payment is made by other means
    public void reverseChequeAllocation(int purchaseId, double paidAmount) throws Exception {
        Connection con = null;
        PreparedStatement selectPS = null;
        PreparedStatement updateAllocPS = null;
        PreparedStatement updateChequePS = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            System.out.println("Reversing cheque allocation for purchase " + purchaseId + ", amount: " + paidAmount);
            
            // Get allocated cheques for this purchase
            String selectSql = "SELECT id, cheque_id " +
                              "FROM prod_supplier_cheque_allocation " +
                              "WHERE purchase_id = ? AND status = 'ALLOCATED' " +
                              "ORDER BY allocated_date ASC";
            
            selectPS = con.prepareStatement(selectSql);
            selectPS.setInt(1, purchaseId);
            rs = selectPS.executeQuery();
            
            double remainingPaid = paidAmount;
            
            while (rs.next() && remainingPaid > 0) {
                int allocationId = rs.getInt("id");
                int chequeId = rs.getInt("cheque_id");
                
                // Update allocation record
                String updateAllocSql = "UPDATE prod_supplier_cheque_allocation " +
                                       "SET status = 'REVERSED', " +
                                       "is_reversed = 1, " +
                                       "reversed_date = CURDATE(), " +
                                       "reversed_time = CURTIME() " +
                                       "WHERE id = ?";
                
                updateAllocPS = con.prepareStatement(updateAllocSql);
                updateAllocPS.setInt(1, allocationId);
                updateAllocPS.executeUpdate();
                updateAllocPS.close();
                
                // Update cheque stock status to AVAILABLE
                String updateChequeSql = "UPDATE prod_supplier_cheque_stock " +
                                        "SET status = 'AVAILABLE' " +
                                        "WHERE id = ?";
                
                updateChequePS = con.prepareStatement(updateChequeSql);
                updateChequePS.setInt(1, chequeId);
                updateChequePS.executeUpdate();
                updateChequePS.close();
                
                System.out.println("Reversed allocation ID " + allocationId + " for cheque " + chequeId);
                
                remainingPaid -= paidAmount;
            }
            
            con.commit();
            System.out.println("Cheque reversal completed for purchase " + purchaseId);
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            System.err.println("Error reversing cheque allocation: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (selectPS != null) try { selectPS.close(); } catch (SQLException e) { ; }
            if (updateAllocPS != null) try { updateAllocPS.close(); } catch (SQLException e) { ; }
            if (updateChequePS != null) try { updateChequePS.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Check and auto-clear cheques after 10 days
    public void checkAndAutoClearCheques() throws Exception {
        Connection con = null;
        PreparedStatement updateAllocPS = null;
        PreparedStatement updateChequePS = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            // Update allocations that have passed due date
            String updateAllocSql = "UPDATE prod_supplier_cheque_allocation " +
                                   "SET status = 'CLEARED', " +
                                   "cleared_date = CURDATE(), " +
                                   "cleared_time = CURTIME() " +
                                   "WHERE status = 'ALLOCATED' " +
                                   "AND CURDATE() >= due_date";
            
            updateAllocPS = con.prepareStatement(updateAllocSql);
            updateAllocPS.executeUpdate();
            
            // Update cheque stock status where all allocations are cleared
            String updateChequeSql = "UPDATE prod_supplier_cheque_stock " +
                                    "SET status = 'CLEARED' " +
                                    "WHERE status IN ('PARTIAL', 'FULLY_USED') " +
                                    "AND id NOT IN ( " +
                                    "  SELECT DISTINCT cheque_id FROM prod_supplier_cheque_allocation " +
                                    "  WHERE status = 'ALLOCATED' " +
                                    ")";
            
            updateChequePS = con.prepareStatement(updateChequeSql);
            updateChequePS.executeUpdate();
            
            con.commit();
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            throw e;
        } finally {
            if (updateAllocPS != null) try { updateAllocPS.close(); } catch (SQLException e) { ; }
            if (updateChequePS != null) try { updateChequePS.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Mark cheque as bounced and restore purchase balances
    public void markChequeBounced(int chequeId, String reason, int uid) throws Exception {
        Connection con = null;
        PreparedStatement selectAllocPS = null;
        PreparedStatement updatePurchasePS = null;
        PreparedStatement updateSupPayPS = null;
        PreparedStatement updateChequePS = null;
        PreparedStatement insertEventPS = null;
        PreparedStatement updateAllocPS = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            System.out.println("Marking supplier cheque " + chequeId + " as bounced");
            
            // Get all allocations for this cheque
            String selectSql = "SELECT a.id, a.purchase_id, a.allocated_amount, " +
                              "p.deal_id, p.balance " +
                              "FROM prod_supplier_cheque_allocation a " +
                              "JOIN prod_purchase p ON a.purchase_id = p.id " +
                              "WHERE a.cheque_id = ? AND a.status IN ('ALLOCATED', 'CLEARED')";
            
            selectAllocPS = con.prepareStatement(selectSql);
            selectAllocPS.setInt(1, chequeId);
            rs = selectAllocPS.executeQuery();
            
            // Restore purchase balances
            while (rs.next()) {
                int purchaseId = rs.getInt("purchase_id");
                int allocationId = rs.getInt("id");
                double allocatedAmount = rs.getDouble("allocated_amount");
                int supplierId = rs.getInt("deal_id");
                double currentBalance = rs.getDouble("balance");
                
                // Restore balance in prod_purchase
                String updatePurchaseSql = "UPDATE prod_purchase " +
                                          "SET balance = balance + ? " +
                                          "WHERE id = ?";
                
                updatePurchasePS = con.prepareStatement(updatePurchaseSql);
                updatePurchasePS.setDouble(1, allocatedAmount);
                updatePurchasePS.setInt(2, purchaseId);
                updatePurchasePS.executeUpdate();
                updatePurchasePS.close();
                
                // Restore balance in prod_purchase_supplier_payment
                String updateSupPaySql = "UPDATE prod_purchase_supplier_payment " +
                                        "SET balance = balance + ? " +
                                        "WHERE prid = ? AND deal_id = ?";
                
                updateSupPayPS = con.prepareStatement(updateSupPaySql);
                updateSupPayPS.setDouble(1, allocatedAmount);
                updateSupPayPS.setInt(2, purchaseId);
                updateSupPayPS.setInt(3, supplierId);
                updateSupPayPS.executeUpdate();
                updateSupPayPS.close();
                
                // Mark allocation as bounced
                String updateAllocSql = "UPDATE prod_supplier_cheque_allocation " +
                                       "SET status = 'BOUNCED' " +
                                       "WHERE id = ?";
                
                updateAllocPS = con.prepareStatement(updateAllocSql);
                updateAllocPS.setInt(1, allocationId);
                updateAllocPS.executeUpdate();
                updateAllocPS.close();
                
                System.out.println("Restored balance for purchase " + purchaseId + 
                                 ", amount: " + allocatedAmount);
            }
            
            // Update cheque status
            String updateChequeSql = "UPDATE prod_supplier_cheque_stock " +
                                    "SET status = 'BOUNCED' " +
                                    "WHERE id = ?";
            
            updateChequePS = con.prepareStatement(updateChequeSql);
            updateChequePS.setInt(1, chequeId);
            updateChequePS.executeUpdate();
            
            // Insert bounce event
            String insertEventSql = "INSERT INTO prod_supplier_cheque_events " +
                                   "(cheque_id, event_type, event_date, event_time, reason, event_uid) " +
                                   "VALUES (?, 'BOUNCE', CURDATE(), CURTIME(), ?, ?)";
            
            insertEventPS = con.prepareStatement(insertEventSql);
            insertEventPS.setInt(1, chequeId);
            insertEventPS.setString(2, reason);
            insertEventPS.setInt(3, uid);
            insertEventPS.executeUpdate();
            
            con.commit();
            System.out.println("Supplier cheque marked as bounced successfully");
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            System.err.println("Error marking cheque as bounced: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (selectAllocPS != null) try { selectAllocPS.close(); } catch (SQLException e) { ; }
            if (updatePurchasePS != null) try { updatePurchasePS.close(); } catch (SQLException e) { ; }
            if (updateSupPayPS != null) try { updateSupPayPS.close(); } catch (SQLException e) { ; }
            if (updateChequePS != null) try { updateChequePS.close(); } catch (SQLException e) { ; }
            if (insertEventPS != null) try { insertEventPS.close(); } catch (SQLException e) { ; }
            if (updateAllocPS != null) try { updateAllocPS.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Mark cheque as expired and restore purchase balances
    public void markChequeExpired(int chequeId, String reason, int uid) throws Exception {
        Connection con = null;
        PreparedStatement selectAllocPS = null;
        PreparedStatement updatePurchasePS = null;
        PreparedStatement updateSupPayPS = null;
        PreparedStatement updateChequePS = null;
        PreparedStatement insertEventPS = null;
        PreparedStatement updateAllocPS = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            System.out.println("Marking supplier cheque " + chequeId + " as expired");
            
            // Get all allocations for this cheque
            String selectSql = "SELECT a.id, a.purchase_id, a.allocated_amount, " +
                              "p.deal_id, p.balance " +
                              "FROM prod_supplier_cheque_allocation a " +
                              "JOIN prod_purchase p ON a.purchase_id = p.id " +
                              "WHERE a.cheque_id = ? AND a.status IN ('ALLOCATED', 'CLEARED')";
            
            selectAllocPS = con.prepareStatement(selectSql);
            selectAllocPS.setInt(1, chequeId);
            rs = selectAllocPS.executeQuery();
            
            // Restore purchase balances
            while (rs.next()) {
                int purchaseId = rs.getInt("purchase_id");
                int allocationId = rs.getInt("id");
                double allocatedAmount = rs.getDouble("allocated_amount");
                int supplierId = rs.getInt("deal_id");
                
                // Restore balance in prod_purchase
                String updatePurchaseSql = "UPDATE prod_purchase " +
                                          "SET balance = balance + ? " +
                                          "WHERE id = ?";
                
                updatePurchasePS = con.prepareStatement(updatePurchaseSql);
                updatePurchasePS.setDouble(1, allocatedAmount);
                updatePurchasePS.setInt(2, purchaseId);
                updatePurchasePS.executeUpdate();
                updatePurchasePS.close();
                
                // Restore balance in prod_purchase_supplier_payment
                String updateSupPaySql = "UPDATE prod_purchase_supplier_payment " +
                                        "SET balance = balance + ? " +
                                        "WHERE prid = ? AND deal_id = ?";
                
                updateSupPayPS = con.prepareStatement(updateSupPaySql);
                updateSupPayPS.setDouble(1, allocatedAmount);
                updateSupPayPS.setInt(2, purchaseId);
                updateSupPayPS.setInt(3, supplierId);
                updateSupPayPS.executeUpdate();
                updateSupPayPS.close();
                
                // Mark allocation status
                String updateAllocSql = "UPDATE prod_supplier_cheque_allocation " +
                                       "SET status = 'BOUNCED' " +
                                       "WHERE id = ?";
                
                updateAllocPS = con.prepareStatement(updateAllocSql);
                updateAllocPS.setInt(1, allocationId);
                updateAllocPS.executeUpdate();
                updateAllocPS.close();
                
                System.out.println("Restored balance for purchase " + purchaseId + 
                                 ", amount: " + allocatedAmount);
            }
            
            // Update cheque status
            String updateChequeSql = "UPDATE prod_supplier_cheque_stock " +
                                    "SET status = 'EXPIRED' " +
                                    "WHERE id = ?";
            
            updateChequePS = con.prepareStatement(updateChequeSql);
            updateChequePS.setInt(1, chequeId);
            updateChequePS.executeUpdate();
            
            // Insert expiry event
            String insertEventSql = "INSERT INTO prod_supplier_cheque_events " +
                                   "(cheque_id, event_type, event_date, event_time, reason, event_uid) " +
                                   "VALUES (?, 'EXPIRY', CURDATE(), CURTIME(), ?, ?)";
            
            insertEventPS = con.prepareStatement(insertEventSql);
            insertEventPS.setInt(1, chequeId);
            insertEventPS.setString(2, reason);
            insertEventPS.setInt(3, uid);
            insertEventPS.executeUpdate();
            
            con.commit();
            System.out.println("Supplier cheque marked as expired successfully");
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            System.err.println("Error marking cheque as expired: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (selectAllocPS != null) try { selectAllocPS.close(); } catch (SQLException e) { ; }
            if (updatePurchasePS != null) try { updatePurchasePS.close(); } catch (SQLException e) { ; }
            if (updateSupPayPS != null) try { updateSupPayPS.close(); } catch (SQLException e) { ; }
            if (updateChequePS != null) try { updateChequePS.close(); } catch (SQLException e) { ; }
            if (insertEventPS != null) try { insertEventPS.close(); } catch (SQLException e) { ; }
            if (updateAllocPS != null) try { updateAllocPS.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Clear cheque allocation when paid by cheque (bankOption = 6)
    public void clearChequeAllocationForPurchase(int purchaseId, double paidAmount) throws Exception {
        Connection con = null;
        PreparedStatement selectPS = null;
        PreparedStatement updateAllocPS = null;
        PreparedStatement updateChequePS = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            System.out.println("Clearing cheques for purchase " + purchaseId + ", amount: " + paidAmount);
            
            // Get allocated cheques for this purchase that are still ALLOCATED
            String selectSql = "SELECT id, cheque_id " +
                              "FROM prod_supplier_cheque_allocation " +
                              "WHERE purchase_id = ? AND status = 'ALLOCATED' " +
                              "ORDER BY allocated_date ASC";
            
            selectPS = con.prepareStatement(selectSql);
            selectPS.setInt(1, purchaseId);
            rs = selectPS.executeQuery();
            
            double remainingAmount = paidAmount;
            
            while (rs.next() && remainingAmount > 0) {
                int allocationId = rs.getInt("id");
                int chequeId = rs.getInt("cheque_id");
                
                // Mark allocation as CLEARED
                String updateAllocSql = "UPDATE prod_supplier_cheque_allocation " +
                                       "SET status = 'CLEARED', " +
                                       "cleared_date = CURDATE(), " +
                                       "cleared_time = CURTIME() " +
                                       "WHERE id = ?";
                
                updateAllocPS = con.prepareStatement(updateAllocSql);
                updateAllocPS.setInt(1, allocationId);
                updateAllocPS.executeUpdate();
                updateAllocPS.close();
                
                System.out.println("Cleared allocation ID " + allocationId + " for cheque " + chequeId);
                
                remainingAmount -= paidAmount;
            }
            
            // Update cheque stock status to CLEARED if all allocations are cleared
            String updateChequeSql = "UPDATE prod_supplier_cheque_stock " +
                                    "SET status = 'CLEARED' " +
                                    "WHERE status IN ('PARTIAL', 'FULLY_USED') " +
                                    "AND id NOT IN ( " +
                                    "  SELECT DISTINCT cheque_id FROM prod_supplier_cheque_allocation " +
                                    "  WHERE status = 'ALLOCATED' " +
                                    ")";
            
            updateChequePS = con.prepareStatement(updateChequeSql);
            updateChequePS.executeUpdate();
            
            con.commit();
            System.out.println("Cheque clearing completed for purchase " + purchaseId);
            
        } catch (Exception e) {
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            System.err.println("Error clearing cheque allocation: " + e.getMessage());
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (selectPS != null) try { selectPS.close(); } catch (SQLException e) { ; }
            if (updateAllocPS != null) try { updateAllocPS.close(); } catch (SQLException e) { ; }
            if (updateChequePS != null) try { updateChequePS.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Get all supplier cheques with supplier details
    public Vector getAllSupplierCheques() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector cheques = new Vector();
            
            String sql = "SELECT c.id, c.cheque_number, c.bank_name, c.status, c.entry_date, " +
                        "s.name AS supplier_name, s.phone_number AS supplier_phone " +
                        "FROM prod_supplier_cheque_stock c " +
                        "LEFT JOIN prod_supplier s ON c.supplier_id = s.id " +
                        "WHERE c.is_active = 1 " +
                        "ORDER BY c.entry_date DESC, c.id DESC";
            
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getInt("id"));                          // 0
                row.add(rs.getString("cheque_number"));             // 1
                row.add(rs.getString("bank_name"));                 // 2
                row.add(rs.getString("status"));                    // 3
                row.add(rs.getString("entry_date"));                // 4
                row.add(rs.getString("supplier_name"));             // 5
                row.add(rs.getString("supplier_phone"));            // 6
                cheques.add(row);
            }
            
            return cheques;
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (ps != null) try { ps.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    // Get allocations for a supplier cheque
    public Vector getChequeAllocations(int chequeId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector allocations = new Vector();
            
            String sql = "SELECT a.id, a.purchase_id, p.invno, p.prno, " +
                        "a.allocated_date, a.due_date, a.status, a.cleared_date, " +
                        "a.allocated_amount, s.name AS supplier_name, p.balance " +
                        "FROM prod_supplier_cheque_allocation a " +
                        "JOIN prod_purchase p ON a.purchase_id = p.id " +
                        "JOIN prod_supplier s ON p.deal_id = s.id " +
                        "WHERE a.cheque_id = ? " +
                        "ORDER BY a.allocated_date DESC";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, chequeId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getInt("id"));                          // 0
                row.add(rs.getInt("purchase_id"));                 // 1
                row.add(rs.getString("invno"));                    // 2 - Invoice number
                row.add(rs.getString("prno"));                     // 3 - Purchase receipt number
                row.add(rs.getString("allocated_date"));           // 4
                row.add(rs.getString("due_date"));                 // 5
                
                // Get status from database
                String dbStatus = rs.getString("status");
                double currentBalance = rs.getDouble("balance");
                
                // If balance is 0 and status is still ALLOCATED, show as REVERSED
                String displayStatus = dbStatus;
                if (currentBalance == 0 && "ALLOCATED".equals(dbStatus)) {
                    displayStatus = "REVERSED";
                }
                
                row.add(displayStatus);                            // 6
                row.add(rs.getString("cleared_date"));             // 7
                row.add(rs.getDouble("allocated_amount"));         // 8
                row.add(rs.getString("supplier_name"));            // 9
                row.add(currentBalance);                           // 10
                allocations.add(row);
            }
            
            return allocations;
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (ps != null) try { ps.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
}
