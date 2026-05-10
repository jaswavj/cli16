
package product;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.text.*;

public class purchaseRequestBean {

    public purchaseRequestBean() {
    }
    
    public Connection check() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    /**
     * Create a new Purchase Request
     * @param reqArr - Request header data: supplier<#>reqDate<#>notes
     * @param prodArr - Product details: productName<#>pack<#>qtypack<#>totqty<#>free<#>cost<#>mrp<#>disc<#>tax<@>...
     * @param uid - User ID creating the request
     * @return Request number (REQ1, REQ2, etc.)
     */
    public String createPurchaseRequest(String reqArr, String prodArr, int uid) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);  // Start transaction
            
            String reqNo = "";
            
            // Parse request header
            String[] reqFields = reqArr != null ? reqArr.split("<#>") : new String[0];
            String supplier = reqFields.length > 0 ? reqFields[0] : "0";  // Can be 0 for TBD
            String reqDate = reqFields.length > 1 ? reqFields[1] : "";
            String notes = reqFields.length > 2 ? reqFields[2] : "";
            
            // Generate request number
            pt = con.prepareStatement("SELECT last_req_no FROM prod_purchase_request_counter WHERE id = 1 FOR UPDATE");
            rs = pt.executeQuery();
            int nextReqNo = 1;
            if (rs.next()) {
                nextReqNo = rs.getInt(1) + 1;
            } else {
                // Counter row doesn't exist, create it
                rs.close();
                pt.close();
                pt = con.prepareStatement("INSERT INTO prod_purchase_request_counter (id, last_req_no) VALUES (1, 0)");
                pt.executeUpdate();
                pt.close();
                nextReqNo = 1;
            }
            reqNo = "REQ" + nextReqNo;
            if (rs != null && !rs.isClosed()) rs.close();
            if (pt != null && !pt.isClosed()) pt.close();
            
            // Update counter
            pt = con.prepareStatement("UPDATE prod_purchase_request_counter SET last_req_no = ? WHERE id = 1");
            pt.setInt(1, nextReqNo);
            pt.executeUpdate();
            pt.close();
            
            // Calculate total from products
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
            
            // Insert PR header
            pt = con.prepareStatement("INSERT INTO prod_purchase_request(" +
                "req_no, req_date, req_time, deal_id, total, pr_status, notes, " +
                "requested_by, ent_date, ent_time, ent_uid) " +
                "VALUES(?, ?, NOW(), ?, ?, 1, ?, ?, NOW(), NOW(), ?)");
            pt.setString(1, reqNo);
            pt.setString(2, reqDate);
            pt.setInt(3, Integer.parseInt(supplier));
            pt.setDouble(4, totalAmount);
            pt.setString(5, notes);
            pt.setInt(6, uid);
            pt.setInt(7, uid);
            pt.executeUpdate();
            pt.close();
            
            // Get PR ID
            int prId = 0;
            pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_request");
            rs = pt.executeQuery();
            if (rs.next()) prId = rs.getInt(1);
            rs.close();
            pt.close();
            
            // Insert PR details
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
                    double discAmt = 0;
                    double netamt = totalamt + taxamt - discAmt;
                    
                    // Get product ID
                    int prodsId = 0;
                    pt = con.prepareStatement("SELECT id FROM prod_product WHERE NAME = ?");
                    pt.setString(1, productName);
                    rs = pt.executeQuery();
                    if (rs.next()) prodsId = rs.getInt(1);
                    rs.close();
                    pt.close();
                    
                    // Insert PR detail
                    pt = con.prepareStatement("INSERT INTO prod_purchase_request_details(" +
                        "pr_id, prods_id, pack, qtypack, quantity, free, rate, mrp, " +
                        "total, tax, tax_amt, disc_per, disc_amt, net) " +
                        "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                    pt.setInt(1, prId);
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
                    pt.executeUpdate();
                    pt.close();
                }
            }
            
            con.commit();
            return reqNo;
            
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
     * Get all Purchase Requests with optional status filter
     * @param status - 0=All, 1=Draft, 2=Submitted, 3=Approved, 4=Rejected, 5=Converted
     * @return Vector of PR records
     */
    public Vector getPurchaseRequests(int status) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector list = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT pr.id, pr.req_no, pr.req_date, pr.req_time, pr.total, pr.pr_status, ");
            sql.append("pr.notes, pr.requested_by, pr.approver_id, pr.approved_date, ");
            sql.append("COALESCE(s.name, 'TBD') as supplier_name, u.user_name as requester_name, ");
            sql.append("COALESCE(a.user_name, '') as approver_name ");
            sql.append("FROM prod_purchase_request pr ");
            sql.append("LEFT JOIN prod_supplier s ON pr.deal_id = s.id ");
            sql.append("LEFT JOIN users u ON pr.requested_by = u.id ");
            sql.append("LEFT JOIN users a ON pr.approver_id = a.id ");
            sql.append("WHERE pr.is_cancelled = 0 ");
            //sql.append("AND pr.pr_status != 3 ");  // Always exclude Converted to PO (status 3)
            
            if (status > 0) {
                sql.append("AND pr.pr_status = ? ");
            } else {
                // By default, show only pending PRs (Draft=1 and Approved=2, exclude Rejected=4)
                sql.append("AND pr.pr_status IN (1, 2) ");
            }
            
            sql.append("ORDER BY pr.id DESC");
            
            pt = con.prepareStatement(sql.toString());
            if (status > 0) {
                pt.setInt(1, status);
            }
            
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getInt("id"));
                row.add(rs.getString("req_no"));
                row.add(rs.getString("req_date"));
                row.add(rs.getString("req_time"));
                row.add(rs.getDouble("total"));
                row.add(rs.getInt("pr_status"));
                row.add(rs.getString("notes"));
                row.add(rs.getString("supplier_name"));
                row.add(rs.getString("requester_name"));
                row.add(rs.getString("approver_name"));
                row.add(rs.getString("approved_date") != null ? rs.getString("approved_date") : "");
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
     * Get Purchase Request details by ID
     * @param prId - Purchase Request ID
     * @return Vector containing PR header and details
     */
    public Vector getPurchaseRequestDetails(int prId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector result = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Get header
            pt = con.prepareStatement("SELECT pr.*, COALESCE(s.name, 'TBD') as supplier_name, " +
                "u.user_name as requester_name " +
                "FROM prod_purchase_request pr " +
                "LEFT JOIN prod_supplier s ON pr.deal_id = s.id " +
                "LEFT JOIN users u ON pr.requested_by = u.id " +
                "WHERE pr.id = ?");
            pt.setInt(1, prId);
            rs = pt.executeQuery();
            
            if (rs.next()) {
                Vector header = new Vector();
                header.add(rs.getInt("id"));
                header.add(rs.getString("req_no"));
                header.add(rs.getString("req_date"));
                header.add(rs.getInt("deal_id"));
                header.add(rs.getString("supplier_name"));
                header.add(rs.getDouble("total"));
                header.add(rs.getInt("pr_status"));
                header.add(rs.getString("notes"));
                header.add(rs.getString("requester_name"));
                result.add(header);
            }
            
            // Get line items
            Vector items = new Vector();
            pt = con.prepareStatement("SELECT prd.*, p.name as product_name " +
                "FROM prod_purchase_request_details prd " +
                "JOIN prod_product p ON prd.prods_id = p.id " +
                "WHERE prd.pr_id = ?");
            pt.setInt(1, prId);
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector item = new Vector();
                item.add(rs.getInt("id"));
                item.add(rs.getInt("prods_id"));
                item.add(rs.getString("product_name"));
                item.add(rs.getInt("pack"));
                item.add(rs.getBigDecimal("qtypack"));
                item.add(rs.getBigDecimal("quantity"));
                item.add(rs.getInt("free"));
                item.add(rs.getDouble("rate"));
                item.add(rs.getDouble("mrp"));
                item.add(rs.getDouble("total"));
                item.add(rs.getDouble("tax"));
                item.add(rs.getDouble("net"));
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
     * Approve or Reject Purchase Request
     * @param prId - Purchase Request ID
     * @param action - 3=Approve, 4=Reject
     * @param approverId - User ID approving/rejecting
     * @param notes - Approval/rejection notes
     */
    public void updatePRStatus(int prId, int action, int approverId, String notes) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            pt = con.prepareStatement("UPDATE prod_purchase_request SET " +
                "pr_status = ?, approver_id = ?, approved_date = NOW(), " +
                "approved_time = NOW(), approval_notes = ? " +
                "WHERE id = ?");
            pt.setInt(1, action);
            pt.setInt(2, approverId);
            pt.setString(3, notes);
            pt.setInt(4, prId);
            pt.executeUpdate();
            
            con.commit();
            
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (SQLException e) { ; }
        }
    }
}
