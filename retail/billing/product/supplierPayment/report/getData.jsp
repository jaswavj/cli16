<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
    response.setContentType("application/json");
    
    try {
        int status = Integer.parseInt(request.getParameter("status"));
        String result = "";
        
        if (status == 1) {
            // Get payment summary
            String fromDate = request.getParameter("fromDate");
            String toDate = request.getParameter("toDate");
            String supplierId = request.getParameter("supplierId");
            
            result = productBean.getSupplierPaymentSummary(fromDate, toDate, supplierId);
            
        } else if (status == 2) {
            // Get payment details
            int paymentId = Integer.parseInt(request.getParameter("paymentId"));
            
            result = productBean.getSupplierPaymentDetails(paymentId);
        }
        
        out.print(result);
        
    } catch (Exception e) {
        out.print("[{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}]");
    }
%>
