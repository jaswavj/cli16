<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*, java.sql.*, java.text.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Get filter parameters
String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");
String period = request.getParameter("period");
String gstin = request.getParameter("gstin");
String shopName = request.getParameter("shopName");

// Fetch data from backend
Vector b2bData = new Vector();
Vector b2clData = new Vector();
Vector b2csData = new Vector();
Vector nilRatedData = new Vector();
Vector hsnData = new Vector();

try {
    b2bData = prod.getGSTR1_B2B(startDate, endDate, gstin);
    b2clData = prod.getGSTR1_B2CL(startDate, endDate, gstin);
    b2csData = prod.getGSTR1_B2CS(startDate, endDate);
    nilRatedData = prod.getGSTR1_NilRated(startDate, endDate);
    hsnData = prod.getGSTR1_HSN(startDate, endDate, gstin);
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>Error loading data: " + e.getMessage() + "</div>");
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GSTR-1 Report</title>
<%@ include file="/assets/common/head.jsp" %>
<style>
@media print {
    .no-print { display: none !important; }
    body { font-size: 10pt; }
    table { page-break-inside: auto; }
    tr { page-break-inside: avoid; page-break-after: auto; }
    .nav-tabs { display: none !important; }
    .tab-content { display: block !important; }
    .tab-pane { display: block !important; opacity: 1 !important; }
}

.report-header {
    background: white;
    color: black;
    padding: 1.5rem;
    border: 2px solid #333;
    border-radius: 10px;
    margin-bottom: 1.5rem;
}

.table thead th {
    background: #333;
    color: white;
    border-bottom: 2px solid #333;
    padding: 0.75rem;
    font-size: 0.9rem;
    font-weight: 600;
    text-align: center;
    vertical-align: middle;
}

.table tbody td {
    padding: 0.6rem;
    font-size: 0.85rem;
    vertical-align: middle;
}

.grand-total-row {
    background-color: #f8f9fa;
    font-weight: bold;
    border-top: 2px solid #333;
}

.section-title {
    color: #333;
    font-weight: 600;
    margin-top: 1.5rem;
    margin-bottom: 1rem;
}

.empty-state {
    text-align: center;
    padding: 2rem;
    color: #6c757d;
    font-style: italic;
}

.info-box {
    background: #e7f3ff;
    border-left: 4px solid #2196F3;
    padding: 1rem;
    margin-bottom: 1rem;
}

.warning-badge {
    background: #ff9800;
    color: white;
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    font-size: 0.75rem;
}

.nav-tabs .nav-link {
    color: #333;
    font-weight: 500;
}

.nav-tabs .nav-link.active {
    background: #333;
    color: white;
    border-color: #333;
}
</style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
    <!-- Action Buttons -->
    <div class="no-print mb-3">
        <a href="<%=contextPath%>/reports/GST/gstr1/page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
        <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
        <button class="btn btn-success btn-sm" onclick="exportToExcel()">📊 Export to Excel</button>
        <button class="btn btn-info btn-sm" onclick="exportToJSON()">📄 Export JSON</button>
    </div>

    <!-- Report Header -->
    <div class="report-header">
        <h3 class="text-center mb-2">FORM GSTR-1</h3>
        <div class="row">
            <div class="col-md-4">
                <strong>GSTIN:</strong> <%=gstin%>
            </div>
            <div class="col-md-4 text-center">
                <strong>Period:</strong> <%=period%>
            </div>
            <div class="col-md-4 text-end">
                <strong>From:</strong> <%=startDate%> <strong>To:</strong> <%=endDate%>
            </div>
        </div>
        <div class="text-center mt-2">
            <strong>Trade Name:</strong> <%=shopName%>
        </div>
    </div>

    <!-- Tabs Navigation -->
    <ul class="nav nav-tabs no-print" id="gstr1Tabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link active" id="b2b-tab" data-bs-toggle="tab" data-bs-target="#b2b" type="button">
                B2B (<%=b2bData.size()%>)
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="b2cl-tab" data-bs-toggle="tab" data-bs-target="#b2cl" type="button">
                B2CL (<%=b2clData.size()%>)
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="b2cs-tab" data-bs-toggle="tab" data-bs-target="#b2cs" type="button">
                B2CS (<%=b2csData.size()%>)
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="cdn-tab" data-bs-toggle="tab" data-bs-target="#cdn" type="button">
                Credit/Debit Notes
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="nil-tab" data-bs-toggle="tab" data-bs-target="#nil" type="button">
                Nil Rated (<%=nilRatedData.size()%>)
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link" id="hsn-tab" data-bs-toggle="tab" data-bs-target="#hsn" type="button">
                HSN Summary (<%=hsnData.size()%>)
            </button>
        </li>
    </ul>

    <!-- Tab Content -->
    <div class="tab-content mt-3" id="gstr1TabContent">
        
        <!-- B2B Section -->
        <div class="tab-pane fade show active" id="b2b" role="tabpanel">
            <h4 class="section-title">4. B2B Invoices - Supplies made to Registered Persons</h4>
            <div class="info-box">
                <strong>Note:</strong> All supplies to registered persons (customers with valid 15-digit GSTIN) are reported here.
                If one invoice has products with different GST rates, it appears in multiple rows.
            </div>
            
            <%if(b2bData.size() > 0) {%>
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="b2bTable">
                    <thead>
                        <tr>
                            <th>S.No</th>
                            <th>GSTIN of Recipient</th>
                            <th>Customer Name</th>
                            <th>Invoice Number</th>
                            <th>Invoice Date</th>
                            <th>Place of Supply</th>
                            <th>Rate (%)</th>
                            <th>Taxable Value (₹)</th>
                            <th>CGST (₹)</th>
                            <th>SGST (₹)</th>
                            <th>IGST (₹)</th>
                            <th>Invoice Value (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        double totalTaxable = 0, totalCGST = 0, totalSGST = 0, totalIGST = 0, totalInvoice = 0;
                        for(int i = 0; i < b2bData.size(); i++) {
                            Vector row = (Vector)b2bData.elementAt(i);
                            String customerGSTIN = (String)row.elementAt(0);
                            String customerName = (String)row.elementAt(1);
                            String invoiceNo = (String)row.elementAt(2);
                            String invoiceDate = (String)row.elementAt(3);
                            String placeOfSupply = (String)row.elementAt(4);
                            String rate = (String)row.elementAt(5);
                            String taxableValue = (String)row.elementAt(6);
                            String cgst = (String)row.elementAt(7);
                            String sgst = (String)row.elementAt(8);
                            String igst = (String)row.elementAt(9);
                            String invoiceValue = (String)row.elementAt(10);
                            
                            totalTaxable += Double.parseDouble(taxableValue);
                            totalCGST += Double.parseDouble(cgst);
                            totalSGST += Double.parseDouble(sgst);
                            totalIGST += Double.parseDouble(igst);
                            totalInvoice += Double.parseDouble(invoiceValue);
                        %>
                        <tr>
                            <td class="text-center"><%=i+1%></td>
                            <td><%=customerGSTIN%></td>
                            <td><%=customerName%></td>
                            <td><%=invoiceNo%></td>
                            <td class="text-center"><%=invoiceDate%></td>
                            <td><%=placeOfSupply%></td>
                            <td class="text-center"><%=rate%>%</td>
                            <td class="text-end"><%=taxableValue%></td>
                            <td class="text-end"><%=cgst%></td>
                            <td class="text-end"><%=sgst%></td>
                            <td class="text-end"><%=igst%></td>
                            <td class="text-end"><%=invoiceValue%></td>
                        </tr>
                        <%}%>
                        <tr class="grand-total-row">
                            <td colspan="7" class="text-end"><strong>GRAND TOTAL:</strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalTaxable)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalCGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalSGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalIGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalInvoice)%></strong></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <%} else {%>
            <div class="empty-state">
                <p>No B2B transactions found for the selected period.</p>
            </div>
            <%}%>
        </div>

        <!-- B2CL Section -->
        <div class="tab-pane fade" id="b2cl" role="tabpanel">
            <h4 class="section-title">5. B2C (Large) Invoices - Supplies to Unregistered Persons (Invoice > ₹2.5 Lakhs)</h4>
            <div class="info-box">
                <strong>Note:</strong> Invoices to customers without GSTIN where invoice value exceeds ₹2,50,000.
            </div>
            
            <%if(b2clData.size() > 0) {%>
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="b2clTable">
                    <thead>
                        <tr>
                            <th>S.No</th>
                            <th>Invoice Number</th>
                            <th>Invoice Date</th>
                            <th>Customer Name</th>
                            <th>Place of Supply</th>
                            <th>Rate (%)</th>
                            <th>Taxable Value (₹)</th>
                            <th>CGST (₹)</th>
                            <th>SGST (₹)</th>
                            <th>IGST (₹)</th>
                            <th>Invoice Value (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        double totalTaxable = 0, totalCGST = 0, totalSGST = 0, totalIGST = 0, totalInvoice = 0;
                        for(int i = 0; i < b2clData.size(); i++) {
                            Vector row = (Vector)b2clData.elementAt(i);
                            String invoiceNo = (String)row.elementAt(0);
                            String invoiceDate = (String)row.elementAt(1);
                            String customerName = (String)row.elementAt(2);
                            String placeOfSupply = (String)row.elementAt(3);
                            String rate = (String)row.elementAt(4);
                            String taxableValue = (String)row.elementAt(5);
                            String cgst = (String)row.elementAt(6);
                            String sgst = (String)row.elementAt(7);
                            String igst = (String)row.elementAt(8);
                            String invoiceValue = (String)row.elementAt(9);
                            
                            totalTaxable += Double.parseDouble(taxableValue);
                            totalCGST += Double.parseDouble(cgst);
                            totalSGST += Double.parseDouble(sgst);
                            totalIGST += Double.parseDouble(igst);
                            totalInvoice += Double.parseDouble(invoiceValue);
                        %>
                        <tr>
                            <td class="text-center"><%=i+1%></td>
                            <td><%=invoiceNo%></td>
                            <td class="text-center"><%=invoiceDate%></td>
                            <td><%=customerName%></td>
                            <td><%=placeOfSupply%></td>
                            <td class="text-center"><%=rate%>%</td>
                            <td class="text-end"><%=taxableValue%></td>
                            <td class="text-end"><%=cgst%></td>
                            <td class="text-end"><%=sgst%></td>
                            <td class="text-end"><%=igst%></td>
                            <td class="text-end"><%=invoiceValue%></td>
                        </tr>
                        <%}%>
                        <tr class="grand-total-row">
                            <td colspan="6" class="text-end"><strong>GRAND TOTAL:</strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalTaxable)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalCGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalSGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalIGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalInvoice)%></strong></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <%} else {%>
            <div class="empty-state">
                <p>No B2CL transactions found for the selected period.</p>
            </div>
            <%}%>
        </div>

        <!-- B2CS Section -->
        <div class="tab-pane fade" id="b2cs" role="tabpanel">
            <h4 class="section-title">7. B2C (Small) - Consolidated Supplies (Invoice ≤ ₹2.5 Lakhs)</h4>
            <div class="info-box">
                <strong>Note:</strong> Consolidated summary of supplies to unregistered customers where invoice value is up to ₹2,50,000.
                Data is grouped by Place of Supply and GST Rate.
            </div>
            
            <%if(b2csData.size() > 0) {%>
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="b2csTable">
                    <thead>
                        <tr>
                            <th>S.No</th>
                            <th>Place of Supply</th>
                            <th>Rate (%)</th>
                            <th>Taxable Value (₹)</th>
                            <th>CGST (₹)</th>
                            <th>SGST (₹)</th>
                            <th>IGST (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        double totalTaxable = 0, totalCGST = 0, totalSGST = 0, totalIGST = 0;
                        for(int i = 0; i < b2csData.size(); i++) {
                            Vector row = (Vector)b2csData.elementAt(i);
                            String placeOfSupply = (String)row.elementAt(0);
                            String rate = (String)row.elementAt(1);
                            String taxableValue = (String)row.elementAt(2);
                            String cgst = (String)row.elementAt(3);
                            String sgst = (String)row.elementAt(4);
                            String igst = (String)row.elementAt(5);
                            
                            totalTaxable += Double.parseDouble(taxableValue);
                            totalCGST += Double.parseDouble(cgst);
                            totalSGST += Double.parseDouble(sgst);
                            totalIGST += Double.parseDouble(igst);
                        %>
                        <tr>
                            <td class="text-center"><%=i+1%></td>
                            <td><%=placeOfSupply%></td>
                            <td class="text-center"><%=rate%>%</td>
                            <td class="text-end"><%=taxableValue%></td>
                            <td class="text-end"><%=cgst%></td>
                            <td class="text-end"><%=sgst%></td>
                            <td class="text-end"><%=igst%></td>
                        </tr>
                        <%}%>
                        <tr class="grand-total-row">
                            <td colspan="3" class="text-end"><strong>GRAND TOTAL:</strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalTaxable)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalCGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalSGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalIGST)%></strong></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <%} else {%>
            <div class="empty-state">
                <p>No B2CS transactions found for the selected period.</p>
            </div>
            <%}%>
        </div>

        <!-- Credit/Debit Notes Section -->
        <div class="tab-pane fade" id="cdn" role="tabpanel">
            <h4 class="section-title">9. Credit/Debit Notes (Registered)</h4>
            <div class="info-box">
                <strong>Note:</strong> Credit and Debit notes issued to registered persons.
            </div>
            <div class="empty-state">
                <p>⚠️ No Credit/Debit Notes functionality available for this period.</p>
                <small class="text-muted">This section will display credit/debit notes when the feature is implemented.</small>
            </div>
        </div>

        <!-- Nil Rated Section -->
        <div class="tab-pane fade" id="nil" role="tabpanel">
            <h4 class="section-title">8. Nil Rated, Exempted and Non-GST Supplies</h4>
            <div class="info-box">
                <strong>Note:</strong> Supplies with 0% GST rate (nil rated or exempted items).
            </div>
            
            <%if(nilRatedData.size() > 0) {%>
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="nilTable">
                    <thead>
                        <tr>
                            <th>S.No</th>
                            <th>Invoice Number</th>
                            <th>Invoice Date</th>
                            <th>Customer Name</th>
                            <th>Invoice Value (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        double totalValue = 0;
                        for(int i = 0; i < nilRatedData.size(); i++) {
                            Vector row = (Vector)nilRatedData.elementAt(i);
                            String invoiceNo = (String)row.elementAt(0);
                            String invoiceDate = (String)row.elementAt(1);
                            String customerName = (String)row.elementAt(2);
                            String value = (String)row.elementAt(3);
                            
                            totalValue += Double.parseDouble(value);
                        %>
                        <tr>
                            <td class="text-center"><%=i+1%></td>
                            <td><%=invoiceNo%></td>
                            <td class="text-center"><%=invoiceDate%></td>
                            <td><%=customerName%></td>
                            <td class="text-end"><%=value%></td>
                        </tr>
                        <%}%>
                        <tr class="grand-total-row">
                            <td colspan="4" class="text-end"><strong>GRAND TOTAL:</strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalValue)%></strong></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <%} else {%>
            <div class="empty-state">
                <p>No Nil Rated/Exempted supplies found for the selected period.</p>
            </div>
            <%}%>
        </div>

        <!-- HSN Summary Section -->
        <div class="tab-pane fade" id="hsn" role="tabpanel">
            <h4 class="section-title">12. HSN-wise Summary of Outward Supplies</h4>
            <div class="info-box">
                <strong>Note:</strong> Summary of all outward supplies grouped by HSN/SAC code.
                Items marked as <span class="warning-badge">N/A</span> do not have HSN codes configured.
            </div>
            
            <%if(hsnData.size() > 0) {%>
            <div class="table-responsive">
                <table class="table table-bordered table-hover" id="hsnTable">
                    <thead>
                        <tr>
                            <th>S.No</th>
                            <th>HSN Code</th>
                            <th>Description</th>
                            <th>Total Qty</th>
                            <th>Rate (%)</th>
                            <th>Taxable Value (₹)</th>
                            <th>CGST (₹)</th>
                            <th>SGST (₹)</th>
                            <th>IGST (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        double totalQty = 0, totalTaxable = 0, totalCGST = 0, totalSGST = 0, totalIGST = 0;
                        for(int i = 0; i < hsnData.size(); i++) {
                            Vector row = (Vector)hsnData.elementAt(i);
                            String hsnCode = (String)row.elementAt(0);
                            String description = (String)row.elementAt(1);
                            String qty = (String)row.elementAt(2);
                            String rate = (String)row.elementAt(3);
                            String taxableValue = (String)row.elementAt(4);
                            String cgst = (String)row.elementAt(5);
                            String sgst = (String)row.elementAt(6);
                            String igst = (String)row.elementAt(7);
                            
                            totalQty += Double.parseDouble(qty);
                            totalTaxable += Double.parseDouble(taxableValue);
                            totalCGST += Double.parseDouble(cgst);
                            totalSGST += Double.parseDouble(sgst);
                            totalIGST += Double.parseDouble(igst);
                            
                            boolean isNA = hsnCode.equals("N/A");
                        %>
                        <tr>
                            <td class="text-center"><%=i+1%></td>
                            <td class="text-center">
                                <%if(isNA) {%>
                                    <span class="warning-badge">N/A</span>
                                <%} else {%>
                                    <%=hsnCode%>
                                <%}%>
                            </td>
                            <td><%=description%></td>
                            <td class="text-center"><%=qty%></td>
                            <td class="text-center"><%=rate%>%</td>
                            <td class="text-end"><%=taxableValue%></td>
                            <td class="text-end"><%=cgst%></td>
                            <td class="text-end"><%=sgst%></td>
                            <td class="text-end"><%=igst%></td>
                        </tr>
                        <%}%>
                        <tr class="grand-total-row">
                            <td colspan="3" class="text-end"><strong>GRAND TOTAL:</strong></td>
                            <td class="text-center"><strong><%=String.format("%.0f", totalQty)%></strong></td>
                            <td></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalTaxable)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalCGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalSGST)%></strong></td>
                            <td class="text-end"><strong><%=String.format("%.3f", totalIGST)%></strong></td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <%} else {%>
            <div class="empty-state">
                <p>No HSN data found for the selected period.</p>
            </div>
            <%}%>
        </div>
    </div>
</div>

<script>
// Print function
function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            var printArea = document.createElement('div');
            printArea.id = 'printArea';
            printArea.innerHTML = headerHtml;
            
            var reportClone = document.querySelector('.container').cloneNode(true);
            var buttons = reportClone.querySelector('.no-print');
            if(buttons) buttons.remove();
            
            printArea.appendChild(reportClone);
            document.body.appendChild(printArea);
            
            window.print();
            
            document.body.removeChild(printArea);
        })
        .catch(error => {
            console.error('Error loading print header:', error);
            window.print();
        });
}

// Export to Excel function
function exportToExcel() {
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">' +
               '<head><meta charset="UTF-8">' +
               '<style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style>' +
               '</head><body>';
    
    // Add header
    html += '<h2>GSTR-1 Report</h2>';
    html += '<p><strong>GSTIN:</strong> <%=gstin%> | <strong>Period:</strong> <%=period%> | <strong>Trade Name:</strong> <%=shopName%></p>';
    html += '<p><strong>From:</strong> <%=startDate%> <strong>To:</strong> <%=endDate%></p>';
    
    // Add all tables
    var tables = ['b2bTable', 'b2clTable', 'b2csTable', 'nilTable', 'hsnTable'];
    var titles = ['B2B Invoices', 'B2CL Invoices', 'B2CS Consolidated', 'Nil Rated Sales', 'HSN Summary'];
    
    for(var i = 0; i < tables.length; i++) {
        var table = document.getElementById(tables[i]);
        if(table) {
            html += '<h3>' + titles[i] + '</h3>';
            html += '<table border="1">' + table.innerHTML + '</table><br/>';
        }
    }
    
    html += '</body></html>';
    
    var blob = new Blob(['\ufeff', html], { type: 'application/vnd.ms-excel' });
    var downloadLink = document.createElement("a");
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = 'GSTR1_Report_<%=period.replace(" ", "_")%>.xls';
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

// Helper function to convert period to MMYYYY format
function convertPeriodToMMYYYY(period) {
    // Input: "Jan 26" or "Jan26" or similar formats
    // Output: "012026"
    var months = {
        'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
        'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
        'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12'
    };
    
    var cleaned = period.toLowerCase().trim().replace(/\s+/g, '');
    var monthPart = cleaned.substring(0, 3);
    var yearPart = cleaned.substring(3);
    
    // Convert 2-digit year to 4-digit
    if (yearPart.length === 2) {
        yearPart = '20' + yearPart;
    }
    
    return (months[monthPart] || '01') + yearPart;
}

// Helper function to extract state code from place of supply
function extractStateCode(placeOfSupply) {
    // Extract state code from strings like "Tamil Nadu (Local)" or "33-Tamil Nadu"
    if (!placeOfSupply) return "33";
    
    var match = placeOfSupply.match(/^(\d{2})/);
    if (match) return match[1];
    
    // If GSTIN prefix is in format, extract first 2 digits
    if (placeOfSupply.indexOf('-') > -1) {
        var parts = placeOfSupply.split('-');
        if (parts[0].length === 2 && !isNaN(parts[0])) {
            return parts[0];
        }
    }
    
    // Default to Tamil Nadu state code
    return "33";
}

// Helper function to ensure invoice value precision
function calculateInvoiceValue(txval, camt, samt, iamt) {
    return parseFloat((parseFloat(txval) + parseFloat(camt) + parseFloat(samt) + parseFloat(iamt)).toFixed(3));
}

// Export to JSON function (GST Portal / Offline Tool Compatible Format)
function exportToJSON() {
    var retPeriod = convertPeriodToMMYYYY("<%=period%>");
    
    var gstr1Data = {
        "gstin": "<%=gstin%>",
        "ret_period": retPeriod,
        "b2b": [],
        "b2cl": [],
        "b2cs": [],
        "cdnr": [],
        "nil": {
            "inv": []
        },
        "hsn": {
            "data": []
        }
    };
    
    // B2B Data - GST Registered Customers (Grouped by CTIN + Invoice Number + Date)
    var b2bGrouped = {};
    
    <%for(int i = 0; i < b2bData.size(); i++) {
        Vector row = (Vector)b2bData.elementAt(i);
        String ctin = row.elementAt(0).toString();
        String inum = row.elementAt(2).toString();
        String idt = row.elementAt(3).toString();
        String pos = row.elementAt(4).toString();
        double rt = Double.parseDouble(row.elementAt(5).toString());
        double txval = Double.parseDouble(row.elementAt(6).toString());
        double camt = Double.parseDouble(row.elementAt(7).toString());
        double samt = Double.parseDouble(row.elementAt(8).toString());
        double iamt = Double.parseDouble(row.elementAt(9).toString());
    %>
        var ctin_b2b = "<%=ctin%>";
        var inum_b2b = "<%=inum%>";
        var idt_b2b = "<%=idt%>";
        var pos_b2b = "<%=pos%>";
        var rt_b2b = parseFloat("<%=rt%>");
        var txval_b2b = parseFloat("<%=txval%>");
        var camt_b2b = parseFloat("<%=camt%>");
        var samt_b2b = parseFloat("<%=samt%>");
        var iamt_b2b = parseFloat("<%=iamt%>");
        
        // Create unique key for grouping
        var key = ctin_b2b + "|" + inum_b2b + "|" + idt_b2b;
        
        if (!b2bGrouped[key]) {
            b2bGrouped[key] = {
                "ctin": ctin_b2b,
                "inum": inum_b2b,
                "idt": idt_b2b,
                "pos": extractStateCode(pos_b2b),
                "itms": [],
                "totalVal": 0
            };
        }
        
        // Add item with this GST rate
        var itemVal = txval_b2b + camt_b2b + samt_b2b + iamt_b2b;
        b2bGrouped[key].itms.push({
            "num": b2bGrouped[key].itms.length + 1,
            "itm_det": {
                "rt": rt_b2b,
                "txval": txval_b2b,
                "camt": camt_b2b,
                "samt": samt_b2b,
                "iamt": iamt_b2b,
                "csamt": 0
            }
        });
        b2bGrouped[key].totalVal += itemVal;
    <%}%>
    
    // Convert grouped data to B2B array
    var ctinMap = {};
    for (var key in b2bGrouped) {
        var inv = b2bGrouped[key];
        var ctin = inv.ctin;
        
        if (!ctinMap[ctin]) {
            ctinMap[ctin] = {
                "ctin": ctin,
                "inv": []
            };
        }
        
        ctinMap[ctin].inv.push({
            "inum": inv.inum,
            "idt": inv.idt,
            "val": parseFloat(inv.totalVal.toFixed(3)),
            "pos": inv.pos,
            "rchrg": "N",
            "inv_typ": "R",
            "itms": inv.itms
        });
    }
    
    // Add to gstr1Data
    for (var ctin in ctinMap) {
        gstr1Data.b2b.push(ctinMap[ctin]);
    }
    
    // B2CL Data - Inter-state Unregistered > 2.5L (Grouped by Invoice Number + Date)
    var b2clGrouped = {};
    
    <%for(int i = 0; i < b2clData.size(); i++) {
        Vector row = (Vector)b2clData.elementAt(i);
        String inum = row.elementAt(0).toString();
        String idt = row.elementAt(1).toString();
        String pos = row.elementAt(3).toString();
        double rt = Double.parseDouble(row.elementAt(4).toString());
        double txval = Double.parseDouble(row.elementAt(5).toString());
        double camt = Double.parseDouble(row.elementAt(6).toString());
        double samt = Double.parseDouble(row.elementAt(7).toString());
        double iamt = Double.parseDouble(row.elementAt(8).toString());
    %>
        var inum_b2cl = "<%=inum%>";
        var idt_b2cl = "<%=idt%>";
        var pos_b2cl = "<%=pos%>";
        var rt_b2cl = parseFloat("<%=rt%>");
        var txval_b2cl = parseFloat("<%=txval%>");
        var camt_b2cl = parseFloat("<%=camt%>");
        var samt_b2cl = parseFloat("<%=samt%>");
        var iamt_b2cl = parseFloat("<%=iamt%>");
        
        // Only include if inter-state (iamt > 0)
        if (iamt_b2cl > 0) {
            var key_b2cl = inum_b2cl + "|" + idt_b2cl;
            
            if (!b2clGrouped[key_b2cl]) {
                b2clGrouped[key_b2cl] = {
                    "inum": inum_b2cl,
                    "idt": idt_b2cl,
                    "pos": extractStateCode(pos_b2cl),
                    "itms": [],
                    "totalVal": 0
                };
            }
            
            var itemVal_b2cl = txval_b2cl + iamt_b2cl;
            b2clGrouped[key_b2cl].itms.push({
                "num": b2clGrouped[key_b2cl].itms.length + 1,
                "itm_det": {
                    "rt": rt_b2cl,
                    "txval": txval_b2cl,
                    "iamt": iamt_b2cl,
                    "csamt": 0
                }
            });
            b2clGrouped[key_b2cl].totalVal += itemVal_b2cl;
        }
    <%}%>
    
    // Convert grouped B2CL to array
    for (var key_b2cl in b2clGrouped) {
        var inv_b2cl = b2clGrouped[key_b2cl];
        gstr1Data.b2cl.push({
            "inum": inv_b2cl.inum,
            "idt": inv_b2cl.idt,
            "val": parseFloat(inv_b2cl.totalVal.toFixed(3)),
            "pos": inv_b2cl.pos,
            "itms": inv_b2cl.itms
        });
    }
    
    // B2CS Data - Consolidated Inter-state Unregistered ≤ 2.5L
    <%for(int i = 0; i < b2csData.size(); i++) {
        Vector row = (Vector)b2csData.elementAt(i);
        String pos = row.elementAt(0).toString();
        double rt = Double.parseDouble(row.elementAt(1).toString());
        double txval = Double.parseDouble(row.elementAt(2).toString());
        double camt = Double.parseDouble(row.elementAt(3).toString());
        double samt = Double.parseDouble(row.elementAt(4).toString());
        double iamt = Double.parseDouble(row.elementAt(5).toString());
    %>
        var txval_b2cs = parseFloat("<%=txval%>");
        var camt_b2cs = parseFloat("<%=camt%>");
        var samt_b2cs = parseFloat("<%=samt%>");
        var iamt_b2cs = parseFloat("<%=iamt%>");
        
        // Only include inter-state (iamt > 0) - Local sales should not be in B2CS
        if (iamt_b2cs > 0) {
            gstr1Data.b2cs.push({
                "sply_ty": "INTER",
                "pos": extractStateCode("<%=pos%>"),
                "typ": "OE",
                "rt": parseFloat("<%=rt%>"),
                "txval": txval_b2cs,
                "iamt": iamt_b2cs,
                "csamt": 0
            });
        }
    <%}%>
    
    // Nil Rated Data
    <%for(int i = 0; i < nilRatedData.size(); i++) {
        Vector row = (Vector)nilRatedData.elementAt(i);
        String inum = row.elementAt(0).toString();
        String idt = row.elementAt(1).toString();
        double invValue = Double.parseDouble(row.elementAt(3).toString());
    %>
        gstr1Data.nil.inv.push({
            "inum": "<%=inum%>",
            "idt": "<%=idt%>",
            "val": parseFloat("<%=invValue%>"),
            "sply_ty": "INTRB2B"
        });
    <%}%>
    
    // HSN Data
    <%for(int i = 0; i < hsnData.size(); i++) {
        Vector row = (Vector)hsnData.elementAt(i);
        String hsn = row.elementAt(0).toString();
        String desc = row.elementAt(1).toString();
        double qty = Double.parseDouble(row.elementAt(2).toString());
        double rt = Double.parseDouble(row.elementAt(3).toString());
        double txval = Double.parseDouble(row.elementAt(4).toString());
        double camt = Double.parseDouble(row.elementAt(5).toString());
        double samt = Double.parseDouble(row.elementAt(6).toString());
        double iamt = Double.parseDouble(row.elementAt(7).toString());
    %>
        gstr1Data.hsn.data.push({
            "num": <%= i + 1 %>,
            "hsn_sc": "<%=hsn%>",
            "desc": "<%=desc%>",
            "uqc": "NOS",
            "qty": parseFloat("<%=qty%>"),
            "val": parseFloat("<%=txval%>"),
            "txval": parseFloat("<%=txval%>"),
            "iamt": parseFloat("<%=iamt%>"),
            "camt": parseFloat("<%=camt%>"),
            "samt": parseFloat("<%=samt%>"),
            "csamt": 0
        });
    <%}%>
    
    var jsonStr = JSON.stringify(gstr1Data, null, 2);
    var blob = new Blob([jsonStr], { type: 'application/json' });
    var downloadLink = document.createElement("a");
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = 'GSTR1_' + retPeriod + '.json';
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}
</script>

</body>
</html>
