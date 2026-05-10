<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Vector" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
    String supplierId = request.getParameter("supplierId");
    
    if (supplierId == null || supplierId.trim().isEmpty()) {
        out.print("<div class='alert alert-danger'>Invalid supplier selected.</div>");
        return;
    }
    
    try {
        Vector chequeList = productBean.getAvailableCheques(Integer.parseInt(supplierId));
        
        if (chequeList.isEmpty()) {
            out.print("<div class='alert alert-warning mb-0'>");
            out.print("<i class='fas fa-exclamation-triangle me-2'></i>");
            out.print("<strong>No Available Cheques:</strong> There are no available cheques for this supplier.");
            out.print("</div>");
        } else {
%>
<div class="table-responsive">
    <table class="table table-striped table-hover table-sm">
        <thead class="table-info">
            <tr>
                <th>Cheque No</th>
                <th>Entry Date</th>
                <th>Bank Name</th>
            </tr>
        </thead>
        <tbody>
<%
            for (int i = 0; i < chequeList.size(); i++) {
                Vector row = (Vector) chequeList.get(i);
%>
            <tr>
                <td><%= row.get(0) %></td>
                <td><%= row.get(1) %></td>
                <td><%= row.get(2) %></td>
            </tr>
<%
            }
%>
        </tbody>
    </table>
</div>
<%
        }
    } catch (Exception e) {
        out.print("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>
