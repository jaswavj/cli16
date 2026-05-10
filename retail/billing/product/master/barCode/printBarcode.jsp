<%@ page language="java" contentType="application/json; charset=UTF-8"%>
<%@ page import="print.BarcodePrinter"%>
<%@ page import="java.util.*"%>
<%@ page import="org.json.*"%>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    try {
        // Read JSON from request body
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }
        
        String jsonStr = sb.toString();
        if (jsonStr.isEmpty()) {
            out.print("{\"status\":\"error\",\"message\":\"No data received\"}");
            return;
        }

        // Parse JSON
        JSONObject json = new JSONObject(jsonStr);
        JSONArray labels = json.getJSONArray("labels");
        
        // Convert to List<Map>
        List<Map<String, String>> labelData = new ArrayList<Map<String, String>>();
        for (int i = 0; i < labels.length(); i++) {
            JSONObject labelObj = labels.getJSONObject(i);
            Map<String, String> label = new HashMap<String, String>();
            label.put("name", labelObj.getString("name"));
            label.put("code", labelObj.getString("code"));
            label.put("barcode", labelObj.optString("barcode", labelObj.getString("code")));
            label.put("mrp", labelObj.getString("mrp"));
            label.put("unit", labelObj.getString("unit"));
            label.put("qty", String.valueOf(labelObj.getInt("qty")));
            labelData.add(label);
        }
        
        // Print labels
        String result = BarcodePrinter.printLabels(labelData);
        
        if (result.startsWith("SUCCESS")) {
            out.print("{\"status\":\"success\",\"message\":\"" + result.substring(9) + "\"}");
        } else {
            out.print("{\"status\":\"error\",\"message\":\"" + result.substring(7) + "\"}");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        out.print("{\"status\":\"error\",\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
    }
%>
