<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
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
    <title>GST Sales Report - Invoice Wise (GSTR-1)</title>
<%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0">GST Sales Report (Invoice-wise - GSTR-1 Format)</h4>
        <div class="no-print">
            <a href="<%=contextPath%>/reports/GST/salesGST/page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
            <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
            <button class="btn btn-success btn-sm" onclick="exportTableToExcel('gstTable', 'GST_Sales_Invoice_Report')">📊 Export to Excel</button>
        </div>
    </div>
    
    <!-- Date Range Display -->
    <div class="alert alert-info no-print mb-3">
        <strong>Report Period:</strong> <%=fromDate%> to <%=toDate%>
    </div>
    
    <!-- Sales Table -->
    <div class="table-responsive">
    <table id="gstTable" class="table table-hover">
        <thead>
            <tr style="background: #624b88; color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600; text-align: center;">S.No</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600;">Invoice No.</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600;">Invoice Date</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600;">Customer Name</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600;">GSTIN</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600; text-align: right;">Taxable Value (₹)</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600; text-align: right;">CGST (₹)</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600; text-align: right;">SGST (₹)</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600; text-align: right;">Total GST (₹)</th>
                <th style="padding: 0.75rem; font-size: 0.9rem; font-weight: 600; text-align: right;">Invoice Value (₹)</th>
            </tr>
        </thead>
        <tbody>
            <%
            Vector salesDat=bill.getSalesGSTReportInvoiceWise(fromDate, toDate);
            double grandTotalTaxable = 0;
            double grandTotalCGST = 0;
            double grandTotalSGST = 0;
            double grandTotalGST = 0;
            double grandTotalInvoice = 0;
            
            if(salesDat!=null && salesDat.size()>0){
                for(int i=0;i<salesDat.size();i++){
                    Vector row=(Vector)salesDat.elementAt(i);
                    
                    String invoiceNo = (String)row.elementAt(0);
                    String customerName = (String)row.elementAt(1);
                    String invoiceDate = (String)row.elementAt(2);
                    String gstin = (String)row.elementAt(3);
                    double taxableAmount = Double.parseDouble((String)row.elementAt(4));
                    double cgst = Double.parseDouble((String)row.elementAt(5));
                    double sgst = Double.parseDouble((String)row.elementAt(6));
                    double totalGst = Double.parseDouble((String)row.elementAt(7));
                    double invoiceValue = Double.parseDouble((String)row.elementAt(8));
                    
                    // Accumulate totals
                    grandTotalTaxable += taxableAmount;
                    grandTotalCGST += cgst;
                    grandTotalSGST += sgst;
                    grandTotalGST += totalGst;
                    grandTotalInvoice += invoiceValue;
            %>
            <tr style="border-bottom: 1px solid #e2e8f0;">
                <td style="padding: 0.5rem; text-align: center;"><%=i+1%></td>
                <td style="padding: 0.5rem; font-weight: 500;"><%=invoiceNo%></td>
                <td style="padding: 0.5rem;"><%=invoiceDate%></td>
                <td style="padding: 0.5rem;"><%=customerName%></td>
                <td style="padding: 0.5rem; font-family: monospace;"><%=gstin%></td>
                <td style="padding: 0.5rem; text-align: right;"><%=String.format("%.3f", taxableAmount)%></td>
                <td style="padding: 0.5rem; text-align: right;"><%=String.format("%.3f", cgst)%></td>
                <td style="padding: 0.5rem; text-align: right;"><%=String.format("%.3f", sgst)%></td>
                <td style="padding: 0.5rem; text-align: right; font-weight: 500;"><%=String.format("%.3f", totalGst)%></td>
                <td style="padding: 0.5rem; text-align: right; font-weight: 600; color: #2d3748;"><%=String.format("%.3f", invoiceValue)%></td>
            </tr>
            <%
                }
            %>
            <!-- Grand Total Row -->
            <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); font-weight: 700; border-top: 3px solid #4a5568;">
                <td colspan="5" style="padding: 0.75rem; text-align: right; font-size: 1rem; color: #2d3748;">GRAND TOTAL</td>
                <td style="padding: 0.75rem; text-align: right; font-size: 1rem; color: #2d3748;"><%=String.format("%.3f", grandTotalTaxable)%></td>
                <td style="padding: 0.75rem; text-align: right; font-size: 1rem; color: #2d3748;"><%=String.format("%.3f", grandTotalCGST)%></td>
                <td style="padding: 0.75rem; text-align: right; font-size: 1rem; color: #2d3748;"><%=String.format("%.3f", grandTotalSGST)%></td>
                <td style="padding: 0.75rem; text-align: right; font-size: 1rem; color: #2d3748;"><%=String.format("%.3f", grandTotalGST)%></td>
                <td style="padding: 0.75rem; text-align: right; font-size: 1rem; color: #2d3748;"><%=String.format("%.3f", grandTotalInvoice)%></td>
            </tr>
            <%
            } else {
            %>
            <tr>
                <td colspan="10" style="padding: 2rem; text-align: center; color: #718096;">
                    <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 1rem; display: block;"></i>
                    No records found for the selected date range.
                </td>
            </tr>
            <%
            }
            %>
            
        </tbody>
    </table>
    </div>
    
    <!-- GSTR-1 Compliance Note -->
    <div class="alert alert-success mt-4 no-print">
        <h6 class="alert-heading"><i class="fas fa-check-circle"></i> GSTR-1 Compliance Checklist</h6>
        <ul class="mb-0" style="list-style: none; padding-left: 0;">
            <li>✅ Invoice-wise aggregation (One row per invoice)</li>
            <li>✅ Customer GSTIN captured for B2B classification</li>
            <li>✅ Taxable value separated from GST</li>
            <li>✅ CGST and SGST split (50% each)</li>
            <li>✅ Invoice date and number for traceability</li>
            <li>✅ Total invoice value calculation</li>
        </ul>
        <hr>
        <p class="mb-0"><strong>Note:</strong> For complete GSTR-1 filing, classify invoices as:</p>
        <ul class="mb-0">
            <li><strong>B2B:</strong> Invoices with valid GSTIN (15 digits)</li>
            <li><strong>B2C Large:</strong> Invoices > ₹2.5 lakhs without GSTIN</li>
            <li><strong>B2C Small:</strong> Aggregated by GST rate for invoices ≤ ₹2.5 lakhs</li>
        </ul>
    </div>
    
    <!-- Pagination -->
    
</div>

<style>
@media print {
    @page { margin: 0.5cm; size: landscape; }
    body { margin: 0; padding: 0; }
    .no-print { display: none !important; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
    #printArea .container { max-width: 100% !important; margin: 0 !important; padding: 0 10px !important; }
    #printArea table { width: 100% !important; font-size: 9px !important; }
    #printArea table th, #printArea table td { padding: 2px 4px !important; font-size: 9px !important; }
    #printArea h4 { font-size: 14px !important; text-align: center; }
}
</style>

<script>
function printReport() {
    var printArea = document.createElement('div');
    printArea.id = 'printArea';
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            printArea.innerHTML = headerHtml;
            var tableContainer = document.querySelector('.container');
            var tableClone = tableContainer.cloneNode(true);
            var buttons = tableClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            printArea.appendChild(tableClone);
            document.body.appendChild(printArea);
            window.print();
            document.body.removeChild(printArea);
        })
        .catch(error => { console.error('Error loading print header:', error); window.print(); });
}

function exportTableToExcel(tableID, filename = ''){
    var table = document.getElementById(tableID);
    if (!table) { alert('Table not found!'); return; }
    var tableClone = table.cloneNode(true);
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel"><head><meta charset="UTF-8"><style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style></head><body><table border="1">' + tableClone.innerHTML + '</table></body></html>';
    filename = filename ? filename + '.xls' : 'excel_data.xls';
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
    var downloadLink = document.createElement("a");
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}
</script>

</body>
</html>
