package cafeorder;

import java.io.Serializable;

/**
 * Bean class for order_tables table
 * Represents a table in the cafe
 */
public class OrderTable implements Serializable {
    private int id;
    private String name;
    private int isOccupied;

    public OrderTable() {
    }

    public OrderTable(int id, String name, int isOccupied) {
        this.id = id;
        this.name = name;
        this.isOccupied = isOccupied;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getIsOccupied() {
        return isOccupied;
    }

    public void setIsOccupied(int isOccupied) {
        this.isOccupied = isOccupied;
    }

    public boolean isOccupied() {
        return isOccupied == 1;
    }

    public void setOccupied(boolean occupied) {
        this.isOccupied = occupied ? 1 : 0;
    }

    @Override
    public String toString() {
        return "OrderTable{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", isOccupied=" + isOccupied +
                '}';
    }
}
