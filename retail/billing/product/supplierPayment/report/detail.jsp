<%@ page import="java.util.*" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
    int paymentId = Integer.parseInt(request.getParameter("paymentId"));
    String supplierName = request.getParameter("supplierName");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Payment Details</title>
    <jsp:include page="../../../assets/common/head.jsp" />
    <style>
        body {
            background: #f5f7fa;
        }
        .navbar {
            background-color: #4e73df;
        }
        .navbar-brand {
            color: #fff !important;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        @media print {
            .no-print {
                display: none;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="../../../assets/navbar/navbar.jsp" />
    
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4><strong>Payment Details - <%= supplierName %></strong></h4>
            <div class="no-print">
                <a href="javascript:history.back()" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
                <button class="btn btn-primary btn-sm" onclick="window.print()">🖨 Print</button>
            </div>
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th>S.No</th>
                        <th>Date & Time</th>
                        <th>Paid Amount</th>
                        <th>Payment Mode</th>
                        <th>User</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Vector details = productBean.getSupplierPaymentDetailsReport(paymentId);
                        double totalPaid = 0;
                        
                        for (int i = 0; i < details.size(); i++) {
                            Vector row = (Vector) details.elementAt(i);
                            double paid = Double.parseDouble(row.elementAt(0).toString());
                            String dateTime = row.elementAt(1).toString();
                            String paymentMode = row.elementAt(2).toString();
                            String userName = row.elementAt(3).toString();
                            
                            totalPaid += paid;
                    %>
                    <tr>
                        <td><%= i + 1 %></td>
                        <td><%= dateTime %></td>
                        <td class="text-end"><%= String.format("%.3f", paid) %></td>
                        <td><%= paymentMode %></td>
                        <td><%= userName %></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
                <tfoot class="table-secondary">
                    <tr>
                        <td colspan="2" class="text-end"><strong>Total Paid:</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalPaid) %></strong></td>
                        <td colspan="2"></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
</body>
</html>