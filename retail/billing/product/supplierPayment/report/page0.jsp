<%@ page import="java.util.*" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
String contextPath = request.getContextPath();
    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");
    String supplierIdStr = request.getParameter("supplierId");
    int supplierId = 0;
    if (supplierIdStr != null && !supplierIdStr.trim().isEmpty() && !supplierIdStr.equals("0")) {
        supplierId = Integer.parseInt(supplierIdStr);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Supplier Payment Report</title>
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
            <p class="mb-0"><strong>Supplier Payment Report From:</strong> <%= fromDate %> - <%= toDate %></p>
            <div class="no-print">
                <a href="<%=contextPath%>/product/supplierPayment/report/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
                <button class="btn btn-primary btn-sm" onclick="window.print()">🖨 Print</button>
            </div>
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover table-bordered" id="reportTable">
                <thead class="table-dark">
                    <tr>
                        <th>S.No</th>
                        <th>Date</th>
                        <th>PR No</th>
                        <th>Supplier Name</th>
                        <th>Total Amount</th>
                        <th>Paid Amount</th>
                        <th>Balance</th>
                        <th class="no-print">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Vector vec = productBean.getSupplierPaymentReport(fromDate, toDate, supplierId);
                        double grandTotal = 0;
                        double grandPaid = 0;
                        double grandBalance = 0;
                        
                        for (int i = 0; i < vec.size(); i++) {
                            Vector row = (Vector) vec.elementAt(i);
                            int paymentId = Integer.parseInt(row.elementAt(0).toString());
                            String date = row.elementAt(1).toString();
                            String prNo = row.elementAt(2).toString();
                            String supplierName = row.elementAt(3).toString();
                            double total = Double.parseDouble(row.elementAt(4).toString());
                            double paid = Double.parseDouble(row.elementAt(5).toString());
                            double balance = Double.parseDouble(row.elementAt(6).toString());
                            
                            grandTotal += total;
                            grandPaid += paid;
                            grandBalance += balance;
                    %>
                    <tr>
                        <td><%= i + 1 %></td>
                        <td><%= date %></td>
                        <td><%= prNo %></td>
                        <td><%= supplierName %></td>
                        <td class="text-end"><%= String.format("%.3f", total) %></td>
                        <td class="text-end"><%= String.format("%.3f", paid) %></td>
                        <td class="text-end"><%= String.format("%.3f", balance) %></td>
                        <td class="text-center no-print">
                            <a href="detail.jsp?paymentId=<%= paymentId %>&supplierName=<%= java.net.URLEncoder.encode(supplierName, "UTF-8") %>" 
                               class="btn btn-sm btn-info">
                                <i class="fas fa-eye"></i> Details
                            </a>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
                <tfoot class="table-secondary">
                    <tr>
                        <td colspan="3" class="text-end"><strong>Grand Total:</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", grandTotal) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", grandPaid) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", grandBalance) %></strong></td>
                        <td class="no-print"></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
</body>
</html>