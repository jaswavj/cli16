<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*, org.json.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<%
    try {
        // Get session user ID
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            out.print("Error: User not logged in");
            return;
        }
        
        // Read JSON from request body
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }
        String jsonData = sb.toString();
        
        if (jsonData == null || jsonData.isEmpty()) {
            out.print("Error: No data received");
            return;
        }
        
        // Parse JSON
        JSONObject data = new JSONObject(jsonData);
        
        int poId = data.getInt("poId");
        int supplierId = data.getInt("supplierId");
        String receiptDate = data.getString("receiptDate");
        String invoiceNo = data.optString("invoiceNo", "");
        String challanNo = data.optString("challanNo", "");
        String receiptNotes = data.optString("receiptNotes", "");
        JSONArray items = data.getJSONArray("items");
        
        // Validate
        if (items.length() == 0) {
            out.print("Error: No items to receive");
            return;
        }
        
        // Build receiptData string
        String receiptData = receiptDate + "<#>" + invoiceNo + "<#>" + challanNo + "<#>" + receiptNotes + "<#>" + supplierId;
        
        // Build receivedArr string
        StringBuilder receivedArr = new StringBuilder();
        for (int i = 0; i < items.length(); i++) {
            JSONObject item = items.getJSONObject(i);
            
            int detailsId = item.getInt("detailsId");
            int prodId = item.getInt("prodId");
            int batchId = item.getInt("batchId");
            double qty = item.getDouble("qty");
            double rate = item.getDouble("rate");
            
            if (i > 0) {
                receivedArr.append("<$>");
            }
            
            // Format: detailsId<#>prodId<#>batchId<#>qty<#>rate
            receivedArr.append(detailsId).append("<#>");
            receivedArr.append(prodId).append("<#>");
            receivedArr.append(batchId).append("<#>");
            receivedArr.append(qty).append("<#>");
            receivedArr.append(rate);
        }
        
        // Call bean method
        String peNo = poBean.createPurchaseEntryFromPO(poId, receiptData, receivedArr.toString(), userId.intValue());
        
        // Return PE number
        out.print(peNo);
        
    } catch (JSONException je) {
        out.print("Error: Invalid JSON format - " + je.getMessage());
        je.printStackTrace();
    } catch (java.sql.SQLException sqle) {
        out.print("Error: SQL Error - " + sqle.getMessage() + " | SQLState: " + sqle.getSQLState() + " | Query: " + sqle.toString());
        sqle.printStackTrace();
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
