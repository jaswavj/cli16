package cafeorder;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import util.DBConnectionManager;

/**
 * Main bean class for cafe order management
 * Contains all database operations for orders, tables, and order details
 */
public class CafeOrderBean {

    public CafeOrderBean() {
    }

    // ==================== TABLE MANAGEMENT ====================

    /**
     * Get all tables
     */
    public List<OrderTable> getAllTables() throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<OrderTable> tables = new ArrayList<>();

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT * FROM order_tables ORDER BY name";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                OrderTable table = new OrderTable();
                table.setId(rs.getInt("id"));
                table.setName(rs.getString("name"));
                table.setIsOccupied(rs.getInt("is_occupied"));
                tables.add(table);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return tables;
    }

    /**
     * Get available (not occupied) tables
     */
    public List<OrderTable> getAvailableTables() throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<OrderTable> tables = new ArrayList<>();

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT * FROM order_tables WHERE is_occupied = 0 ORDER BY name";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                OrderTable table = new OrderTable();
                table.setId(rs.getInt("id"));
                table.setName(rs.getString("name"));
                table.setIsOccupied(rs.getInt("is_occupied"));
                tables.add(table);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return tables;
    }

    /**
     * Get table by ID
     */
    public OrderTable getTableById(int id) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        OrderTable table = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT * FROM order_tables WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                table = new OrderTable();
                table.setId(rs.getInt("id"));
                table.setName(rs.getString("name"));
                table.setIsOccupied(rs.getInt("is_occupied"));
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return table;
    }

    /**
     * Create new table
     */
    public int createTable(String name) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int generatedId = 0;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "INSERT INTO order_tables (name, is_occupied) VALUES (?, 0)";
            ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, name);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return generatedId;
    }

    /**
     * Update table
     */
    public boolean updateTable(int id, String name) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "UPDATE order_tables SET name = ? WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    /**
     * Delete table
     */
    public boolean deleteTable(int id) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "DELETE FROM order_tables WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    /**
     * Update table occupancy status
     */
    public boolean updateTableOccupancy(int tableId, boolean isOccupied) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "UPDATE order_tables SET is_occupied = ? WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, isOccupied ? 1 : 0);
            ps.setInt(2, tableId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    // ==================== ORDER MANAGEMENT ====================

    /**
     * Create new order with details
     */
    public int createOrder(int tableId, int userId, List<ProductOrderDetail> items) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int orderId = 0;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Generate order number
            String orderNo = "ORD" + System.currentTimeMillis();

            // Get current date and time
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
            String currentDate = dateFormat.format(new java.util.Date());
            String currentTime = timeFormat.format(new java.util.Date());

            // Insert order
            String sql = "INSERT INTO prod_order (order_no, table_id, is_delivered, is_billed, is_cancelled, date, time, uid) " +
                        "VALUES (?, ?, 0, 0, 0, ?, ?, ?)";
            ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, orderNo);
            ps.setInt(2, tableId);
            ps.setString(3, currentDate);
            ps.setString(4, currentTime);
            ps.setInt(5, userId);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            }
            rs.close();
            ps.close();

            // Insert order details
            sql = "INSERT INTO prod_order_details (order_id, prod_id, qty, price, total, is_delivered) " +
                  "VALUES (?, ?, ?, ?, ?, 0)";
            ps = con.prepareStatement(sql);

            for (ProductOrderDetail item : items) {
                ps.setInt(1, orderId);
                ps.setInt(2, item.getProdId());
                ps.setInt(3, item.getQty());
                ps.setDouble(4, item.getPrice());
                ps.setDouble(5, item.getTotal());
                ps.addBatch();
            }
            ps.executeBatch();
            ps.close();

            // Update table status to occupied
            sql = "UPDATE order_tables SET is_occupied = 1 WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, tableId);
            ps.executeUpdate();

            con.commit();
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }

        return orderId;
    }

    /**
     * Get orders by status
     * @param isPending true for pending orders, false for all
     * @param isDelivered -1 for all, 0 for not delivered, 1 for delivered
     * @param isBilled -1 for all, 0 for not billed, 1 for billed
     */
    public List<ProductOrder> getOrders(boolean isPending, int isDelivered, int isBilled) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<ProductOrder> orders = new ArrayList<>();

        try {
            con = DBConnectionManager.getConnectionFromPool();
            StringBuilder sql = new StringBuilder(
                "SELECT po.*, ot.name as table_name FROM prod_order po " +
                "JOIN order_tables ot ON po.table_id = ot.id WHERE po.is_cancelled = 0"
            );

            if (isPending) {
                sql.append(" AND po.is_billed = 0");
            }
            if (isDelivered >= 0) {
                sql.append(" AND po.is_delivered = ").append(isDelivered);
            }
            if (isBilled >= 0) {
                sql.append(" AND po.is_billed = ").append(isBilled);
            }

            sql.append(" ORDER BY po.date DESC, po.time DESC");

            ps = con.prepareStatement(sql.toString());
            rs = ps.executeQuery();

            while (rs.next()) {
                ProductOrder order = new ProductOrder();
                order.setId(rs.getInt("id"));
                order.setOrderNo(rs.getString("order_no"));
                order.setTableId(rs.getInt("table_id"));
                order.setTableName(rs.getString("table_name"));
                order.setIsDelivered(rs.getInt("is_delivered"));
                order.setIsBilled(rs.getInt("is_billed"));
                order.setIsCancelled(rs.getInt("is_cancelled"));
                order.setDate(rs.getDate("date"));
                order.setTime(rs.getTime("time"));
                order.setUid(rs.getInt("uid"));
                orders.add(order);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return orders;
    }

    /**
     * Get pending orders (not billed, not cancelled)
     */
    public List<ProductOrder> getPendingOrders() throws SQLException {
        return getOrders(true, -1, 0);
    }

    /**
     * Get delivered orders (delivered but not billed)
     */
    public List<ProductOrder> getDeliveredOrders() throws SQLException {
        return getOrders(false, 1, 0);
    }

    /**
     * Get billed orders
     */
    public List<ProductOrder> getBilledOrders() throws SQLException {
        return getOrders(false, -1, 1);
    }

    /**
     * Get order by ID with details
     */
    public ProductOrder getOrderById(int orderId) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        ProductOrder order = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();

            // Get order
            String sql = "SELECT po.*, ot.name as table_name FROM prod_order po " +
                        "JOIN order_tables ot ON po.table_id = ot.id WHERE po.id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();

            if (rs.next()) {
                order = new ProductOrder();
                order.setId(rs.getInt("id"));
                order.setOrderNo(rs.getString("order_no"));
                order.setTableId(rs.getInt("table_id"));
                order.setTableName(rs.getString("table_name"));
                order.setIsDelivered(rs.getInt("is_delivered"));
                order.setIsBilled(rs.getInt("is_billed"));
                order.setIsCancelled(rs.getInt("is_cancelled"));
                order.setDate(rs.getDate("date"));
                order.setTime(rs.getTime("time"));
                order.setUid(rs.getInt("uid"));
            }
            rs.close();
            ps.close();

            // Get order details
            if (order != null) {
                sql = "SELECT pod.*, p.prodname, p.code FROM prod_order_details pod " +
                      "JOIN product p ON pod.prod_id = p.id WHERE pod.order_id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, orderId);
                rs = ps.executeQuery();

                while (rs.next()) {
                    ProductOrderDetail detail = new ProductOrderDetail();
                    detail.setId(rs.getInt("id"));
                    detail.setOrderId(rs.getInt("order_id"));
                    detail.setProdId(rs.getInt("prod_id"));
                    detail.setProdName(rs.getString("prodname"));
                    detail.setProdCode(rs.getString("code"));
                    detail.setQty(rs.getInt("qty"));
                    detail.setPrice(rs.getDouble("price"));
                    detail.setTotal(rs.getDouble("total"));
                    detail.setIsDelivered(rs.getInt("is_delivered"));
                    order.addOrderDetail(detail);
                }
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return order;
    }

    /**
     * Update order delivery status
     */
    public boolean updateOrderDeliveryStatus(int orderId, boolean isDelivered) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "UPDATE prod_order SET is_delivered = ? WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, isDelivered ? 1 : 0);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    /**
     * Mark entire order as delivered (including all items)
     */
    public boolean markOrderDelivered(int orderId) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Mark all items as delivered
            String sql = "UPDATE prod_order_details SET is_delivered = 1 WHERE order_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.executeUpdate();
            ps.close();

            // Mark order as delivered
            sql = "UPDATE prod_order SET is_delivered = 1 WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.executeUpdate();

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (ps != null) ps.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    /**
     * Mark order as billed and free the table
     */
    public boolean markOrderBilled(int orderId, int tableId) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Mark order as billed
            String sql = "UPDATE prod_order SET is_billed = 1 WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.executeUpdate();
            ps.close();

            // Free the table
            sql = "UPDATE order_tables SET is_occupied = 0 WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, tableId);
            ps.executeUpdate();

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (ps != null) ps.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    /**
     * Cancel order
     */
    public boolean cancelOrder(int orderId) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // Get table ID before cancelling
            String sql = "SELECT table_id FROM prod_order WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            int tableId = 0;
            if (rs.next()) {
                tableId = rs.getInt("table_id");
            }
            rs.close();
            ps.close();

            // Mark order as cancelled
            sql = "UPDATE prod_order SET is_cancelled = 1 WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.executeUpdate();
            ps.close();

            // Free the table
            if (tableId > 0) {
                sql = "UPDATE order_tables SET is_occupied = 0 WHERE id = ?";
                ps = con.prepareStatement(sql);
                ps.setInt(1, tableId);
                ps.executeUpdate();
            }

            con.commit();
            return true;
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (ps != null) ps.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    // ==================== ORDER DETAIL MANAGEMENT ====================

    /**
     * Get order details by order ID
     */
    public List<ProductOrderDetail> getOrderDetails(int orderId) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<ProductOrderDetail> details = new ArrayList<>();

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT pod.*, p.prodname, p.code FROM prod_order_details pod " +
                        "JOIN product p ON pod.prod_id = p.id WHERE pod.order_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();

            while (rs.next()) {
                ProductOrderDetail detail = new ProductOrderDetail();
                detail.setId(rs.getInt("id"));
                detail.setOrderId(rs.getInt("order_id"));
                detail.setProdId(rs.getInt("prod_id"));
                detail.setProdName(rs.getString("prodname"));
                detail.setProdCode(rs.getString("code"));
                detail.setQty(rs.getInt("qty"));
                detail.setPrice(rs.getDouble("price"));
                detail.setTotal(rs.getDouble("total"));
                detail.setIsDelivered(rs.getInt("is_delivered"));
                details.add(detail);
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return details;
    }

    /**
     * Update item delivery status
     */
    public boolean updateItemDeliveryStatus(int detailId, boolean isDelivered) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "UPDATE prod_order_details SET is_delivered = ? WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, isDelivered ? 1 : 0);
            ps.setInt(2, detailId);
            return ps.executeUpdate() > 0;
        } finally {
            if (ps != null) ps.close();
            if (con != null) con.close();
        }
    }

    /**
     * Check if all items in an order are delivered
     */
    public boolean areAllItemsDelivered(int orderId) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT COUNT(*) as total, SUM(is_delivered) as delivered " +
                        "FROM prod_order_details WHERE order_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();

            if (rs.next()) {
                int total = rs.getInt("total");
                int delivered = rs.getInt("delivered");
                return total > 0 && total == delivered;
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return false;
    }

    // ==================== UTILITY METHODS ====================

    /**
     * Get order statistics
     */
    public Map<String, Integer> getOrderStatistics() throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Map<String, Integer> stats = new HashMap<>();

        try {
            con = DBConnectionManager.getConnectionFromPool();
            
            // Total pending orders
            String sql = "SELECT COUNT(*) as count FROM prod_order WHERE is_billed = 0 AND is_cancelled = 0";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("pendingOrders", rs.getInt("count"));
            }
            rs.close();
            ps.close();

            // Total delivered orders
            sql = "SELECT COUNT(*) as count FROM prod_order WHERE is_delivered = 1 AND is_billed = 0 AND is_cancelled = 0";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("deliveredOrders", rs.getInt("count"));
            }
            rs.close();
            ps.close();

            // Occupied tables
            sql = "SELECT COUNT(*) as count FROM order_tables WHERE is_occupied = 1";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("occupiedTables", rs.getInt("count"));
            }
            rs.close();
            ps.close();

            // Available tables
            sql = "SELECT COUNT(*) as count FROM order_tables WHERE is_occupied = 0";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                stats.put("availableTables", rs.getInt("count"));
            }

        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return stats;
    }

    /**
     * Get today's revenue from orders
     */
    public double getTodayRevenue() throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        double revenue = 0.0;

        try {
            con = DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT SUM(pod.total) as revenue FROM prod_order_details pod " +
                        "JOIN prod_order po ON pod.order_id = po.id " +
                        "WHERE po.date = CURDATE() AND po.is_billed = 1 AND po.is_cancelled = 0";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                revenue = rs.getDouble("revenue");
            }
        } finally {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (con != null) con.close();
        }

        return revenue;
    }

    /**
     * Get pending orders as JSON string for billing
     */
    public String getPendingOrdersJSON() {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        StringBuilder json = new StringBuilder("[");
        
        try {
            con = DBConnectionManager.getConnectionFromPool();
            
            String sql = "SELECT po.id, po.order_no, po.date, po.time, po.is_delivered, ot.name as table_name " +
                         "FROM prod_order po " +
                         "LEFT JOIN order_tables ot ON po.table_id = ot.id " +
                         "WHERE po.is_billed = 0 AND po.is_cancelled = 0 " +
                         "ORDER BY po.date DESC, po.time DESC";
            
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            boolean first = true;
            
            while(rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                String tableName = rs.getString("table_name");
                if(tableName == null) tableName = "N/A";
                
                String orderNo = rs.getString("order_no");
                if(orderNo == null) orderNo = "";
                
                String date = rs.getString("date");
                if(date == null) date = "";
                
                String time = rs.getString("time");
                if(time == null) time = "";
                
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"order_no\":\"").append(orderNo).append("\",")
                    .append("\"table_name\":\"").append(tableName).append("\",")
                    .append("\"date\":\"").append(date).append("\",")
                    .append("\"time\":\"").append(time).append("\",")
                    .append("\"is_delivered\":").append(rs.getInt("is_delivered"))
                    .append("}");
            }
            json.append("]");
            
        } catch(Exception e) {
            String msg = e.getMessage();
            if(msg == null) msg = "Unknown error";
            msg = msg.replace("\"", "'").replace("\n", " ").replace("\r", " ");
            return "[{\"error\":\"" + msg + "\"}]";
        } finally {
            try {
                if(rs != null) rs.close();
                if(ps != null) ps.close();
                if(con != null) con.close();
            } catch(Exception e) {
                e.printStackTrace();
            }
        }
        
        return json.toString();
    }
}
