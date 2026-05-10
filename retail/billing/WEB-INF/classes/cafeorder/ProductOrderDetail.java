package cafeorder;

import java.io.Serializable;

/**
 * Bean class for prod_order_details table
 * Represents individual items in an order
 */
public class ProductOrderDetail implements Serializable {
    private int id;
    private int orderId;
    private int prodId;
    private int qty;
    private double price;
    private double total;
    private int isDelivered;
    
    // Additional fields for joins
    private String prodName;
    private String prodCode;

    public ProductOrderDetail() {
    }

    public ProductOrderDetail(int id, int orderId, int prodId, int qty, double price, 
                             double total, int isDelivered) {
        this.id = id;
        this.orderId = orderId;
        this.prodId = prodId;
        this.qty = qty;
        this.price = price;
        this.total = total;
        this.isDelivered = isDelivered;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getProdId() {
        return prodId;
    }

    public void setProdId(int prodId) {
        this.prodId = prodId;
    }

    public int getQty() {
        return qty;
    }

    public void setQty(int qty) {
        this.qty = qty;
        // Recalculate total when quantity changes
        this.total = this.price * qty;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
        // Recalculate total when price changes
        this.total = price * this.qty;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public int getIsDelivered() {
        return isDelivered;
    }

    public void setIsDelivered(int isDelivered) {
        this.isDelivered = isDelivered;
    }

    public String getProdName() {
        return prodName;
    }

    public void setProdName(String prodName) {
        this.prodName = prodName;
    }

    public String getProdCode() {
        return prodCode;
    }

    public void setProdCode(String prodCode) {
        this.prodCode = prodCode;
    }

    // Convenience methods
    public boolean isDelivered() {
        return isDelivered == 1;
    }

    public void setDelivered(boolean delivered) {
        this.isDelivered = delivered ? 1 : 0;
    }

    /**
     * Calculate total based on quantity and price
     */
    public void calculateTotal() {
        this.total = this.price * this.qty;
    }

    @Override
    public String toString() {
        return "ProductOrderDetail{" +
                "id=" + id +
                ", orderId=" + orderId +
                ", prodId=" + prodId +
                ", prodName='" + prodName + '\'' +
                ", qty=" + qty +
                ", price=" + price +
                ", total=" + total +
                ", isDelivered=" + isDelivered +
                '}';
    }
}
