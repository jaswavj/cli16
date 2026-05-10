<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*,java.text.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate    = request.getParameter("fromDate");
    String toDate      = request.getParameter("toDate");
    int customerId     = Integer.parseInt(request.getParameter("customerId"));
    String customerName = prod.getCustomerNameById(customerId);

    Vector rows = bill.getCommissionReport(fromDate, toDate, customerId);

    // Group rows by bill no
    // Each row: [0]bill_display [1]bill_date [2]product_name [3]qty [4]price [5]disc [6]total [7]comm_per_unit [8]comm_amount
    String currentBill = null;
    double billCommTotal  = 0.0;
    double grandCommTotal = 0.0;
    double grandSaleTotal = 0.0;
    int serial = 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Commission Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .table td, .table th { vertical-align: middle; font-size: 0.85rem; }
        .bill-group-header td {
            background: #e8f0fe;
            font-weight: 600;
            color: #2d3748;
            font-size: 0.85rem;
            padding: 0.3rem 0.4rem;
        }
        .bill-subtotal td {
            background: #f0fdf4;
            font-weight: 600;
            color: #276749;
            font-size: 0.85rem;
            padding: 0.3rem 0.4rem;
        }
        .grand-total-row td {
            background: #2d3748;
            color: #fff;
            font-weight: 700;
            font-size: 0.9rem;
            padding: 0.4rem;
        }
        @media print {
            .no-print { display: none !important; }
            body { background: #fff; }
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h5 class="mb-0">Commission Report</h5>
            <p class="mb-0 text-muted" style="font-size:0.85rem;">
                <strong>Customer:</strong> <%=customerName%> &nbsp;|&nbsp;
                <strong>Period:</strong> <%=fromDate%> to <%=toDate%>
            </p>
        </div>
        <div class="no-print">
            <a href="<%=contextPath%>/reports/commissionReport/page.jsp" class="btn btn-secondary btn-sm me-2">&#8592; Back</a>
            <button class="btn btn-primary btn-sm me-2" onclick="window.print()">&#128424; Print</button>
            <button class="btn btn-success btn-sm" onclick="exportTableToExcel('commTable','Commission_Report')">&#128202; Export</button>
        </div>
    </div>

    <% if (rows == null || rows.size() == 0) { %>
    <div class="alert alert-info">No commission records found for the selected period and customer.</div>
    <% } else { %>

    <div class="table-responsive">
    <table id="commTable" class="table table-bordered mb-0" style="font-size:0.85rem;">
        <thead style="background: linear-gradient(135deg,#f7fafc 0%,#edf2f7 100%);">
            <tr>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;">#</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;">Bill No</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;">Date</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;">Product</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;text-align:right;">Qty</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;text-align:right;">Price</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;text-align:right;">Disc</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;text-align:right;">Total</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;text-align:right;">Comm/Unit</th>
                <th style="padding:0.4rem;color:#4a5568;font-size:0.85rem;text-align:right;">Commission</th>
            </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < rows.size(); i++) {
            Vector row      = (Vector) rows.get(i);
            String billNo   = row.elementAt(0).toString();
            String billDate = row.elementAt(1).toString();
            String prodName = row.elementAt(2).toString();
            double qty        = (Double) row.elementAt(3);
            double price      = (Double) row.elementAt(4);
            double disc       = (Double) row.elementAt(5);
            double rowTotal   = (Double) row.elementAt(6);
            double commPerUnit= (Double) row.elementAt(7);
            double commAmt    = (Double) row.elementAt(8);

            // Detect new bill group — print subtotal for previous bill first
            if (currentBill != null && !currentBill.equals(billNo)) {
        %>
        <tr class="bill-subtotal">
            <td colspan="9" style="text-align:right; padding:0.3rem 0.4rem;">Bill Commission Subtotal (<%=currentBill%>):</td>
            <td style="text-align:right; padding:0.3rem 0.4rem;">&#8377;<%=String.format("%.2f", billCommTotal)%></td>
        </tr>
        <%
                billCommTotal = 0.0;
            }

            // Print bill group header when bill changes
            if (currentBill == null || !currentBill.equals(billNo)) {
                currentBill = billNo;
        %>
        <tr class="bill-group-header">
            <td colspan="10" style="padding:0.3rem 0.4rem;">
                <i class="fa-solid fa-file-invoice me-1"></i>Bill No: <%=billNo%> &nbsp;|&nbsp; Date: <%=billDate%>
            </td>
        </tr>
        <%      } 
            serial++;
            billCommTotal  += commAmt;
            grandCommTotal += commAmt;
            grandSaleTotal += rowTotal;
        %>
        <tr style="border-bottom:1px solid #f1f5f9;">
            <td style="padding:0.4rem;color:#718096;border:none;"><%=serial%></td>
            <td style="padding:0.4rem;color:#718096;border:none;"><%=billNo%></td>
            <td style="padding:0.4rem;color:#718096;border:none;"><%=billDate%></td>
            <td style="padding:0.4rem;color:#2d3748;border:none;"><%=prodName%></td>
            <td style="padding:0.4rem;color:#718096;border:none;text-align:right;"><%=String.format("%.2f", qty)%></td>
            <td style="padding:0.4rem;color:#718096;border:none;text-align:right;">&#8377;<%=String.format("%.2f", price)%></td>
            <td style="padding:0.4rem;color:#718096;border:none;text-align:right;">&#8377;<%=String.format("%.2f", disc)%></td>
            <td style="padding:0.4rem;color:#718096;border:none;text-align:right;">&#8377;<%=String.format("%.2f", rowTotal)%></td>
            <td style="padding:0.4rem;color:#718096;border:none;text-align:right;">&#8377;<%=String.format("%.2f", commPerUnit)%></td>
            <td style="padding:0.4rem;font-weight:600;color:#276749;border:none;text-align:right;">&#8377;<%=String.format("%.2f", commAmt)%></td>
        </tr>
        <% } %>

        <%-- Last bill subtotal --%>
        <% if (currentBill != null) { %>
        <tr class="bill-subtotal">
            <td colspan="9" style="text-align:right; padding:0.3rem 0.4rem;">Bill Commission Subtotal (<%=currentBill%>):</td>
            <td style="text-align:right; padding:0.3rem 0.4rem;">&#8377;<%=String.format("%.2f", billCommTotal)%></td>
        </tr>
        <% } %>

        <%-- Grand Total --%>
        <tr class="grand-total-row">
            <td colspan="7" style="text-align:right;">Grand Total Sale:</td>
            <td style="text-align:right;">&#8377;<%=String.format("%.2f", grandSaleTotal)%></td>
            <td style="text-align:right;">Total Commission:</td>
            <td style="text-align:right;">&#8377;<%=String.format("%.2f", grandCommTotal)%></td>
        </tr>

        </tbody>
    </table>
    </div>

    <% } %>
</div>

<script>
function exportTableToExcel(tableId, filename) {
    var table = document.getElementById(tableId);
    var html  = table.outerHTML;
    var url   = 'data:application/vnd.ms-excel,' + escape(html);
    var a     = document.createElement('a');
    a.href    = url;
    a.download = filename + '.xls';
    a.click();
}
</script>
</body>
</html>
