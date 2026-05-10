package product;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/**
 * purchaseReturnBean
 * ------------------
 * Self-contained bean for Purchase Edit, Cancel, and Return operations.
 * Extracted from productBean so this feature can be deployed independently
 * to any client without the full productBean dependency.
 *
 * Methods included:
 *   - GetSupplier()
 *   - getPurchaseHeaderById(int)
 *   - getPurchaseIdByPrno(String)
 *   - getPurchaseDetailsForEdit(int)
 *   - getAlreadyReturnedQtyForPurchase(int)
 *   - editPurchaseItemPrice(int, int, double, double, String, int)
 *   - cancelPurchaseItem(int, int, String, int)
 *   - savePurchaseReturn(int, String, String, int)
 *   - getPurchaseReturnList(String, String, int)
 *   - getPurchaseReturnDetails(int)
 */
public class purchaseReturnBean {

    public purchaseReturnBean() {
    }

    public Connection check() throws SQLException {
        return util.DBConnectionManager.getConnectionFromPool();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helper / Lookup methods
    // ─────────────────────────────────────────────────────────────────────────

    public Vector GetSupplier() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector vec = new Vector();
            pt = con.prepareStatement("SELECT id, NAME FROM prod_supplier WHERE is_active=1 ORDER BY name");
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector vec1 = new Vector();
                vec1.addElement(rs.getString(1));
                vec1.addElement(rs.getString(2));
                vec.addElement(vec1);
            }
            return vec;
        } finally {
            if (rs  != null) try { rs.close();  } catch (SQLException e) { ; }
            if (pt  != null) try { pt.close();  } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e)   { ; }
        }
    }

    public Vector getPurchaseHeaderById(int purchaseId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vec = new Vector();
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT a.`id`, a.`invno`, a.`invdate`, a.`total`, a.`paid`, a.`balance`, a.`ent_date`, a.`ent_time`, b.user_name, c.name " +
                         "FROM `prod_purchase` a, users b, prod_supplier c " +
                         "WHERE a.`ent_uid` = b.id AND c.id = a.deal_id AND a.`id` = ? AND a.is_cancelled = 0";
            ps = con.prepareStatement(sql);
            ps.setInt(1, purchaseId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getString(1));  // 0 id
                row.addElement(rs.getString(2));  // 1 invno
                row.addElement(rs.getString(3));  // 2 invdate
                row.addElement(rs.getString(4));  // 3 total
                row.addElement(rs.getString(5));  // 4 paid
                row.addElement(rs.getString(6));  // 5 balance
                row.addElement(rs.getString(7));  // 6 ent_date
                row.addElement(rs.getString(8));  // 7 ent_time
                row.addElement(rs.getString(9));  // 8 user_name
                row.addElement(rs.getString(10)); // 9 supplier name
                vec.add(row);
            }
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
        return vec;
    }

    public int getPurchaseIdByPrno(String prno) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int purchaseId = 0;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            ps = con.prepareStatement("SELECT id FROM prod_purchase WHERE prno = ? AND is_cancelled = 0 LIMIT 1");
            ps.setString(1, prno.trim());
            rs = ps.executeQuery();
            if (rs.next()) purchaseId = rs.getInt(1);
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
        return purchaseId;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Purchase Edit / Cancel methods
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Returns purchase details including is_cancelled status (for edit/cancel UI).
     */
    public Vector getPurchaseDetailsForEdit(int purchaseId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vec = new Vector();
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT pd.id, p.name AS product_name, pd.prods_id, " +
                         "pd.pack, pd.qtypack, pd.quantity, pd.free, " +
                         "pd.rate, pd.mrp, pd.totalamt, pd.tax, " +
                         "pd.cgst_amt, pd.sgst_amt, pd.netamt, " +
                         "IFNULL(pd.is_cancelled, 0) AS is_cancelled " +
                         "FROM prod_purchase_details pd " +
                         "JOIN prod_product p ON pd.prods_id = p.id " +
                         "WHERE pd.prid = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, purchaseId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getInt(1));      // 0 id
                row.addElement(rs.getString(2));   // 1 product_name
                row.addElement(rs.getInt(3));      // 2 prods_id
                row.addElement(rs.getDouble(4));   // 3 pack
                row.addElement(rs.getDouble(5));   // 4 qtypack
                row.addElement(rs.getDouble(6));   // 5 quantity
                row.addElement(rs.getDouble(7));   // 6 free
                row.addElement(rs.getDouble(8));   // 7 rate
                row.addElement(rs.getDouble(9));   // 8 mrp
                row.addElement(rs.getDouble(10));  // 9 totalamt
                row.addElement(rs.getDouble(11));  // 10 tax
                row.addElement(rs.getDouble(12));  // 11 cgst_amt
                row.addElement(rs.getDouble(13));  // 12 sgst_amt
                row.addElement(rs.getDouble(14));  // 13 netamt
                row.addElement(rs.getInt(15));     // 14 is_cancelled
                vec.add(row);
            }
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
        return vec;
    }

    /**
     * Edit price (rate and/or mrp) of a purchase detail line.
     * - Updates prod_purchase_details rate, mrp, totalamt, netamt
     * - Updates prod_batch cost/mrp for the product
     * - Re-calculates prod_purchase.total / .net
     * - Logs to prod_purchase_edit_log
     */
    public String editPurchaseItemPrice(int detailId, int purchaseId, double newRate, double newMrp, String reason, int uid) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Fetch current detail row
            ps = con.prepareStatement(
                "SELECT prods_id, quantity, rate, mrp, tax FROM prod_purchase_details WHERE id = ? AND prid = ? AND IFNULL(is_cancelled,0) = 0");
            ps.setInt(1, detailId);
            ps.setInt(2, purchaseId);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("Item not found or already cancelled.");
            }
            int productId  = rs.getInt(1);
            double qty     = rs.getDouble(2);
            double oldRate = rs.getDouble(3);
            double oldMrp  = rs.getDouble(4);
            double tax     = rs.getDouble(5);
            rs.close(); ps.close();

            double newTotal   = new BigDecimal(qty * newRate).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            double newTaxAmt  = new BigDecimal(newTotal * tax / 100).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            double newNetAmt  = new BigDecimal(newTotal + newTaxAmt).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            double newCgstAmt = new BigDecimal(newTaxAmt / 2).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            double newSgstAmt = newCgstAmt;

            // Update prod_purchase_details
            ps = con.prepareStatement(
                "UPDATE prod_purchase_details SET rate=?, mrp=?, totalamt=?, tax_amt=?, netamt=?, cgst_amt=?, sgst_amt=? WHERE id=?");
            ps.setDouble(1, newRate);
            ps.setDouble(2, newMrp);
            ps.setDouble(3, newTotal);
            ps.setDouble(4, newTaxAmt);
            ps.setDouble(5, newNetAmt);
            ps.setDouble(6, newCgstAmt);
            ps.setDouble(7, newSgstAmt);
            ps.setInt(8, detailId);
            ps.executeUpdate(); ps.close();

            // Update prod_batch cost / mrp for this product
            ps = con.prepareStatement(
                "UPDATE prod_batch SET cost=?, mrp=? WHERE product_id=?");
            ps.setDouble(1, newRate);
            ps.setDouble(2, newMrp);
            ps.setInt(3, productId);
            ps.executeUpdate(); ps.close();

            // Recalculate prod_purchase header totals from detail rows
            ps = con.prepareStatement(
                "UPDATE prod_purchase pp SET pp.total = (SELECT IFNULL(SUM(pd.totalamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0) = 0), " +
                "pp.net = (SELECT IFNULL(SUM(pd.netamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0) = 0) " +
                "WHERE pp.id = ?");
            ps.setInt(1, purchaseId);
            ps.executeUpdate(); ps.close();

            // Log the edit
            ps = con.prepareStatement(
                "INSERT INTO prod_purchase_edit_log(purchase_id, purchase_detail_id, product_id, edit_type, old_rate, new_rate, old_mrp, new_mrp, qty, reason, uid, date_time) " +
                "VALUES(?,?,?,'price_edit',?,?,?,?,?,?,?,NOW())");
            ps.setInt(1, purchaseId);
            ps.setInt(2, detailId);
            ps.setInt(3, productId);
            ps.setDouble(4, oldRate);
            ps.setDouble(5, newRate);
            ps.setDouble(6, oldMrp);
            ps.setDouble(7, newMrp);
            ps.setDouble(8, qty);
            ps.setString(9, reason != null ? reason : "");
            ps.setInt(10, uid);
            ps.executeUpdate(); ps.close();

            con.commit();
            return "Price updated successfully.";
        } catch (Exception e) {
            if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
            throw e;
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }

    /**
     * Cancel a purchase detail line.
     * - Validates current stock >= qty to deduct.
     * - Reduces stock in prod_batch, prod_stock_totals.
     * - Inserts prod_lifecycle (stock_out, type=2).
     * - Marks prod_purchase_details.is_cancelled = 1.
     * - Recalculates prod_purchase header totals.
     * - Logs to prod_purchase_edit_log.
     */
    public String cancelPurchaseItem(int detailId, int purchaseId, String reason, int uid) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Fetch detail row
            ps = con.prepareStatement(
                "SELECT prods_id, quantity, free, rate, mrp FROM prod_purchase_details WHERE id = ? AND prid = ? AND IFNULL(is_cancelled,0) = 0");
            ps.setInt(1, detailId);
            ps.setInt(2, purchaseId);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("Item not found or already cancelled.");
            }
            int productId = rs.getInt(1);
            double qty    = rs.getDouble(2);
            double free   = rs.getDouble(3);
            double rate   = rs.getDouble(4);
            double mrp    = rs.getDouble(5);
            rs.close(); ps.close();

            BigDecimal totalQty = new BigDecimal(qty + free).setScale(3, java.math.RoundingMode.HALF_UP);

            // Validate stock using prod_stock_totals
            ps = con.prepareStatement(
                "SELECT IFNULL(stock, 0) FROM prod_stock_totals WHERE prods_id = ?");
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            BigDecimal currentStock = BigDecimal.ZERO;
            if (rs.next()) currentStock = rs.getBigDecimal(1);
            rs.close(); ps.close();

            if (currentStock.compareTo(totalQty) < 0) {
                throw new Exception("Cannot cancel: current stock (" + currentStock.toPlainString()
                    + ") is less than purchase qty (" + totalQty.toPlainString() + "). Reduce stock first.");
            }

            // Deduct stock from prod_batch
            ps = con.prepareStatement(
                "UPDATE prod_batch SET stock = GREATEST(0, stock - ?) WHERE product_id = ?");
            ps.setBigDecimal(1, totalQty);
            ps.setInt(2, productId);
            ps.executeUpdate(); ps.close();

            // Deduct from prod_stock_totals
            ps = con.prepareStatement(
                "UPDATE prod_stock_totals SET stock = stock - ? WHERE prods_id = ?");
            ps.setBigDecimal(1, totalQty);
            ps.setInt(2, productId);
            ps.executeUpdate(); ps.close();

            // Get previous lifecycle row for stock_now
            ps = con.prepareStatement(
                "SELECT IFNULL(stock_now, 0) FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            BigDecimal prevStockNow = BigDecimal.ZERO;
            if (rs.next()) prevStockNow = rs.getBigDecimal(1);
            rs.close(); ps.close();

            // Insert lifecycle entry (stock out)
            ps = con.prepareStatement(
                "INSERT INTO prod_lifecycle(batch_id, product_id, stock_out, stock_now, is_zero_stock_bill, notes, uid, stock_type, DATE, TIME) " +
                "VALUES(1, ?, ?, ?, 2, ?, ?, 2, NOW(), NOW())");
            ps.setInt(1, productId);
            ps.setBigDecimal(2, totalQty);
            ps.setBigDecimal(3, prevStockNow.subtract(totalQty));
            ps.setString(4, "Stock deducted — Purchase item cancelled (detail id: " + detailId + ")");
            ps.setInt(5, uid);
            ps.executeUpdate(); ps.close();

            // Mark item as cancelled
            ps = con.prepareStatement(
                "UPDATE prod_purchase_details SET is_cancelled = 1 WHERE id = ?");
            ps.setInt(1, detailId);
            ps.executeUpdate(); ps.close();

            // Recalculate prod_purchase header totals
            ps = con.prepareStatement(
                "UPDATE prod_purchase pp SET pp.total = (SELECT IFNULL(SUM(pd.totalamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0)=0), " +
                "pp.net = (SELECT IFNULL(SUM(pd.netamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0)=0) " +
                "WHERE pp.id = ?");
            ps.setInt(1, purchaseId);
            ps.executeUpdate(); ps.close();

            // Log
            ps = con.prepareStatement(
                "INSERT INTO prod_purchase_edit_log(purchase_id, purchase_detail_id, product_id, edit_type, old_rate, new_rate, old_mrp, new_mrp, qty, reason, uid, date_time) " +
                "VALUES(?,?,?,'cancel',?,0,?,0,?,?,?,NOW())");
            ps.setInt(1, purchaseId);
            ps.setInt(2, detailId);
            ps.setInt(3, productId);
            ps.setDouble(4, rate);
            ps.setDouble(5, mrp);
            ps.setDouble(6, qty);
            ps.setString(7, reason != null ? reason : "");
            ps.setInt(8, uid);
            ps.executeUpdate(); ps.close();

            con.commit();
            return "Item cancelled successfully. Stock reduced by " + totalQty.toPlainString() + ".";
        } catch (Exception e) {
            if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
            throw e;
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Purchase Return methods
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Save a purchase return.
     * itemsArr format: "detailId<#>qty<#>rate<@>detailId<#>qty<#>rate<@>..."
     * - Validates each qty <= original qty in purchase detail (minus already returned).
     * - Reduces stock in prod_batch, prod_stock_totals.
     * - Inserts prod_lifecycle (stock out).
     * - Inserts prod_purchase_return header and prod_purchase_return_details.
     */
    public String savePurchaseReturn(int purchaseId, String itemsArr, String notes, int uid) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Get supplier from purchase header
            ps = con.prepareStatement("SELECT deal_id FROM prod_purchase WHERE id = ?");
            ps.setInt(1, purchaseId);
            rs = ps.executeQuery();
            int supplierId = rs.next() ? rs.getInt(1) : 0;
            rs.close(); ps.close();

            // Generate return number
            ps = con.prepareStatement("SELECT COUNT(id)+1 FROM prod_purchase_return");
            rs = ps.executeQuery();
            String returnNo = rs.next() ? "RTN" + rs.getString(1) : "RTN1";
            rs.close(); ps.close();

            // Insert return header (total updated below)
            ps = con.prepareStatement(
                "INSERT INTO prod_purchase_return(return_no, purchase_id, supplier_id, total, notes, uid, date_time) VALUES(?,?,?,0,?,?,NOW())");
            ps.setString(1, returnNo);
            ps.setInt(2, purchaseId);
            ps.setInt(3, supplierId);
            ps.setString(4, notes != null ? notes : "");
            ps.setInt(5, uid);
            ps.executeUpdate(); ps.close();

            ps = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_return");
            rs = ps.executeQuery();
            int returnId = rs.next() ? rs.getInt(1) : 0;
            rs.close(); ps.close();

            double grandReturnTotal = 0;

            String[] rows = itemsArr.split("<@>");
            for (String row : rows) {
                if (row.trim().isEmpty()) continue;
                String[] fields = row.split("<#>");
                int detailId    = Integer.parseInt(fields[0]);
                double returnQty = Double.parseDouble(fields[1]);
                double rate      = Double.parseDouble(fields[2]);

                // Fetch original qty and product id
                ps = con.prepareStatement(
                    "SELECT prods_id, quantity, free FROM prod_purchase_details WHERE id = ? AND prid = ? AND IFNULL(is_cancelled,0)=0");
                ps.setInt(1, detailId);
                ps.setInt(2, purchaseId);
                rs = ps.executeQuery();
                if (!rs.next()) {
                    throw new Exception("Purchase detail id " + detailId + " not found or cancelled.");
                }
                int productId  = rs.getInt(1);
                double origQty = rs.getDouble(2) + rs.getDouble(3);
                rs.close(); ps.close();

                // Validate: total returned so far + this return <= origQty
                ps = con.prepareStatement(
                    "SELECT IFNULL(SUM(prd.qty),0) FROM prod_purchase_return_details prd " +
                    "JOIN prod_purchase_return pr ON prd.return_id = pr.id " +
                    "WHERE prd.purchase_detail_id = ? AND pr.purchase_id = ?");
                ps.setInt(1, detailId);
                ps.setInt(2, purchaseId);
                rs = ps.executeQuery();
                double alreadyReturned = rs.next() ? rs.getDouble(1) : 0;
                rs.close(); ps.close();

                double available = origQty - alreadyReturned;
                if (returnQty <= 0 || returnQty > available) {
                    throw new Exception("Return qty " + returnQty + " exceeds available qty " + available + " for product id " + productId + ".");
                }

                // Validate current stock
                ps = con.prepareStatement("SELECT IFNULL(stock,0) FROM prod_stock_totals WHERE prods_id = ?");
                ps.setInt(1, productId);
                rs = ps.executeQuery();
                BigDecimal currentStock = rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
                rs.close(); ps.close();

                BigDecimal rQty = new BigDecimal(returnQty).setScale(3, java.math.RoundingMode.HALF_UP);
                if (currentStock.compareTo(rQty) < 0) {
                    throw new Exception("Insufficient stock (" + currentStock.toPlainString() + ") for product id " + productId + ".");
                }

                // Deduct stock
                ps = con.prepareStatement("UPDATE prod_batch SET stock = GREATEST(0, stock - ?) WHERE product_id = ?");
                ps.setBigDecimal(1, rQty);
                ps.setInt(2, productId);
                ps.executeUpdate(); ps.close();

                ps = con.prepareStatement("UPDATE prod_stock_totals SET stock = stock - ? WHERE prods_id = ?");
                ps.setBigDecimal(1, rQty);
                ps.setInt(2, productId);
                ps.executeUpdate(); ps.close();

                // Lifecycle entry
                ps = con.prepareStatement(
                    "SELECT IFNULL(stock_now,0) FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
                ps.setInt(1, productId);
                rs = ps.executeQuery();
                BigDecimal prevNow = rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
                rs.close(); ps.close();

                ps = con.prepareStatement(
                    "INSERT INTO prod_lifecycle(batch_id, product_id, stock_out, stock_now, is_zero_stock_bill, notes, uid, stock_type, DATE, TIME) " +
                    "VALUES(1,?,?,?,2,?,?,2,NOW(),NOW())");
                ps.setInt(1, productId);
                ps.setBigDecimal(2, rQty);
                ps.setBigDecimal(3, prevNow.subtract(rQty));
                ps.setString(4, "Stock deducted — Purchase return (" + returnNo + ")");
                ps.setInt(5, uid);
                ps.executeUpdate(); ps.close();

                double lineTotal = new BigDecimal(returnQty * rate).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
                grandReturnTotal += lineTotal;

                // Insert return detail
                ps = con.prepareStatement(
                    "INSERT INTO prod_purchase_return_details(return_id, purchase_detail_id, product_id, qty, rate, total, uid, date_time) " +
                    "VALUES(?,?,?,?,?,?,?,NOW())");
                ps.setInt(1, returnId);
                ps.setInt(2, detailId);
                ps.setInt(3, productId);
                ps.setDouble(4, returnQty);
                ps.setDouble(5, rate);
                ps.setDouble(6, lineTotal);
                ps.setInt(7, uid);
                ps.executeUpdate(); ps.close();
            }

            // Update return header total
            ps = con.prepareStatement("UPDATE prod_purchase_return SET total = ? WHERE id = ?");
            ps.setDouble(1, grandReturnTotal);
            ps.setInt(2, returnId);
            ps.executeUpdate(); ps.close();

            con.commit();
            return returnNo;
        } catch (Exception e) {
            if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
            throw e;
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }

    /**
     * List purchase returns with date range and optional supplier filter.
     * Returns: [id, return_no, purchase_id, prno, supplier_name, total, notes, date_time, entered_by]
     */
    public Vector getPurchaseReturnList(String fromDate, String toDate, int supplierId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vec = new Vector();
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT pr.id, pr.return_no, pr.purchase_id, pp.prno, " +
                         "IFNULL(d.name,'—') AS supplier_name, pr.total, pr.notes, pr.date_time, " +
                         "IFNULL(u.user_name,'—') AS entered_by " +
                         "FROM prod_purchase_return pr " +
                         "JOIN prod_purchase pp ON pr.purchase_id = pp.id " +
                         "LEFT JOIN prod_supplier d ON pr.supplier_id = d.id " +
                         "LEFT JOIN users u ON pr.uid = u.id " +
                         "WHERE DATE(pr.date_time) BETWEEN ? AND ?" +
                         (supplierId > 0 ? " AND pr.supplier_id = ?" : "") +
                         " ORDER BY pr.date_time DESC";
            ps = con.prepareStatement(sql);
            ps.setString(1, fromDate);
            ps.setString(2, toDate);
            if (supplierId > 0) ps.setInt(3, supplierId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getInt(1));     // 0 id
                row.addElement(rs.getString(2));  // 1 return_no
                row.addElement(rs.getInt(3));     // 2 purchase_id
                row.addElement(rs.getString(4));  // 3 prno
                row.addElement(rs.getString(5));  // 4 supplier_name
                row.addElement(rs.getDouble(6));  // 5 total
                row.addElement(rs.getString(7));  // 6 notes
                row.addElement(rs.getString(8));  // 7 date_time
                row.addElement(rs.getString(9));  // 8 entered_by
                vec.add(row);
            }
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
        return vec;
    }

    /**
     * Get items for a specific purchase return.
     * Returns: [id, product_name, qty, rate, total]
     */
    public Vector getPurchaseReturnDetails(int returnId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vec = new Vector();
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT prd.id, p.name, prd.qty, prd.rate, prd.total " +
                         "FROM prod_purchase_return_details prd " +
                         "JOIN prod_product p ON prd.product_id = p.id " +
                         "WHERE prd.return_id = ? ORDER BY prd.id";
            ps = con.prepareStatement(sql);
            ps.setInt(1, returnId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getInt(1));     // 0 id
                row.addElement(rs.getString(2));  // 1 product_name
                row.addElement(rs.getDouble(3));  // 2 qty
                row.addElement(rs.getDouble(4));  // 3 rate
                row.addElement(rs.getDouble(5));  // 4 total
                vec.add(row);
            }
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
        return vec;
    }

    /**
     * Returns already-returned qty per purchase_detail_id for a given purchase.
     * Each element: [detailId(Integer), returnedQty(Double)]
     */
    public Vector getAlreadyReturnedQtyForPurchase(int purchaseId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vec = new Vector();
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            ps = con.prepareStatement(
                "SELECT prd.purchase_detail_id, IFNULL(SUM(prd.qty),0) " +
                "FROM prod_purchase_return_details prd " +
                "JOIN prod_purchase_return pr ON prd.return_id = pr.id " +
                "WHERE pr.purchase_id = ? " +
                "GROUP BY prd.purchase_detail_id");
            ps.setInt(1, purchaseId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getInt(1));     // 0 detailId
                row.addElement(rs.getDouble(2));  // 1 returnedQty
                vec.add(row);
            }
        } finally {
            if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
            if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
        return vec;
    }
}
