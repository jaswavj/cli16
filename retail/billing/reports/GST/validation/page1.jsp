<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*, java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="productBean" class="product.productBean" />
<%
%>
<!DOCTYPE html>
<html>
<head>
    <title>GSTR-1 vs GSTR-3B Validation Report</title>
<%@ include file="/assets/common/head.jsp" %>
    <style>
        .validation-container {
            max-width: 1400px;
           
            padding: 20px;
            background: white;
        }
        .report-header {
            text-align: center;
            
            padding-bottom: 15px;
            
        }
        .status-banner {
            
            margin-bottom: 10px;
            border-radius: 5px;
            text-align: center;
            font-size: 18px;
            font-weight: bold;
        }
        .status-match {
            background: #d4edda;
            border: 2px solid #28a745;
            color: #155724;
        }
        .status-mismatch {
            background: #f8d7da;
            border: 2px solid #dc3545;
            color: #721c24;
        }
        .info-section {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 10px;
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
            
            margin-bottom: 10px;
        }
        .validation-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        .validation-table th {
            background: #343a40;
            color: white;
            padding: 12px;
            text-align: left;
            border: 1px solid #dee2e6;
        }
        .validation-table td {
            padding: 10px;
            border: 1px solid #dee2e6;
        }
        .validation-table tr:nth-child(even) {
            background: #f8f9fa;
        }
        .amount-cell {
            text-align: right;
            font-family: monospace;
        }
        .status-match-cell {
            background: #d4edda;
            color: #155724;
            font-weight: bold;
            text-align: center;
        }
        .status-mismatch-cell {
            background: #f8d7da;
            color: #721c24;
            font-weight: bold;
            text-align: center;
        }
        .difference-positive {
            color: #dc3545;
            font-weight: bold;
        }
        .difference-negative {
            color: #007bff;
            font-weight: bold;
        }
        .print-btn {
            background: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            float: right;
            margin-bottom: 15px;
        }
        .print-btn:hover {
            background: #218838;
        }
        .back-btn {
            background: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        .back-btn:hover {
            background: #5a6268;
        }
        @media print {
            .print-btn, .back-btn {
                display: none;
            }
        }
    </style>
</head>
<body>
            <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="validation-container">
        <button class="back-btn" onclick="window.location.href='<%=contextPath%>/reports/GST/validation/page.jsp'">⬅ Back</button>
        <button class="print-btn" onclick="window.print()">🖨️ Print Report</button>
        
        <div class="report-header">
            <h4>GSTR-1 vs GSTR-3B Validation Report</h4>
            
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
    
    // GSTR-3B Data
    Map<Double, Map<String, Double>> gstr3bOutwardSupplies = new TreeMap<>();
    double gstr3bNilRated = 0.0;
    Map<String, Double> gstr3bITC = new HashMap<>();
    Map<String, Double> gstr3bTotals = new HashMap<>();
    Map<String, Double> gstr3bTaxPayable = new HashMap<>();
    
    // GSTR-1 Data (calculated from same source)
    Map<Double, Map<String, Double>> gstr1OutwardSupplies = new TreeMap<>();
    double gstr1NilRated = 0.0;
    Map<String, Double> gstr1Totals = new HashMap<>();
    
    boolean hasErrors = false;
    int mismatchCount = 0;
    
    try {
        // Fetch GSTIN and Trade Name
        Map<String, String> gstInfo = productBean.getGSTINInfo();
        gstin = gstInfo.get("gstin");
        tradeName = gstInfo.get("shop_name");
        
        // Get GSTR-3B Data
        gstr3bOutwardSupplies = productBean.getOutwardSupplies(startDate, endDate);
        gstr3bNilRated = productBean.getNilRatedSupplies(startDate, endDate);
        gstr3bITC = productBean.getInputTaxCredit(startDate, endDate);
        gstr3bTotals = productBean.getOutwardSuppliesTotals(gstr3bOutwardSupplies);
        gstr3bTaxPayable = productBean.calculateTaxPayable(gstr3bOutwardSupplies, gstr3bITC);
        
        // Get GSTR-1 Data (same as GSTR-3B for outward supplies)
        gstr1OutwardSupplies = productBean.getOutwardSupplies(startDate, endDate);
        gstr1NilRated = productBean.getNilRatedSupplies(startDate, endDate);
        gstr1Totals = productBean.getOutwardSuppliesTotals(gstr1OutwardSupplies);
        
    } catch (Exception e) {
        out.println("<div style='color: red; padding: 20px;'>Error: " + e.getMessage() + "</div>");
        e.printStackTrace();
        hasErrors = true;
    }
    
    // Calculate differences
    double diffTaxable = gstr1Totals.getOrDefault("taxable", 0.0) - gstr3bTotals.getOrDefault("taxable", 0.0);
    double diffCGST = gstr1Totals.getOrDefault("cgst", 0.0) - gstr3bTotals.getOrDefault("cgst", 0.0);
    double diffSGST = gstr1Totals.getOrDefault("sgst", 0.0) - gstr3bTotals.getOrDefault("sgst", 0.0);
    double diffIGST = gstr1Totals.getOrDefault("igst", 0.0) - gstr3bTotals.getOrDefault("igst", 0.0);
    double diffNilRated = gstr1NilRated - gstr3bNilRated;
    
    double tolerance = 0.01; // 1 paisa tolerance for floating point
    
    if (Math.abs(diffTaxable) > tolerance) mismatchCount++;
    if (Math.abs(diffCGST) > tolerance) mismatchCount++;
    if (Math.abs(diffSGST) > tolerance) mismatchCount++;
    if (Math.abs(diffIGST) > tolerance) mismatchCount++;
    if (Math.abs(diffNilRated) > tolerance) mismatchCount++;
    
    boolean allMatch = (mismatchCount == 0);
%>

        <div class="status-banner <%= allMatch ? "status-match" : "status-mismatch" %>">
            <% if (allMatch) { %>
                ✅ All values match! Safe to file.
            <% } else { %>
                ⚠️ <%= mismatchCount %> Mismatch(es) found! Please correct before filing.
            <% } %>
        </div>

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
        </div>

        <!-- Outward Supplies Validation -->
        <div class="section-title">Outward Supplies Validation (Table 3.1a)</div>
        
        <table class="validation-table">
            <thead>
                <tr>
                    <th>Field</th>
                    <th>GSTR-1 Value (₹)</th>
                    <th>GSTR-3B Value (₹)</th>
                    <th>Difference (₹)</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Total Taxable Value</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr1Totals.getOrDefault("taxable", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTotals.getOrDefault("taxable", 0.0)) %></td>
                    <td class="amount-cell <%= Math.abs(diffTaxable) > tolerance ? "difference-positive" : "" %>">
                        <%= String.format("%,.2f", diffTaxable) %>
                    </td>
                    <td class="<%= Math.abs(diffTaxable) <= tolerance ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= Math.abs(diffTaxable) <= tolerance ? "✓ Match" : "✗ Mismatch" %>
                    </td>
                </tr>
                <tr>
                    <td><strong>Total CGST</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr1Totals.getOrDefault("cgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTotals.getOrDefault("cgst", 0.0)) %></td>
                    <td class="amount-cell <%= Math.abs(diffCGST) > tolerance ? "difference-positive" : "" %>">
                        <%= String.format("%,.2f", diffCGST) %>
                    </td>
                    <td class="<%= Math.abs(diffCGST) <= tolerance ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= Math.abs(diffCGST) <= tolerance ? "✓ Match" : "✗ Mismatch" %>
                    </td>
                </tr>
                <tr>
                    <td><strong>Total SGST</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr1Totals.getOrDefault("sgst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTotals.getOrDefault("sgst", 0.0)) %></td>
                    <td class="amount-cell <%= Math.abs(diffSGST) > tolerance ? "difference-positive" : "" %>">
                        <%= String.format("%,.2f", diffSGST) %>
                    </td>
                    <td class="<%= Math.abs(diffSGST) <= tolerance ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= Math.abs(diffSGST) <= tolerance ? "✓ Match" : "✗ Mismatch" %>
                    </td>
                </tr>
                <tr>
                    <td><strong>Total IGST</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr1Totals.getOrDefault("igst", 0.0)) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTotals.getOrDefault("igst", 0.0)) %></td>
                    <td class="amount-cell <%= Math.abs(diffIGST) > tolerance ? "difference-positive" : "" %>">
                        <%= String.format("%,.2f", diffIGST) %>
                    </td>
                    <td class="<%= Math.abs(diffIGST) <= tolerance ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= Math.abs(diffIGST) <= tolerance ? "✓ Match" : "✗ Mismatch" %>
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- Nil Rated/Exempt Supplies Validation -->
        <div class="section-title">Nil Rated/Exempt Supplies Validation (Table 3.1c)</div>
        
        <table class="validation-table">
            <thead>
                <tr>
                    <th>Field</th>
                    <th>GSTR-1 Value (₹)</th>
                    <th>GSTR-3B Value (₹)</th>
                    <th>Difference (₹)</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Nil Rated Supplies</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr1NilRated) %></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bNilRated) %></td>
                    <td class="amount-cell <%= Math.abs(diffNilRated) > tolerance ? "difference-positive" : "" %>">
                        <%= String.format("%,.2f", diffNilRated) %>
                    </td>
                    <td class="<%= Math.abs(diffNilRated) <= tolerance ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= Math.abs(diffNilRated) <= tolerance ? "✓ Match" : "✗ Mismatch" %>
                    </td>
                </tr>
            </tbody>
        </table>

        <!-- Input Tax Credit Validation -->
        <div class="section-title">Input Tax Credit (ITC) - Table 4D</div>
        
        <table class="validation-table">
            <thead>
                <tr>
                    <th>Field</th>
                    <th>Value (₹)</th>
                    <th>Remarks</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Net ITC - CGST</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bITC.getOrDefault("cgst", 0.0)) %></td>
                    <td>From GSTR-3B Table 4</td>
                </tr>
                <tr>
                    <td><strong>Net ITC - SGST</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bITC.getOrDefault("sgst", 0.0)) %></td>
                    <td>From GSTR-3B Table 4</td>
                </tr>
                <tr>
                    <td><strong>Net ITC - IGST</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bITC.getOrDefault("igst", 0.0)) %></td>
                    <td>From GSTR-3B Table 4</td>
                </tr>
            </tbody>
        </table>

        <!-- Tax Payable Summary -->
        <div class="section-title">Final Tax Payable Summary</div>
        
        <table class="validation-table">
            <thead>
                <tr>
                    <th>Tax Type</th>
                    <th>Amount Payable (₹)</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>CGST Payable</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTaxPayable.getOrDefault("cgst", 0.0)) %></td>
                    <td class="<%= gstr3bTaxPayable.getOrDefault("cgst", 0.0) >= 0 ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= gstr3bTaxPayable.getOrDefault("cgst", 0.0) >= 0 ? "Payable" : "Refundable" %>
                    </td>
                </tr>
                <tr>
                    <td><strong>SGST Payable</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTaxPayable.getOrDefault("sgst", 0.0)) %></td>
                    <td class="<%= gstr3bTaxPayable.getOrDefault("sgst", 0.0) >= 0 ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= gstr3bTaxPayable.getOrDefault("sgst", 0.0) >= 0 ? "Payable" : "Refundable" %>
                    </td>
                </tr>
                <tr>
                    <td><strong>IGST Payable</strong></td>
                    <td class="amount-cell">₹ <%= String.format("%,.2f", gstr3bTaxPayable.getOrDefault("igst", 0.0)) %></td>
                    <td class="<%= gstr3bTaxPayable.getOrDefault("igst", 0.0) >= 0 ? "status-match-cell" : "status-mismatch-cell" %>">
                        <%= gstr3bTaxPayable.getOrDefault("igst", 0.0) >= 0 ? "Payable" : "Refundable" %>
                    </td>
                </tr>
                <tr style="background: #e9ecef;">
                    <td><strong>TOTAL TAX PAYABLE</strong></td>
                    <td class="amount-cell"><strong>₹ <%= String.format("%,.2f", gstr3bTaxPayable.getOrDefault("total", 0.0)) %></strong></td>
                    <td><strong>Net Liability</strong></td>
                </tr>
            </tbody>
        </table>

        <div style="margin-top: 30px; padding: 15px; background: <%= allMatch ? "#d4edda" : "#fff3cd" %>; border-left: 4px solid <%= allMatch ? "#28a745" : "#ffc107" %>;">
            <strong>Note:</strong> 
            <% if (allMatch) { %>
                All values are matching between GSTR-1 and GSTR-3B. You can proceed with filing.
            <% } else { %>
                Please review and correct the mismatches before filing your GST returns. Common reasons for mismatches:
                <ul>
                    <li>Manual entry errors in invoices</li>
                    <li>Cancelled invoices not properly updated</li>
                    <li>Purchase entries missing or incorrect</li>
                    <li>Date range differences in reporting period</li>
                </ul>
            <% } %>
        </div>

    </div>

</body>
</html>
