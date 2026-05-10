<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("startDate");  
    String toDate   = request.getParameter("endDate");

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase GST Report</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div class="text-center flex-grow-1">
            <h4 class="mb-0">Purchase GST Report</h4>
            <div class="mb-3">
                <strong>From:</strong> <%=fromDate%> <strong>To:</strong> <%=toDate%>
            </div>
        </div>
        <div class="no-print">
            <a href="<%=contextPath%>/reports/GST/purchaseGST/page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
            <button class="btn btn-primary me-2" onclick="printReport()">🖨 Print</button>
            <button class="btn btn-success" onclick="exportTableToExcel()">📊 Export to Excel</button>
        </div>
    </div>
    <!-- Purchase GST Table -->
    <div class="table-responsive">
        <table id="purchaseGstTable" class="table table-hover">
            <thead>
                <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">S.No</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Invoice No.</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Supplier Name</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Invoice Date</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Item Description</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Purchase Amount (₹)</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Taxable Amount (₹)</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">GST Rate (%)</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">CGST (₹)</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">SGST (₹)</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">IGST (₹)</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Total Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
                <%
                Vector purchaseGSTData = prod.getPurchaseGSTReport(fromDate, toDate);
                
                double totalPurchase = 0.0, totalTaxable = 0.0, totalCGST = 0.0, totalSGST = 0.0, totalIGST = 0.0, grandTotal = 0.0;
                if(purchaseGSTData != null && !purchaseGSTData.isEmpty()) {
                    for(int i=0; i<purchaseGSTData.size(); i++) {
                        Vector row = (Vector)purchaseGSTData.elementAt(i);
                        double purchaseAmt = Double.parseDouble((String)row.elementAt(4));
                        double taxableAmt = Double.parseDouble((String)row.elementAt(5));
                        double cgstAmt = Double.parseDouble((String)row.elementAt(7));
                        double sgstAmt = Double.parseDouble((String)row.elementAt(8));
                        double igstAmt = Double.parseDouble((String)row.elementAt(9));
                        double totalAmt = Double.parseDouble((String)row.elementAt(10));
                        
                        totalPurchase += purchaseAmt;
                        totalTaxable += taxableAmt;
                        totalCGST += cgstAmt;
                        totalSGST += sgstAmt;
                        totalIGST += igstAmt;
                        grandTotal += totalAmt;
                %>
                <tr>
                    <td><%=i+1%></td>
                    <td><%=row.elementAt(0)%></td>
                    <td><%=row.elementAt(1)%></td>
                    <td><%=row.elementAt(2)%></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=String.format("%.3f", purchaseAmt)%></td>
                    <td><%=String.format("%.3f", taxableAmt)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%=String.format("%.3f", cgstAmt)%></td>
                    <td><%=String.format("%.3f", sgstAmt)%></td>
                    <td><%=String.format("%.3f", igstAmt)%></td>
                    <td><%=String.format("%.3f", totalAmt)%></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="12" class="text-center">No data found for the selected date range.</td>
                </tr>
                <%
                }
                %>
            </tbody>
            <% if(purchaseGSTData != null && !purchaseGSTData.isEmpty()) { %>
            <tfoot class="table-dark">
                <tr>
                    <th colspan="5" class="text-end">Total:</th>
                    <th><%=String.format("%.3f", totalPurchase)%></th>
                    <th><%=String.format("%.3f", totalTaxable)%></th>
                    <th>-</th>
                    <th><%=String.format("%.3f", totalCGST)%></th>
                    <th><%=String.format("%.3f", totalSGST)%></th>
                    <th><%=String.format("%.3f", totalIGST)%></th>
                    <th><%=String.format("%.3f", grandTotal)%></th>
                </tr>
            </tfoot>
            <% } %>
        </table>
    </div>
</div>

<style>
@media print {
    @page {
        size: portrait;
        margin: 0.3cm;
    }
    body * {
        visibility: hidden;
    }
    #printArea, #printArea * {
        visibility: visible;
    }
    #printArea {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
    }
    .no-print {
        display: none !important;
    }
    body {
        font-size: 8px;
        padding: 0;
        margin: 0;
    }
    .container {
        padding: 0 5px;
        max-width: 100%;
    }
    table {
        font-size: 8px;
        width: 100%;
        border-collapse: collapse;
    }
    th, td {
        padding: 1px 2px;
        word-wrap: break-word;
        max-width: 80px;
    }
    h4 {
        font-size: 10px;
        margin: 0;
    }
}
</style>

<script>
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            const printArea = document.createElement('div');
            printArea.id = 'printArea';
            printArea.innerHTML = headerHtml;
            
            const container = document.querySelector('.container').cloneNode(true);
            const noPrintElements = container.querySelectorAll('.no-print');
            noPrintElements.forEach(el => el.remove());
            
            printArea.appendChild(container);
            document.body.appendChild(printArea);
            
            window.print();
            
            document.body.removeChild(printArea);
        })
        .catch(err => {
            console.error('Error loading print header:', err);
            alert('Error loading print header');
        });
}

function exportTableToExcel() {
    const table = document.getElementById('purchaseGstTable');
    const filename = 'Purchase_GST_Report.xls';
    
    const tableClone = table.cloneNode(true);
    const buttons = tableClone.querySelectorAll('button, .no-print');
    buttons.forEach(btn => btn.remove());
    
    const html = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel">' +
                 '<head><meta charset="utf-8"><style>table { border-collapse: collapse; width: 100%; } th, td { border: 1px solid #000; padding: 8px; text-align: left; }</style></head>' +
                 '<body>' + tableClone.outerHTML + '</body></html>';
    
    const blob = new Blob(['\ufeff', html], {
        type: 'application/vnd.ms-excel'
    });
    
    const url = URL.createObjectURL(blob);
    const downloadLink = document.createElement('a');
    downloadLink.href = url;
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
    URL.revokeObjectURL(url);
}
</script>

</body>
</html>