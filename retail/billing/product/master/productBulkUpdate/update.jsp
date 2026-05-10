<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

// Get parameters
String productIdStr = request.getParameter("productId");
String batchIdStr = request.getParameter("batchId");
String mrpStr = request.getParameter("mrp");
String gstStr = request.getParameter("gst");

// Validate parameters
if (productIdStr == null || batchIdStr == null || mrpStr == null || gstStr == null) {
    response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Missing required parameters&type=danger");
    return;
}

try {
    int productId = Integer.parseInt(productIdStr);
    int batchId = Integer.parseInt(batchIdStr);
    double mrp = Double.parseDouble(mrpStr);
    int gst = Integer.parseInt(gstStr);
    
    // Validate values
    if (mrp <= 0) {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid MRP value&type=danger");
        return;
    }
    
    if (gst < 0 || gst > 100) {
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid GST value (must be 0-100)&type=danger");
        return;
    }
    
    try {
        // Use bean method to update
        boolean success = prod.updateProductMrpAndGst(productId, batchId, mrp, gst);
        
        if (success) {
            response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Product updated successfully!&type=success");
        } else {
            response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Failed to update product&type=danger");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Error: " + e.getMessage() + "&type=danger");
    }
    
} catch (NumberFormatException e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/product/master/productBulkUpdate/page.jsp?msg=Invalid number format&type=danger");
}
%>
