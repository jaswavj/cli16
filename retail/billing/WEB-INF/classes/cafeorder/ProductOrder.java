package cafeorder;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

/**
 * Bean class for prod_order table
 * Represents a customer order in the cafe
 */
public class ProductOrder implements Serializable {
    private int id;
    private String orderNo;
    private int tableId;
    private int isDelivered;
    private int isBilled;
    private int isCancelled;
    private Date date;
    private Time time;
    private int uid;
    
    // Additional fields for joins
    private String tableName;
    private List<ProductOrderDetail> orderDetails;

    public ProductOrder() {
        this.orderDetails = new ArrayList<>();
    }

    public ProductOrder(int id, String orderNo, int tableId, int isDelivered, int isBilled, 
                       int isCancelled, Date date, Time time, int uid) {
        this.id = id;
        this.orderNo = orderNo;
        this.tableId = tableId;
        this.isDelivered = isDelivered;
        this.isBilled = isBilled;
        this.isCancelled = isCancelled;
        this.date = date;
        this.time = time;
        this.uid = uid;
        this.orderDetails = new ArrayList<>();
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public void setOrderNo(String orderNo) {
        this.orderNo = orderNo;
    }

    public int getTableId() {
        return tableId;
    }

    public void setTableId(int tableId) {
        this.tableId = tableId;
    }

    public int getIsDelivered() {
        return isDelivered;
    }

    public void setIsDelivered(int isDelivered) {
        this.isDelivered = isDelivered;
    }

    public int getIsBilled() {
        return isBilled;
    }

    public void setIsBilled(int isBilled) {
        this.isBilled = isBilled;
    }

    public int getIsCancelled() {
        return isCancelled;
    }

    public void setIsCancelled(int isCancelled) {
        this.isCancelled = isCancelled;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public Time getTime() {
        return time;
    }

    public void setTime(Time time) {
        this.time = time;
    }

    public int getUid() {
        return uid;
    }

    public void setUid(int uid) {
        this.uid = uid;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public List<ProductOrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<ProductOrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public void addOrderDetail(ProductOrderDetail detail) {
        this.orderDetails.add(detail);
    }

    // Convenience methods
    public boolean isDelivered() {
        return isDelivered == 1;
    }

    public void setDelivered(boolean delivered) {
        this.isDelivered = delivered ? 1 : 0;
    }

    public boolean isBilled() {
        return isBilled == 1;
    }

    public void setBilled(boolean billed) {
        this.isBilled = billed ? 1 : 0;
    }

    public boolean isCancelled() {
        return isCancelled == 1;
    }

    public void setCancelled(boolean cancelled) {
        this.isCancelled = cancelled ? 1 : 0;
    }

    /**
     * Calculate total amount of the order
     */
    public double getTotalAmount() {
        double total = 0.0;
        for (ProductOrderDetail detail : orderDetails) {
            total += detail.getTotal();
        }
        return total;
    }

    /**
     * Check if all items are delivered
     */
    public boolean isAllItemsDelivered() {
        if (orderDetails.isEmpty()) {
            return false;
        }
        for (ProductOrderDetail detail : orderDetails) {
            if (detail.getIsDelivered() == 0) {
                return false;
            }
        }
        return true;
    }

    @Override
    public String toString() {
        return "ProductOrder{" +
                "id=" + id +
                ", orderNo='" + orderNo + '\'' +
                ", tableId=" + tableId +
                ", tableName='" + tableName + '\'' +
                ", isDelivered=" + isDelivered +
                ", isBilled=" + isBilled +
                ", isCancelled=" + isCancelled +
                ", date=" + date +
                ", time=" + time +
                ", uid=" + uid +
                ", itemCount=" + orderDetails.size() +
                '}';
    }
}
