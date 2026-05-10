<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, org.json.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
try {
    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");
    String categoryId = request.getParameter("categoryId");
    String brandId = request.getParameter("brandId");
    String productId = request.getParameter("productId");

    // Call the method from billingBean
    Map<String, Object> data = bill.getSalesStatistics(fromDate, toDate, categoryId, brandId, productId);
    
    // Convert to JSON
    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("totalBills", data.get("totalBills"));
    jsonResponse.put("totalSales", data.get("totalSales"));
    jsonResponse.put("totalQty", data.get("totalQty"));
    jsonResponse.put("avgBill", data.get("avgBill"));
    
    // Convert details Vector to JSONArray
    Vector details = (Vector) data.get("details");
    JSONArray detailsArray = new JSONArray();
    for (int i = 0; i < details.size(); i++) {
        Map<String, Object> row = (Map<String, Object>) details.get(i);
        JSONObject jsonRow = new JSONObject();
        jsonRow.put("billNo", row.get("billNo"));
        jsonRow.put("date", row.get("date"));
        jsonRow.put("productName", row.get("productName"));
        jsonRow.put("categoryName", row.get("categoryName"));
        jsonRow.put("brandName", row.get("brandName"));
        jsonRow.put("qty", row.get("qty"));
        jsonRow.put("price", row.get("price"));
        jsonRow.put("disc", row.get("disc"));
        jsonRow.put("total", row.get("total"));
        detailsArray.put(jsonRow);
    }
    jsonResponse.put("details", detailsArray);
    
    out.clear();
    out.print(jsonResponse.toString());
    out.flush();
    
} catch (Exception e) {
    e.printStackTrace();
    out.clear();
    JSONObject error = new JSONObject();
    error.put("error", e.getMessage());
    out.print(error.toString());
    out.flush();
}
%>
