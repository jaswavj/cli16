<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, org.json.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    try {
        response.setContentType("application/json");
        
        // Get parameters
        String searchTerm = request.getParameter("search");
        if (searchTerm == null) searchTerm = "";
        
        int currentPage = 1;
        int pageSize = 20; // Number of products per page
        
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                currentPage = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
        
        try {
            String pageSizeParam = request.getParameter("pageSize");
            if (pageSizeParam != null && !pageSizeParam.isEmpty()) {
                pageSize = Integer.parseInt(pageSizeParam);
            }
        } catch (NumberFormatException e) {
            pageSize = 20;
        }
        
        JSONObject result = new JSONObject();
        JSONArray productsArray = new JSONArray();
        
        // Build unit lookup map: unitId -> [unitName, convertionUnit]
        HashMap<String, String[]> unitMap = new HashMap<String, String[]>();
        Vector allUnits = prod.getUnits();
        if (allUnits != null) {
            for (int u = 0; u < allUnits.size(); u++) {
                Vector uu = (Vector) allUnits.get(u);
                if (uu != null && uu.size() > 1 && uu.elementAt(1) != null) {
                    String uid = uu.elementAt(1).toString();
                    String uname = uu.elementAt(0) != null ? uu.elementAt(0).toString() : "";
                    String cUnit = (uu.size() > 2 && uu.elementAt(2) != null) ? uu.elementAt(2).toString() : "";
                    unitMap.put(uid, new String[]{uname, cUnit});
                }
            }
        }

        // Get all products
        Vector productList = prod.getAllProducts();
        
        if (productList != null) {
            // Filter products based on search term
            Vector filteredProducts = new Vector();
            for (int i = 0; i < productList.size(); i++) {
                Vector row = (Vector) productList.get(i);
                if (row != null && row.size() > 14) {
                    String productName = row.elementAt(0) != null ? row.elementAt(0).toString().toLowerCase() : "";
                    String prodCode = row.elementAt(1) != null ? row.elementAt(1).toString().toLowerCase() : "";
                    String categ = row.elementAt(2) != null ? row.elementAt(2).toString().toLowerCase() : "";
                    String brandss = row.elementAt(3) != null ? row.elementAt(3).toString().toLowerCase() : "";
                    
                    String searchLower = searchTerm.toLowerCase();
                    if (searchTerm.isEmpty() || 
                        productName.contains(searchLower) || 
                        prodCode.contains(searchLower) || 
                        categ.contains(searchLower) || 
                        brandss.contains(searchLower)) {
                        filteredProducts.add(row);
                    }
                }
            }
            
            int totalProducts = filteredProducts.size();
            int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
            
            // Calculate pagination boundaries
            int startIndex = (currentPage - 1) * pageSize;
            int endIndex = Math.min(startIndex + pageSize, totalProducts);
            
            // Get paginated products
            for (int i = startIndex; i < endIndex; i++) {
                Vector row = (Vector) filteredProducts.get(i);
                
                JSONObject productObj = new JSONObject();
                productObj.put("index", i + 1);
                productObj.put("productName", row.elementAt(0) != null ? row.elementAt(0).toString() : "");
                productObj.put("prodCode", row.elementAt(1) != null ? row.elementAt(1).toString() : "");
                productObj.put("productId", Integer.parseInt(row.elementAt(8).toString()));
                productObj.put("categ", row.elementAt(2) != null ? row.elementAt(2).toString() : "");
                productObj.put("brandss", row.elementAt(3) != null ? row.elementAt(3).toString() : "");
                productObj.put("mrp", Double.parseDouble(row.elementAt(4).toString()));
                productObj.put("cost", Double.parseDouble(row.elementAt(9).toString()));
                productObj.put("discType", Integer.parseInt(row.elementAt(10).toString()));
                productObj.put("discount", Double.parseDouble(row.elementAt(11).toString()));
                productObj.put("gst", Integer.parseInt(row.elementAt(12).toString()));
                productObj.put("unitId", row.elementAt(13) != null ? row.elementAt(13).toString() : "");
                productObj.put("hsn", row.elementAt(14) != null ? row.elementAt(14).toString() : "");
                productObj.put("commission", row.size() > 16 && row.elementAt(16) != null ? Double.parseDouble(row.elementAt(16).toString()) : 0.0);
                productObj.put("stock", row.elementAt(6) != null ? row.elementAt(6).toString() : "0");
                
                // Get unit name and conversion unit from pre-built map
                String unitName = "";
                String convertionUnit = "";
                String unitIdStr = row.elementAt(13) != null ? row.elementAt(13).toString() : "";
                if (row.size() > 15 && row.elementAt(15) != null) {
                    unitName = row.elementAt(15).toString();
                }
                if (!unitIdStr.isEmpty() && unitMap.containsKey(unitIdStr)) {
                    String[] unitInfo = unitMap.get(unitIdStr);
                    if (unitName.isEmpty()) unitName = unitInfo[0];
                    convertionUnit = unitInfo[1];
                }
                productObj.put("unit", unitName);
                productObj.put("convertionUnit", convertionUnit);
                
                productsArray.put(productObj);
            }
            
            result.put("products", productsArray);
            result.put("totalProducts", totalProducts);
            result.put("totalPages", totalPages);
            result.put("currentPage", currentPage);
            result.put("pageSize", pageSize);
            result.put("success", true);
        } else {
            result.put("products", productsArray);
            result.put("totalProducts", 0);
            result.put("totalPages", 0);
            result.put("currentPage", 1);
            result.put("pageSize", pageSize);
            result.put("success", true);
        }
        
        out.print(result.toString());
        
    } catch (Exception e) {
        response.setContentType("application/json");
        JSONObject errorResult = new JSONObject();
        errorResult.put("success", false);
        errorResult.put("error", e.getMessage());
        errorResult.put("products", new JSONArray());
        errorResult.put("totalProducts", 0);
        errorResult.put("totalPages", 0);
        errorResult.put("currentPage", 1);
        errorResult.put("pageSize", 20);
        out.print(errorResult.toString());
    }
%>
