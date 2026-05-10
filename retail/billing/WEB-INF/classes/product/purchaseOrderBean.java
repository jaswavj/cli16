
package product;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.text.*;

public class purchaseOrderBean {

    public purchaseOrderBean() {
    }
    
    public Connection check() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    /**
     * Create Purchase Order from PR or standalone
     * @param poArr - PO header: supplier<#>expectedDate<#>poNotes<#>prId (prId=0 for standalone)
     * @param prodArr - Product details (same format as PR/PE)
     * @param uid - User ID creating PO
     * @return PO number (PO1, PO2, etc.)
     */
    public String createPurchaseOrder(String poArr, String prodArr, int uid) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            String poNo = "";
            
            // Parse PO header
            String[] poFields = poArr != null ? poArr.split("<#>") : new String[0];
            String supplier = poFields.length > 0 ? poFields[0] : "0";
            String expectedDate = poFields.length > 1 ? poFields[1] : "";
            String poNotes = poFields.length > 2 ? poFields[2] : "";
            String prIdStr = poFields.length > 3 ? poFields[3] : "0";
            String payTypeStr = poFields.length > 4 ? poFields[4] : "0";
            String bankStr = poFields.length > 5 ? poFields[5] : "0";
            String advanceAmountStr = poFields.length > 6 ? poFields[6] : "0";
            String balanceAmountStr = poFields.length > 7 ? poFields[7] : "0";
            
            int prId = Integer.parseInt(prIdStr);
            int payType = Integer.parseInt(payTypeStr);
            int bank = Integer.parseInt(bankStr);
            double advanceAmount = Double.parseDouble(advanceAmountStr);
            double balanceAmount = Double.parseDouble(balanceAmountStr);
            
            // Generate PO number
            pt = con.prepareStatement("SELECT last_po_no FROM prod_purchase_order_counter WHERE id = 1 FOR UPDATE");
            rs = pt.executeQuery();
            int nextPoNo = 1;
            if (rs.next()) {
                nextPoNo = rs.getInt(1) + 1;
            } else {
                // Counter row doesn't exist, create it
                rs.close();
                pt.close();
                pt = con.prepareStatement("INSERT INTO prod_purchase_order_counter (id, last_po_no) VALUES (1, 0)");
                pt.executeUpdate();
                pt.close();
                nextPoNo = 1;
            }
            poNo = "PO" + nextPoNo;
            if (rs != null && !rs.isClosed()) rs.close();
            if (pt != null && !pt.isClosed()) pt.close();
            
            // Update counter
            pt = con.prepareStatement("UPDATE prod_purchase_order_counter SET last_po_no = ? WHERE id = 1");
            pt.setInt(1, nextPoNo);
            pt.executeUpdate();
            pt.close();
            
            // Calculate total
            double totalAmount = 0;
            if (prodArr != null && !prodArr.trim().isEmpty()) {
                String[] productRows = prodArr.split("<@>");
                for (String row : productRows) {
                    if (row.trim().isEmpty()) continue;
                    String[] fields = row.split("<#>");
                    BigDecimal totQty = new BigDecimal(fields[3]);
                    double cost = Double.parseDouble(fields[5]);
                    double tax = Double.parseDouble(fields[8]);
                    double totalamt = totQty.doubleValue() * cost;
                    double taxamt = totalamt * (tax / 100);
                    totalAmount += (totalamt + taxamt);
                }
            }
            
            // Insert PO header (into prod_purchase with is_po=1)
            pt = con.prepareStatement("INSERT INTO prod_purchase(" +
                "prno, invno, invdate, total, paid, balance, discount, net, " +
                "ent_uid, pay_type, bank_id, deal_id, is_po, po_status, pr_id, " +
                "expected_date, po_notes, ent_date, ent_time) " +
                "VALUES(?, '', NOW(), ?, ?, ?, 0, ?, ?, ?, ?, ?, 1, 1, ?, ?, ?, NOW(), NOW())");
            pt.setString(1, poNo);
            pt.setDouble(2, totalAmount);
            pt.setDouble(3, advanceAmount);
            pt.setDouble(4, balanceAmount);
            pt.setDouble(5, totalAmount);
            pt.setInt(6, uid);
            pt.setInt(7, payType);
            pt.setInt(8, bank);
            pt.setInt(9, Integer.parseInt(supplier));
            if (prId > 0) {
                pt.setInt(10, prId);
            } else {
                pt.setNull(10, java.sql.Types.INTEGER);
            }
            pt.setString(11, expectedDate);
            pt.setString(12, poNotes);
            pt.executeUpdate();
            pt.close();
            
            // Get PO ID
            int poId = 0;
            pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase WHERE is_po = 1");
            rs = pt.executeQuery();
            if (rs.next()) poId = rs.getInt(1);
            rs.close();
            pt.close();
            
            // Insert PO details
            if (prodArr != null && !prodArr.trim().isEmpty()) {
                String[] productRows = prodArr.split("<@>");
                for (String row : productRows) {
                    if (row.trim().isEmpty()) continue;
                    String[] fields = row.split("<#>");
                    
                    String productName = fields[0];
                    double pack = Double.parseDouble(fields[1]);
                    BigDecimal qtyPerPack = new BigDecimal(fields[2]);
                    BigDecimal totQty = new BigDecimal(fields[3]);
                    BigDecimal freeQty = new BigDecimal(fields[4]);
                    double cost = Double.parseDouble(fields[5]);
                    double mrp = Double.parseDouble(fields[6]);
                    double disc = Double.parseDouble(fields[7]);
                    double tax = Double.parseDouble(fields[8]);
                    
                    // Calculate amounts
                    double totalamt = totQty.doubleValue() * cost;
                    double taxamt = totalamt * (tax / 100);
                    double sgstper = tax / 2;
                    double cgstper = tax / 2;
                    double sgstAmt = taxamt / 2;
                    double cgstAmt = taxamt / 2;
                    double discAmt = 0;
                    double netamt = totalamt + taxamt - discAmt;
                    double unitcost = totQty.compareTo(BigDecimal.ZERO) > 0 ? cost / totQty.doubleValue() : 0;
                    double unitmrp = totQty.compareTo(BigDecimal.ZERO) > 0 ? mrp / totQty.doubleValue() : 0;
                    
                    // Get product ID
                    int prodsId = 0;
                    pt = con.prepareStatement("SELECT id FROM prod_product WHERE NAME = ?");
                    pt.setString(1, productName);
                    rs = pt.executeQuery();
                    if (rs.next()) prodsId = rs.getInt(1);
                    rs.close();
                    pt.close();
                    
                    // Insert PO detail
                    pt = con.prepareStatement("INSERT INTO prod_purchase_details(" +
                        "prid, prods_id, pack, qtypack, quantity, free, rate, mrp, " +
                        "totalamt, tax, tax_amt, disc_per, disc, netamt, isinvoicereceived, " +
                        "sgst_per, cgst_per, sgst_amt, cgst_amt, unitrate, unitmrp, " +
                        "ordered_qty, received_qty, pending_qty, is_fully_received) " +
                        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, ?, ?, 0, ?, 0)");
                    pt.setInt(1, poId);
                    pt.setInt(2, prodsId);
                    pt.setInt(3, (int) pack);
                    pt.setBigDecimal(4, qtyPerPack);
                    pt.setBigDecimal(5, totQty);
                    pt.setBigDecimal(6, freeQty);
                    pt.setDouble(7, cost);
                    pt.setDouble(8, mrp);
                    pt.setDouble(9, totalamt);
                    pt.setDouble(10, tax);
                    pt.setDouble(11, taxamt);
                    pt.setDouble(12, disc);
                    pt.setDouble(13, discAmt);
                    pt.setDouble(14, netamt);
                    pt.setDouble(15, sgstper);
                    pt.setDouble(16, cgstper);
                    pt.setDouble(17, sgstAmt);
                    pt.setDouble(18, cgstAmt);
                    pt.setDouble(19, unitcost);
                    pt.setDouble(20, unitmrp);
                    pt.setBigDecimal(21, totQty);  // ordered_qty
                    pt.setBigDecimal(22, totQty);  // pending_qty = ordered_qty initially
                    pt.executeUpdate();
                    pt.close();
                }
            }
            
            // If created from PR, update PR status to "Converted to PO"
            if (prId > 0) {
                pt = con.prepareStatement("UPDATE prod_purchase_request SET pr_status = 5, po_id = ? WHERE id = ?");
                pt.setInt(1, poId);
                pt.setInt(2, prId);
                pt.executeUpdate();
                pt.close();
            }
            
            // Insert advance payment if provided
            if (advanceAmount > 0) {
                // Insert into prod_purchase_supplier_payment table
                // Using poId as prid temporarily to link to PO, will be updated when goods are received
                pt = con.prepareStatement("INSERT INTO prod_purchase_supplier_payment(prid, deal_id, total, paid, balance, is_active) VALUES(?, ?, ?, ?, ?, 1)");
                pt.setInt(1, poId); // Temporarily use PO ID, will be updated to actual purchase receipt ID later
                pt.setInt(2, Integer.parseInt(supplier));
                pt.setDouble(3, totalAmount);
                pt.setDouble(4, advanceAmount);
                pt.setDouble(5, balanceAmount);
                pt.executeUpdate();
                pt.close();
                
                // Get the supplier payment ID
                int supPayId = 0;
                pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_supplier_payment");
                rs = pt.executeQuery();
                if (rs.next()) supPayId = rs.getInt(1);
                rs.close();
                pt.close();
                
                // Insert into prod_purchase_supplier_payment_details table
                pt = con.prepareStatement("INSERT INTO prod_purchase_supplier_payment_details(supPayId, payable, paid, balance, pay_type, pay_mode, uid, notes, date, time) VALUES(?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())");
                pt.setInt(1, supPayId);
                pt.setDouble(2, totalAmount);
                pt.setDouble(3, advanceAmount);
                pt.setDouble(4, balanceAmount);
                pt.setInt(5, payType);
                pt.setInt(6, bank);
                pt.setInt(7, uid);
                pt.setString(8, "Advance Payment for PO " + poNo + " (ID: " + poId + ")");
                pt.executeUpdate();
                pt.close();
            }
            
            con.commit();
            return poNo;
            
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    /**
     * Send Purchase Order to supplier (update status to Sent)
     * @param poId - Purchase Order ID
     * @return true if successful
     */
    public boolean sendPurchaseOrder(int poId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            pt = con.prepareStatement("UPDATE prod_purchase SET po_status = 2 WHERE id = ? AND is_po = 1");
            pt.setInt(1, poId);
            int rowsUpdated = pt.executeUpdate();
            
            con.commit();
            return rowsUpdated > 0;
            
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    /**
     * Get all Purchase Orders with optional status filter
     * @param status - 0=All, 1=Draft, 2=Sent, 3=Partially Received, 4=Completed
     * @return Vector of PO records
     */
    public Vector getPurchaseOrders(int status) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector list = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT po.id, po.prno, po.invdate, po.expected_date, po.total, po.po_status, ");
            sql.append("po.po_notes, po.pr_id, s.name as supplier_name, u.user_name, ");
            sql.append("COALESCE(SUM(pod.ordered_qty), 0) as total_ordered, ");
            sql.append("COALESCE(SUM(pod.received_qty), 0) as total_received, ");
            sql.append("COALESCE(SUM(pod.pending_qty), 0) as total_pending ");
            sql.append("FROM prod_purchase po ");
            sql.append("LEFT JOIN prod_supplier s ON po.deal_id = s.id ");
            sql.append("LEFT JOIN users u ON po.ent_uid = u.id ");
            sql.append("LEFT JOIN prod_purchase_details pod ON po.id = pod.prid ");
            sql.append("WHERE po.is_po = 1 AND po.is_cancelled = 0 ");
            sql.append("AND po.po_status IN (1, 2, 3) AND pod.is_fully_received=0 ");
            sql.append("GROUP BY po.id ORDER BY po.id DESC");
            
            pt = con.prepareStatement(sql.toString());
            
            
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getInt("id"));
                row.add(rs.getString("prno"));
                row.add(rs.getString("invdate"));
                row.add(rs.getString("expected_date"));
                row.add(rs.getDouble("total"));
                row.add(rs.getInt("po_status"));
                row.add(rs.getString("po_notes"));
                row.add(rs.getString("supplier_name"));
                row.add(rs.getString("user_name"));
                row.add(rs.getInt("total_ordered"));
                row.add(rs.getInt("total_received"));
                row.add(rs.getInt("total_pending"));
                
                // Calculate completion percentage
                int totalOrdered = rs.getInt("total_ordered");
                int totalReceived = rs.getInt("total_received");
                double completionPercent = totalOrdered > 0 ? (totalReceived * 100.0 / totalOrdered) : 0;
                row.add(completionPercent);
                
                list.add(row);
            }
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
        
        return list;
    }
    
    /**
     * Get PO details with pending items
     * @param poId - Purchase Order ID
     * @return Vector containing PO header and pending line items
     */
    public Vector getPOPendingItems(int poId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector result = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Get header
            pt = con.prepareStatement("SELECT po.*, s.name as supplier_name, u.user_name " +
                "FROM prod_purchase po " +
                "LEFT JOIN prod_supplier s ON po.deal_id = s.id " +
                "LEFT JOIN users u ON po.ent_uid = u.id " +
                "WHERE po.id = ? AND po.is_po = 1");
            pt.setInt(1, poId);
            rs = pt.executeQuery();
            
            if (rs.next()) {
                Vector header = new Vector();
                header.add(rs.getInt("id"));
                header.add(rs.getString("prno"));
                header.add(rs.getString("invdate"));
                header.add(rs.getString("expected_date"));
                header.add(rs.getInt("deal_id"));
                header.add(rs.getString("supplier_name"));
                header.add(rs.getDouble("total"));
                header.add(rs.getInt("po_status"));
                header.add(rs.getString("po_notes"));
                header.add(rs.getString("user_name"));
                result.add(header);
            }
            
            // Get pending line items
            Vector items = new Vector();
            pt = con.prepareStatement("SELECT pd.*, p.name as product_name, " +
                "COALESCE(pd.quantity, 0) as quantity, " +
                "COALESCE(pd.ordered_qty, pd.quantity, 0) as ordered_qty, " +
                "COALESCE(pd.received_qty, 0) as received_qty, " +
                "COALESCE(pd.pending_qty, pd.quantity, 0) as pending_qty, " +
                "COALESCE(pd.is_fully_received, 0) as is_fully_received " +
                "FROM prod_purchase_details pd " +
                "JOIN prod_product p ON pd.prods_id = p.id " +
                "WHERE pd.prid = ? AND COALESCE(pd.is_fully_received, 0) = 0");
            pt.setInt(1, poId);
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector item = new Vector();
                item.add(rs.getString("product_name"));        // 0
                item.add("-");                                 // 1: batch_name (not tracked in this system)
                item.add("PCS");                               // 2: unit_name (hardcoded as no unit table exists)
                item.add(rs.getDouble("rate"));                // 3
                item.add(rs.getBigDecimal("ordered_qty"));            // 4
                item.add(rs.getBigDecimal("received_qty"));           // 5
                item.add(rs.getBigDecimal("pending_qty"));            // 6
                item.add(rs.getDouble("mrp"));                 // 7
                item.add(rs.getInt("id"));                     // 8: po_detail_id
                item.add(rs.getInt("prods_id"));               // 9: product_id
                item.add(0);                                   // 10: batch_id (not used in this system)
                item.add(rs.getDouble("tax"));                 // 11
                item.add(rs.getInt("pack"));                   // 12
                item.add(rs.getBigDecimal("qtypack"));                // 13
                item.add(rs.getInt("free"));                   // 14
                item.add(rs.getDouble("disc_per"));            // 15
                items.add(item);
            }
            result.add(items);
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
        
        return result;
    }
    
    /**
     * Get ALL items for a PO (both pending and received) for the details view
     * @param poId - Purchase Order ID
     * @return Vector with all PO items
     */
    public Vector getPOAllItems(int poId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector items = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Get ALL line items (not just pending)
            pt = con.prepareStatement("SELECT pd.*, p.name as product_name, " +
                "COALESCE(pd.quantity, 0) as quantity, " +
                "COALESCE(pd.ordered_qty, pd.quantity, 0) as ordered_qty, " +
                "COALESCE(pd.received_qty, 0) as received_qty, " +
                "COALESCE(pd.pending_qty, pd.quantity, 0) as pending_qty, " +
                "COALESCE(pd.is_fully_received, 0) as is_fully_received " +
                "FROM prod_purchase_details pd " +
                "JOIN prod_product p ON pd.prods_id = p.id " +
                "WHERE pd.prid = ?");
            pt.setInt(1, poId);
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector item = new Vector();
                item.add(rs.getString("product_name"));        // 0
                item.add("-");                                 // 1: batch_name (not tracked in this system)
                item.add("PCS");                               // 2: unit_name (hardcoded as no unit table exists)
                item.add(rs.getDouble("rate"));                // 3
                item.add(rs.getBigDecimal("ordered_qty"));            // 4
                item.add(rs.getBigDecimal("received_qty"));           // 5
                item.add(rs.getBigDecimal("pending_qty"));            // 6
                item.add(rs.getInt("is_fully_received"));      // 7
                item.add(rs.getInt("id"));                     // 8: po_detail_id
                items.add(item);
            }
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
        
        return items;
    }
    
    /**
     * Create Purchase Entry from PO (Goods Receipt)
     * @param poId - Purchase Order ID
     * @param receiptData - Receipt info: receiptDate<#>invoiceNo<#>challanNo<#>receiptNotes<#>supplierId
     * @param receivedArr - Received items: po_detail_id<#>prodId<#>batchId<#>qty<#>rate<$>...
     * @param uid - User ID receiving goods
     * @return PE number (PR1, PR2, etc.)
     */
    public String createPurchaseEntryFromPO(int poId, String receiptData, String receivedArr, int uid) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            // Parse receipt data: receiptDate<#>invoiceNo<#>challanNo<#>receiptNotes<#>supplierId
            String[] receiptFields = receiptData != null ? receiptData.split("<#>") : new String[0];
            String receiptDate = receiptFields.length > 0 ? receiptFields[0] : "";
            String invoiceNo = receiptFields.length > 1 ? receiptFields[1] : "";
            String challanNo = receiptFields.length > 2 ? receiptFields[2] : "";
            String notes = receiptFields.length > 3 ? receiptFields[3] : "";
            int supplierId = receiptFields.length > 4 ? Integer.parseInt(receiptFields[4]) : 0;
            
            // Generate PE number
            String peNo = "";
            pt = con.prepareStatement("SELECT COUNT(id)+1 FROM prod_purchase WHERE is_po = 0");
            rs = pt.executeQuery();
            if (rs.next())
                peNo = "PR" + rs.getString(1);
            
            // Calculate totals from received items
            double grandTotal = 0;
            if (receivedArr != null && !receivedArr.trim().isEmpty()) {
                String[] receivedItems = receivedArr.split("<\\$>");
                for (String item : receivedItems) {
                    if (item.trim().isEmpty()) continue;
                    String[] fields = item.split("<#>");
                    int poDetailId = Integer.parseInt(fields[0]);
                    BigDecimal receivedQty = new BigDecimal(fields[3]);
                    
                    // Get item cost and tax
                    pt = con.prepareStatement("SELECT rate, tax FROM prod_purchase_details WHERE id = ?");
                    pt.setInt(1, poDetailId);
                    rs = pt.executeQuery();
                    if (rs.next()) {
                        double rate = rs.getDouble(1);
                        double tax = rs.getDouble(2);
                        double totalamt = receivedQty.doubleValue() * rate;
                        double taxamt = totalamt * (tax / 100);
                        grandTotal += (totalamt + taxamt);
                    }
                }
            }
            
            // Insert PE header
            pt = con.prepareStatement("INSERT INTO prod_purchase(" +
                "prno, invno, invdate, total, paid, balance, discount, net, " +
                "ent_uid, pay_type, bank_id, deal_id, is_po, ent_date, ent_time) " +
                "VALUES(?, ?, ?, ?, 0, ?, 0, ?, ?, 1, 0, ?, 0, NOW(), NOW())");
            pt.setString(1, peNo);
            pt.setString(2, invoiceNo);
            pt.setString(3, receiptDate);
            pt.setDouble(4, grandTotal);
            pt.setDouble(5, grandTotal);
            pt.setDouble(6, grandTotal);
            pt.setInt(7, uid);
            pt.setInt(8, supplierId);
            pt.executeUpdate();
            
            // Get PE ID
            int peId = 0;
            pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase WHERE is_po = 0");
            rs = pt.executeQuery();
            if (rs.next()) peId = rs.getInt(1);
            
            // Create link between PO and PE
            pt = con.prepareStatement("INSERT INTO prod_purchase_entry_link(" +
                "po_id, pe_id, receipt_no, receipt_date, received_by, notes, " +
                "created_date, created_time, uid) " +
                "VALUES(?, ?, ?, ?, ?, ?, NOW(), NOW(), ?)");
            pt.setInt(1, poId);
            pt.setInt(2, peId);
            pt.setString(3, challanNo);    // Challan is the receipt/delivery note number
            pt.setString(4, receiptDate);
            pt.setInt(5, uid);
            pt.setString(6, notes);
            pt.setInt(7, uid);
            pt.executeUpdate();
            
            // Get link ID
            int linkId = 0;
            pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_entry_link");
            rs = pt.executeQuery();
            if (rs.next()) linkId = rs.getInt(1);
            
            // Insert PE details and update PO
            if (receivedArr != null && !receivedArr.trim().isEmpty()) {
                String[] receivedItems = receivedArr.split("<\\$>");
                for (String item : receivedItems) {
                    if (item.trim().isEmpty()) continue;
                    String[] fields = item.split("<#>");
                    int poDetailId = Integer.parseInt(fields[0]);
                    BigDecimal receivedQty = new BigDecimal(fields[3]);
                    
                    // Validate: received_qty must not exceed pending_qty
                    pt = con.prepareStatement("SELECT pending_qty FROM prod_purchase_details WHERE id = ?");
                    pt.setInt(1, poDetailId);
                    rs = pt.executeQuery();
                    if (rs.next()) {
                        BigDecimal pendingQty = rs.getBigDecimal(1);
                        if (receivedQty.compareTo(pendingQty) > 0) {
                            throw new Exception("Received quantity (" + receivedQty + ") exceeds pending quantity (" + pendingQty + ")");
                        }
                    }
                    
                    // Get PO line item details
                    pt = con.prepareStatement("SELECT * FROM prod_purchase_details WHERE id = ?");
                    pt.setInt(1, poDetailId);
                    rs = pt.executeQuery();
                    
                    if (rs.next()) {
                        int prodsId = rs.getInt("prods_id");
                        double rate = rs.getDouble("rate");
                        double mrp = rs.getDouble("mrp");
                        double tax = rs.getDouble("tax");
                        int pack = rs.getInt("pack");
                        BigDecimal qtypack = rs.getBigDecimal("qtypack");
                        BigDecimal free = rs.getBigDecimal("free");
                        double discPer = rs.getDouble("disc_per");
                        
                        // Calculate amounts
                        double totalamt = receivedQty.doubleValue() * rate;
                        double taxamt = totalamt * (tax / 100);
                        double sgstper = tax / 2;
                        double cgstper = tax / 2;
                        double sgstAmt = taxamt / 2;
                        double cgstAmt = taxamt / 2;
                        double discAmt = 0;
                        double netamt = totalamt + taxamt - discAmt;
                        double unitcost = receivedQty.compareTo(BigDecimal.ZERO) > 0 ? rate : 0;
                        double unitmrp = receivedQty.compareTo(BigDecimal.ZERO) > 0 ? mrp : 0;
                        
                        // Insert PE detail
                        pt = con.prepareStatement("INSERT INTO prod_purchase_details(" +
                            "prid, prods_id, pack, qtypack, quantity, free, rate, mrp, " +
                            "totalamt, tax, tax_amt, disc_per, disc, netamt, isinvoicereceived, " +
                            "sgst_per, cgst_per, sgst_amt, cgst_amt, unitrate, unitmrp) " +
                            "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?, ?)");
                        pt.setInt(1, peId);
                        pt.setInt(2, prodsId);
                        pt.setInt(3, pack);
                        pt.setBigDecimal(4, qtypack);
                        pt.setBigDecimal(5, receivedQty);
                        pt.setBigDecimal(6, free);
                        pt.setDouble(7, rate);
                        pt.setDouble(8, mrp);
                        pt.setDouble(9, totalamt);
                        pt.setDouble(10, tax);
                        pt.setDouble(11, taxamt);
                        pt.setDouble(12, discPer);
                        pt.setDouble(13, discAmt);
                        pt.setDouble(14, netamt);
                        pt.setDouble(15, sgstper);
                        pt.setDouble(16, cgstper);
                        pt.setDouble(17, sgstAmt);
                        pt.setDouble(18, cgstAmt);
                        pt.setDouble(19, unitcost);
                        pt.setDouble(20, unitmrp);
                        pt.executeUpdate();
                        
                        // Get PE detail ID
                        int peDetailId = 0;
                        pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_details");
                        rs = pt.executeQuery();
                        if (rs.next()) peDetailId = rs.getInt(1);
                        
                        // Create link between PO detail and PE detail
                        pt = con.prepareStatement("INSERT INTO prod_purchase_entry_details_link(" +
                            "link_id, po_detail_id, pe_detail_id, quantity_received) " +
                            "VALUES(?, ?, ?, ?)");
                        pt.setInt(1, linkId);  // link_id references the prod_purchase_entry_link.id
                        pt.setInt(2, poDetailId);
                        pt.setInt(3, peDetailId);
                        pt.setBigDecimal(4, receivedQty);
                        pt.executeUpdate();
                        
                        // Update PO line item
                        pt = con.prepareStatement("UPDATE prod_purchase_details SET " +
                            "received_qty = received_qty + ?, " +
                            "pending_qty = ordered_qty - received_qty - ?, " +
                            "is_fully_received = CASE WHEN (ordered_qty - received_qty - ?) = 0 THEN 1 ELSE 0 END " +
                            "WHERE id = ?");
                        pt.setBigDecimal(1, receivedQty);
                        pt.setBigDecimal(2, receivedQty);
                        pt.setBigDecimal(3, receivedQty);
                        pt.setInt(4, poDetailId);
                        pt.executeUpdate();
                        
                        // Update stock (same logic as direct purchase)
                        BigDecimal stock = receivedQty.add(free);
                        String userNotes = "While Stock Added Through Purchase Entry from PO";
                        
                        // Update product GST
                        pt = con.prepareStatement("UPDATE prod_product SET gst=? WHERE id = ?");
                        pt.setDouble(1, tax);
                        pt.setInt(2, prodsId);
                        pt.executeUpdate();
                        
                        // Update stock in prod_batch
                        pt = con.prepareStatement("UPDATE prod_batch SET stock = stock + ? WHERE product_id = ?");
                        pt.setBigDecimal(1, stock);
                        pt.setInt(2, prodsId);
                        pt.executeUpdate();
                        
                        // Get previous stock
                        BigDecimal stocknow = BigDecimal.ZERO;
                        pt = con.prepareStatement("SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
                        pt.setInt(1, prodsId);
                        rs = pt.executeQuery();
                        if (rs.next()) {
                            stocknow = rs.getBigDecimal(1);
                        }
                        
                        // Insert lifecycle record
                        pt = con.prepareStatement("INSERT INTO prod_lifecycle(" +
                            "batch_id, product_id, stock_in, stock_now, is_zero_stock_bill, " +
                            "notes, uid, stock_type, DATE, TIME) " +
                            "VALUES(1, ?, ?, ?, 2, ?, ?, 2, NOW(), NOW())");
                        pt.setInt(1, prodsId);
                        pt.setBigDecimal(2, stock);
                        pt.setBigDecimal(3, stock.add(stocknow));
                        pt.setString(4, userNotes);
                        pt.setInt(5, uid);
                        pt.executeUpdate();
                        
                        // Update or insert prod_stock_totals
                        int prodTotId = 0;
                        pt = con.prepareStatement("SELECT id FROM prod_stock_totals WHERE prods_id = ?");
                        pt.setInt(1, prodsId);
                        rs = pt.executeQuery();
                        if (rs.next()) prodTotId = rs.getInt(1);
                        
                        if (prodTotId == 0) {
                            pt = con.prepareStatement("INSERT INTO prod_stock_totals(prods_id, stock, userlog) VALUES(?, ?, ?)");
                            pt.setInt(1, prodsId);
                            pt.setBigDecimal(2, stock);
                            pt.setString(3, userNotes);
                            pt.executeUpdate();
                        } else {
                            pt = con.prepareStatement("UPDATE prod_stock_totals SET stock=stock+?, userlog=? WHERE prods_id=?");
                            pt.setBigDecimal(1, stock);
                            pt.setString(2, userNotes);
                            pt.setInt(3, prodsId);
                            pt.executeUpdate();
                        }
                    }
                }
            }
            
            // Update PO status
            updatePOStatus(con, poId);
            
            con.commit();
            return peNo;
            
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
    
    /**
     * Update PO status based on received quantities
     * @param con - Database connection (for transaction)
     * @param poId - Purchase Order ID
     */
    private void updatePOStatus(Connection con, int poId) throws SQLException {
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            // Calculate totals
            pt = con.prepareStatement("SELECT " +
                "SUM(pending_qty) as total_pending, " +
                "SUM(CASE WHEN received_qty > 0 THEN 1 ELSE 0 END) as partial_count " +
                "FROM prod_purchase_details WHERE prid = ?");
            pt.setInt(1, poId);
            rs = pt.executeQuery();
            
            int newStatus = 2;  // Default: Sent
            if (rs.next()) {
                int totalPending = rs.getInt("total_pending");
                int partialCount = rs.getInt("partial_count");
                
                if (totalPending == 0) {
                    newStatus = 4;  // Completed
                } else if (partialCount > 0) {
                    newStatus = 3;  // Partially Received
                }
            }
            
            // Update PO status
            pt = con.prepareStatement("UPDATE prod_purchase SET po_status = ? WHERE id = ?");
            pt.setInt(1, newStatus);
            pt.setInt(2, poId);
            pt.executeUpdate();
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        }
    }
    
    /**
     * Get receipt history for a PO
     * @param poId - Purchase Order ID
     * @return Vector of PE records linked to this PO
     */
    public Vector getPOReceiptHistory(int poId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector list = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            pt = con.prepareStatement("SELECT pe.id, pe.prno, pe.invdate, u.user_name, " +
                "COUNT(DISTINCT pd.id) as items_received, pe.total " +
                "FROM prod_purchase_entry_link l " +
                "JOIN prod_purchase pe ON l.pe_id = pe.id " +
                "LEFT JOIN users u ON pe.ent_uid = u.id " +
                "LEFT JOIN prod_purchase_details pd ON pd.prid = pe.id " +
                "WHERE l.po_id = ? " +
                "GROUP BY pe.id, pe.prno, pe.invdate, u.user_name, pe.total " +
                "ORDER BY pe.invdate DESC, pe.id DESC");
            pt.setInt(1, poId);
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getInt("id"));           // 0: PE ID
                row.add(rs.getString("prno"));      // 1: PE Number
                row.add(rs.getString("invdate"));   // 2: Receipt Date
                row.add(rs.getString("user_name")); // 3: Received By
                row.add(rs.getInt("items_received")); // 4: Items Count
                row.add(rs.getDouble("total"));     // 5: Total Amount
                list.add(row);
            }
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
        
        return list;
    }
    
    /**
     * Get PO Header details
     * @param poId - Purchase Order ID
     * @return Vector with PO header data
     */
    public Vector getPOHeader(int poId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector header = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            pt = con.prepareStatement("SELECT po.prno, po.invdate, po.expected_date, po.total, po.po_status, " +
                "po.po_notes, s.name as supplier_name, u.user_name, po.pr_id, pr.req_no, s.id as supplier_id " +
                "FROM prod_purchase po " +
                "LEFT JOIN prod_supplier s ON po.deal_id = s.id " +
                "LEFT JOIN users u ON po.ent_uid = u.id " +
                "LEFT JOIN prod_purchase_request pr ON po.pr_id = pr.id " +
                "WHERE po.id = ?");
            pt.setInt(1, poId);
            rs = pt.executeQuery();
            
            if (rs.next()) {
                header.add(rs.getString("prno"));         // 0: PO Number
                header.add(rs.getString("invdate"));      // 1: PO Date
                header.add(rs.getString("expected_date")); // 2: Expected Date
                header.add(rs.getDouble("total"));        // 3: Total Amount
                header.add(rs.getInt("po_status"));       // 4: PO Status
                header.add(rs.getString("po_notes"));     // 5: Notes
                header.add(rs.getString("supplier_name")); // 6: Supplier Name
                header.add(rs.getString("user_name"));    // 7: Created By
                header.add(rs.getObject("pr_id") != null ? rs.getInt("pr_id") : null); // 8: PR ID
                header.add(rs.getString("req_no"));       // 9: PR Number
                header.add(rs.getInt("supplier_id"));     // 10: Supplier ID
            }
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
        
        return header;
    }
    
    /**
     * Get advance payment details for a PO
     */
    public Vector getPOAdvancePayment(int poId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector payment = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Find advance payment using the notes field which contains the PO ID
            pt = con.prepareStatement(
                "SELECT sp.total, sp.paid, sp.balance " +
                "FROM prod_purchase_supplier_payment sp " +
                "JOIN prod_purchase_supplier_payment_details spd ON sp.id = spd.supPayId " +
                "WHERE sp.prid = ? AND spd.notes LIKE ? " +
                "ORDER BY spd.date DESC, spd.time DESC LIMIT 1"
            );
            pt.setInt(1, poId);
            pt.setString(2, "%Advance Payment for PO%ID: " + poId + ")%");
            rs = pt.executeQuery();
            
            if (rs.next()) {
                payment.add(rs.getDouble("total"));    // 0: Total
                payment.add(rs.getDouble("paid"));     // 1: Advance Paid
                payment.add(rs.getDouble("balance"));  // 2: Balance
            }
            
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
        
        return payment;
    }
}
