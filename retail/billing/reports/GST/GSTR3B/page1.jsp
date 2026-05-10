<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*, java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="productBean" class="product.productBean" />
<!DOCTYPE html>
<html>
<head>
    <title>GSTR-3B Summary Report</title>
<%@ include file="/assets/common/head.jsp" %>
    <style>
        .gstr3b-container {
            max-width: 1200px;
            
            padding: 5px 10px;
            background: white;
        }
        .report-header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #333;
            padding-bottom: 15px;
        }
        .filter-section {
            background: #f5f5f5;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .filter-section select, .filter-section input {
            padding: 8px;
            margin: 5px;
            border: 1px solid #ccc;
            border-radius: 3px;
        }
        .info-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 25px;
        }
        .info-box {
            padding: 10px;
            background: #f9f9f9;
            border-left: 3px solid #007bff;
        }
        .section-title {
            background: #007bff;
            color: white;
            padding: 10px;
            font-weight: bold;
            margin-top: 25px;
            margin-bottom: 15px;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .data-table th {
            background: #343a40;
            color: white;
            padding: 10px;
            text-align: left;
            border: 1px solid #dee2e6;
        }
        .data-table td {
            padding: 8px;
            border: 1px solid #dee2e6;
        }
        .data-table tr:nth-child(even) {
            background: #f8f9fa;
        }
        .total-row {
            background: #e9ecef !important;
            font-weight: bold;
        }
        .amount-cell {
            text-align: right;
        }
        .tax-payable-section {
            background: #fff3cd;
            padding: 20px;
            border-radius: 5px;
            margin-top: 25px;
        }
        .tax-payable-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-top: 15px;
        }
        .tax-box {
            background: white;
            padding: 15px;
            border: 2px solid #ffc107;
            border-radius: 5px;
            text-align: center;
        }
        .tax-label {
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }
        .tax-amount {
            font-size: 24px;
            font-weight: bold;
            color: #d9534f;
        }
        .action-buttons {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            margin-bottom: 15px;
        }
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
        }
        .btn-back {
            background: #6c757d;
            color: white;
        }
        .btn-back:hover {
            background: #5a6268;
        }
        .btn-excel {
            background: #17a2b8;
            color: white;
        }
        .btn-excel:hover {
            background: #138496;
        }
        .btn-print {
            background: #28a745;
            color: white;
        }
        .btn-print:hover {
            background: #218838;
        }
        @media print {
            .filter-section, .action-buttons {
                display: none;
            }
        }
    </style>
</head>
<body>
        <%@ include file="/assets/navbar/navbar.jsp" %>
    <div class="gstr3b-container">
        <div class="action-buttons">
            <button class="btn btn-back" onclick="window.history.back()">⬅ Back</button>
            <button class="btn btn-excel" onclick="exportToExcel()">📊 Export to Excel</button>
            <button class="btn btn-print" onclick="window.print()">🖨️ Print Report</button>
        </div>
        
        

        

<%
    // Get parameters
    String selectedMonth = request.getParameter("month");
    String selectedYear = request.getParameter("year");
    
    if (selectedMonth == null) selectedMonth = "01";
    if (selectedYear == null) selectedYear = "2026";
    
    String startDate = selectedYear + "-" + selectedMonth + "-01";
    String endDate = selectedYear + "-" + selectedMonth + "-31";
    
    String gstin = "";
    String tradeName = "";
    
    // Data structures using bean
    Map<Double, Map<String, Double>> outwardSupplies = new TreeMap<>();
    double nilRatedSupplies = 0.0;
    double exemptSupplies = 0.0;
    double nonGSTSupplies = 0.0;
    
    Map<String, Double> itc = new HashMap<>();
    Map<String, Double> totals = new HashMap<>();
    Map<String, Double> taxPayable = new HashMap<>();
    
    try {
        // Fetch GSTIN and Trade Name
        Map<String, String> gstInfo = productBean.getGSTINInfo();
        gstin = gstInfo.get("gstin");
        tradeName = gstInfo.get("shop_name");
        
        // Get Outward Supplies (Sales)
        outwardSupplies = productBean.getOutwardSupplies(startDate, endDate);
        
        // Get Nil Rated Supplies
        nilRatedSupplies = productBean.getNilRatedSupplies(startDate, endDate);
        
        // Get Input Tax Credit (Purchases)
        itc = productBean.getInputTaxCredit(startDate, endDate);
        
        // Calculate totals
        totals = productBean.getOutwardSuppliesTotals(outwardSupplies);
        
        // Calculate Tax Payable
        taxPayable = productBean.calculateTaxPayable(outwardSupplies, itc);
        
    } catch (Exception e) {
        out.println("<div style='color: red; padding: 20px;'>Error: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>

        <div class="info-section">
            <div class="info-box">
                <strong>GSTIN:</strong> <%= gstin.isEmpty() ? "Not Configured" : gstin %>
            </div>
            <div class="info-box">
                <strong>Trade Name:</strong> <%= tradeName.isEmpty() ? "Not Configured" : tradeName %>
            </div>
            <div class="info-box">
                <strong>Period:</strong> <%= selectedMonth %>/<%= selectedYear %>
            </div>
            <div class="info-box">
                <strong>Generated On:</strong> <%= new SimpleDateFormat("dd-MMM-yyyy hh:mm a").format(new java.util.Date()) %>
            </div>
        </div>

        <!-- Table 3.1 - Outward Supplies -->
        <div class="section-title">3.1 - Outward Supplies and Inward Supplies Liable to Reverse Charge</div>
        
        <h3 style="margin: 15px 0; color: #007bff;">3.1(a) - Outward Taxable Supplies (other than zero rated, nil rated and exempted)</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>GST Rate (%)</th>
                    <th>Taxable Value (₹)</th>
                    <th>Central Tax (₹)</th>
                    <th>State/UT Tax (₹)</th>
                    <th>Integrated Tax (₹)</th>
                    <th>Cess (₹)</th>
                </tr>
            </thead>
            <tbody> 
<%
    // Sort GST rates
    List<Double> sortedRates = new ArrayList<>(outwardSupplies.keySet());
    Collections.sort(sortedRates);
    
    for (Double rate : sortedRates) {
        Map<String, Double> taxMap = outwardSupplies.get(rate);
        double taxable = taxMap.getOrDefault("taxable", 0.0);
        double cgst = taxMap.getOrDefault("cgst", 0.0);
        double sgst = taxMap.getOrDefault("sgst", 0.0);
        double igst = taxMap.getOrDefault("igst", 0.0);
%>
                <tr>
                    <td><%= String.format("%.3f", rate) %>%</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", taxable) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", cgst) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", sgst) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", igst) %></td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
<%
    }
%>
                <tr class="total-row">
                    <td>Total</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", totals.getOrDefault("taxable", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", totals.getOrDefault("cgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", totals.getOrDefault("sgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", totals.getOrDefault("igst", 0.0)) %></td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
            </tbody>
        </table>

        <h3 style="margin: 15px 0; color: #007bff;">3.1(c) - Other Outward Supplies (Nil rated, exempted)</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Description</th>
                    <th>Value (₹)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Nil Rated Supplies</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", nilRatedSupplies) %></td>
                </tr>
                <tr>
                    <td>Exempted Supplies</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", exemptSupplies) %></td>
                </tr>
                <tr>
                    <td>Non-GST Supplies</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", nonGSTSupplies) %></td>
                </tr>
                <tr class="total-row">
                    <td>Total</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", nilRatedSupplies + exemptSupplies + nonGSTSupplies) %></td>
                </tr>
            </tbody>
        </table>

        <!-- Table 4 - ITC -->
        <div class="section-title">4 - Eligible Input Tax Credit (ITC)</div>
        
        <h3 style="margin: 15px 0; color: #007bff;">4(A) - ITC Available (on purchases from registered suppliers)</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Details</th>
                    <th>Central Tax (₹)</th>
                    <th>State/UT Tax (₹)</th>
                    <th>Integrated Tax (₹)</th>
                    <th>Cess (₹)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>(1) Import of goods</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr>
                    <td>(2) Import of services</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr>
                    <td>(3) Inward supplies liable to reverse charge</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr>
                    <td>(4) Inward supplies from ISD</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr>
                    <td><strong>(5) All other ITC (Purchases)</strong></td>
                    <td class="amount-cell"><strong>₹ <%= String.format("%,.2f", itc.getOrDefault("cgst", 0.0)) %></strong></td>
                    <td class="amount-cell"><strong>₹ <%= String.format("%,.2f", itc.getOrDefault("sgst", 0.0)) %></strong></td>
                    <td class="amount-cell"><strong>₹ <%= String.format("%,.2f", itc.getOrDefault("igst", 0.0)) %></strong></td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr class="total-row">
                    <td>Total ITC Available</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", itc.getOrDefault("cgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", itc.getOrDefault("sgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", itc.getOrDefault("igst", 0.0)) %></td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
            </tbody>
        </table>

        <h3 style="margin: 15px 0; color: #007bff;">4(B) - ITC Reversed</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Details</th>
                    <th>Central Tax (₹)</th>
                    <th>State/UT Tax (₹)</th>
                    <th>Integrated Tax (₹)</th>
                    <th>Cess (₹)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>(1) As per Rule 42 & 43 of CGST Rules</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr>
                    <td>(2) Others</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
                <tr class="total-row">
                    <td>Total ITC Reversed</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
            </tbody>
        </table>

        <h3 style="margin: 15px 0; color: #007bff;">4(D) - Net ITC Available</h3>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Details</th>
                    <th>Central Tax (₹)</th>
                    <th>State/UT Tax (₹)</th>
                    <th>Integrated Tax (₹)</th>
                    <th>Cess (₹)</th>
                </tr>
            </thead>
            <tbody>
                <tr class="total-row">
                    <td>Net ITC Available (A - B)</td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", itc.getOrDefault("cgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", itc.getOrDefault("sgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", itc.getOrDefault("igst", 0.0)) %></td>
                    <td class="amount-cell">₹ 0.00</td>
                </tr>
            </tbody>
        </table>

        <!-- Tax Payable Section -->
        <div class="tax-payable-section">
            <h2 style="margin: 0 0 10px 0; color: #856404;">5 - Tax Payable</h2>
            <p style="margin: 0 0 15px 0; color: #666;">Net Tax Liability (Output Tax - Input Tax Credit)</p>
            
            <div class="tax-payable-grid">
                <div class="tax-box">
                    <div class="tax-label">CGST Payable</div>
                    <div class="tax-amount">₹ <%= String.format("%,.2f", taxPayable.getOrDefault("cgst", 0.0)) %></div>
                </div>
                <div class="tax-box">
                    <div class="tax-label">SGST Payable</div>
                    <div class="tax-amount">₹ <%= String.format("%,.2f", taxPayable.getOrDefault("sgst", 0.0)) %></div>
                </div>
                <div class="tax-box">
                    <div class="tax-label">IGST Payable</div>
                    <div class="tax-amount">₹ <%= String.format("%,.2f", taxPayable.getOrDefault("igst", 0.0)) %></div>
                </div>
                <div class="tax-box" style="border-color: #d9534f; background: #f8d7da;">
                    <div class="tax-label">TOTAL TAX PAYABLE</div>
                    <div class="tax-amount" style="color: #721c24;">₹ <%= String.format("%,.2f", taxPayable.getOrDefault("total", 0.0)) %></div>
                </div>
            </div>
        </div>

        <div style="margin-top: 30px; padding: 15px; background: #e7f3ff; border-left: 4px solid #2196F3;">
            <strong>Note:</strong> This is a system-generated report based on sales and purchase data. Please verify all figures before filing with GST portal.
        </div>

    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script>
        function exportToExcel() {
            const period = '<%= selectedMonth %>/<%= selectedYear %>';
            const gstin = '<%= gstin %>';
            const tradeName = '<%= tradeName %>';
            
            // Create workbook
            const wb = XLSX.utils.book_new();
            
            // Sheet 1: Outward Supplies
            const outwardData = [
                ['GSTR-3B Summary Report'],
                ['Period: ' + period],
                ['GSTIN: ' + gstin],
                ['Trade Name: ' + tradeName],
                [],
                ['3.1(a) - Outward Taxable Supplies'],
                ['GST Rate (%)', 'Taxable Value (₹)', 'Central Tax (₹)', 'State/UT Tax (₹)', 'Integrated Tax (₹)', 'Cess (₹)'],
<%
    for (Double rate : sortedRates) {
        Map<String, Double> taxMap = outwardSupplies.get(rate);
        double taxable = taxMap.getOrDefault("taxable", 0.0);
        double cgst = taxMap.getOrDefault("cgst", 0.0);
        double sgst = taxMap.getOrDefault("sgst", 0.0);
        double igst = taxMap.getOrDefault("igst", 0.0);
%>
                ['<%= String.format("%.3f", rate) %>%', <%= taxable %>, <%= cgst %>, <%= sgst %>, <%= igst %>, 0],
<%
    }
%>
                ['Total', <%= totals.getOrDefault("taxable", 0.0) %>, <%= totals.getOrDefault("cgst", 0.0) %>, <%= totals.getOrDefault("sgst", 0.0) %>, <%= totals.getOrDefault("igst", 0.0) %>, 0],
                [],
                ['3.1(c) - Other Outward Supplies'],
                ['Description', 'Value (₹)'],
                ['Nil Rated Supplies', <%= nilRatedSupplies %>],
                ['Exempted Supplies', <%= exemptSupplies %>],
                ['Non-GST Supplies', <%= nonGSTSupplies %>],
                ['Total', <%= nilRatedSupplies + exemptSupplies + nonGSTSupplies %>],
            ];
            
            const ws1 = XLSX.utils.aoa_to_sheet(outwardData);
            XLSX.utils.book_append_sheet(wb, ws1, 'Outward Supplies');
            
            // Sheet 2: ITC and Tax Payable
            const itcData = [
                ['GSTR-3B Summary Report'],
                ['Period: ' + period],
                [],
                ['4 - Eligible Input Tax Credit (ITC)'],
                ['Details', 'Central Tax (₹)', 'State/UT Tax (₹)', 'Integrated Tax (₹)', 'Cess (₹)'],
                ['All other ITC (Purchases)', <%= itc.getOrDefault("cgst", 0.0) %>, <%= itc.getOrDefault("sgst", 0.0) %>, <%= itc.getOrDefault("igst", 0.0) %>, 0],
                ['Total ITC Available', <%= itc.getOrDefault("cgst", 0.0) %>, <%= itc.getOrDefault("sgst", 0.0) %>, <%= itc.getOrDefault("igst", 0.0) %>, 0],
                [],
                ['5 - Tax Payable'],
                ['Tax Type', 'Amount Payable (₹)'],
                ['CGST Payable', <%= taxPayable.getOrDefault("cgst", 0.0) %>],
                ['SGST Payable', <%= taxPayable.getOrDefault("sgst", 0.0) %>],
                ['IGST Payable', <%= taxPayable.getOrDefault("igst", 0.0) %>],
                ['TOTAL TAX PAYABLE', <%= taxPayable.getOrDefault("total", 0.0) %>],
            ];
            
            const ws2 = XLSX.utils.aoa_to_sheet(itcData);
            XLSX.utils.book_append_sheet(wb, ws2, 'ITC and Tax Payable');
            
            // Generate file name
            const fileName = 'GSTR3B_' + period.replace('/', '_') + '.xlsx';
            
            // Save file
            XLSX.writeFile(wb, fileName);
        }
    </script>
 
</body>
</html>
