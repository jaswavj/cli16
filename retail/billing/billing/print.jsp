<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.text.DecimalFormat"%>

<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="userBean" class="user.userBean" scope="page"/>
<%
String billNo = request.getParameter("billNo");
if(billNo == null || billNo.trim().isEmpty()){
    out.print("Error: Missing bill number");
    return;
}

double extradisc = bill.getExtraDisc(billNo);
String cusName=bill.getCusName(billNo);
String cusNumber=bill.getCusNumber(billNo);

// Get customer details from customers table
Vector customerDetails = bill.getCustomerDetailsByBillNo(billNo);
String customerName = "-";
String customerPhone = "-";
String customerAddress = "-";
String customerGSTIN = "-";

if (customerDetails != null && customerDetails.size() >= 4) {
    customerName = customerDetails.get(0) != null ? customerDetails.get(0).toString() : cusName;
    customerPhone = customerDetails.get(1) != null ? customerDetails.get(1).toString() : cusNumber;
    customerAddress = customerDetails.get(2) != null ? customerDetails.get(2).toString() : "-";
    customerGSTIN = customerDetails.get(3) != null ? customerDetails.get(3).toString() : "-";
} else {
    // Fallback to old fields if customer not found
    customerName = cusName;
    customerPhone = cusNumber;
}


double paid = bill.getPaidTotal(billNo);
String numPaid=bill.getNumPaid(paid);
double balance = bill.getbalanceTotal(billNo);
String billDate = bill.getBillDate(billNo);
Vector<Vector<Object>> billDetails = bill.getBillDetailsUsingNo(billNo);

// Get LR details
Vector lrDetails = bill.getLRDetails(billNo);
String lrNo = "";
String lrDate = "";
String lrName = "";

if (lrDetails != null && lrDetails.size() >= 3) {
    lrNo = lrDetails.get(0) != null ? lrDetails.get(0).toString() : "";
    lrDate = lrDetails.get(1) != null ? lrDetails.get(1).toString() : "";
    lrName = lrDetails.get(2) != null ? lrDetails.get(2).toString() : "";
}

// Fetch company details
Vector companyDetails = userBean.getCompanyDetails();
String companyName = "";
String companyAddress = "";
String companyGSTIN = "";
String companyBankDetails = "";

if (companyDetails != null && companyDetails.size() >= 4) {
    companyName = companyDetails.get(1) != null ? companyDetails.get(1).toString() : "";
    companyAddress = companyDetails.get(2) != null ? companyDetails.get(2).toString() : "";
    companyGSTIN = companyDetails.get(3) != null ? companyDetails.get(3).toString() : "";
    if (companyDetails.size() > 6) {
        companyBankDetails = companyDetails.get(6) != null ? companyDetails.get(6).toString() : "";
    }
}

DecimalFormat df = new DecimalFormat("0.00");

// GST Calculation variables
double totalAmount = 0;
double totalDiscount = 0;
double finalPaid = 0;
double totalItemAmount = 0;
double totalTaxableAmount = 0;
double totalCGST = 0;
double totalSGST = 0;
double totalIGST = 0;
double totalGSTAmount = 0;
double totalQty = 0;
double subTotalBeforeDiscount = 0;
double totalCourierCharge = 0;

// Map to store GST-wise totals
Map<Integer, Double> gstWiseTaxable = new HashMap<Integer, Double>();
Map<Integer, Double> gstWiseCGST = new HashMap<Integer, Double>();
Map<Integer, Double> gstWiseSGST = new HashMap<Integer, Double>();

for(Vector<Object> prod : billDetails){
    double itemTotal = Double.parseDouble(prod.get(4).toString());
    double itemDisc = Double.parseDouble(prod.get(3).toString());
    double itemPrice = Double.parseDouble(prod.get(2).toString());
    int gstPer = Integer.parseInt(prod.get(5).toString());
    double qty = Double.parseDouble(prod.get(1).toString());
    double itemCourier = (prod.size() > 10 && prod.get(10) != null) ? Double.parseDouble(prod.get(10).toString()) : 0;
    
    // Calculate taxable amount (amount before GST)
    double taxableAmount = itemTotal / (1 + (gstPer / 100.0));
    double gstAmount = itemTotal - taxableAmount;
    double cgst = gstAmount / 2;
    double sgst = gstAmount / 2;
    
    totalAmount += itemTotal;
    totalDiscount += itemDisc;
    totalItemAmount += itemPrice;
    totalTaxableAmount += taxableAmount;
    totalCGST += cgst;
    totalSGST += sgst;
    totalGSTAmount += gstAmount;
    totalQty += qty;
    totalCourierCharge += itemCourier;
    
    // Group by GST rate
    gstWiseTaxable.put(gstPer, gstWiseTaxable.getOrDefault(gstPer, 0.0) + taxableAmount);
    gstWiseCGST.put(gstPer, gstWiseCGST.getOrDefault(gstPer, 0.0) + cgst);
    gstWiseSGST.put(gstPer, gstWiseSGST.getOrDefault(gstPer, 0.0) + sgst);
}

// Calculate subtotal before discount (totalAmount is after item discounts, so add them back)
subTotalBeforeDiscount = totalAmount + totalDiscount;
    
finalPaid = totalAmount - extradisc;

// Fetch due collection records for this bill
int billId = bill.getBillId(billNo);
Vector<Vector<Object>> dueCollections = bill.getDuePaidList(billId);
Vector initialPayment = bill.getInitialBillPayment(billNo);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Tax Invoice</title>
    <style>
        :root {
            --theme-primary: #0b7a44;
            --theme-border: #1e5a3c;
            --theme-light: #ffffff;
        }
        @page { size: A4; margin: 5mm; }
        body {
            font-family: Arial, sans-serif;
            font-size: 13px;
            margin: 0;
            padding: 5px;
            color: #000;
        }
        .container {
            width: calc(100% - 20px);
            border: 2px solid var(--theme-border);
            margin: 0 auto;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            background: white;
        }
        
        /* Grid layout helpers */
        .row { display: flex; width: 100%; }
        .col-50 { width: 50%; }
        .col-40 { width: 40%; }
        .col-60 { width: 60%; }
        
        .border-bottom { border-bottom: 1px solid #000; }
        .border-right { border-right: 1px solid #000; }
        .border-top { border-top: 1px solid #000; }
        
        .p-5 { padding: 5px; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .font-bold { font-weight: bold; }
        
        /* Invoice header */
        .invoice-header {
            border-bottom: 2px solid var(--theme-border);
            background: #fff;
        }
        .invoice-header-top {
            background: var(--theme-primary);
            color: #fff;
            text-align: center;
            padding: 7px 16px;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 4px;
            text-transform: uppercase;
        }
        .invoice-header-main {
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
            column-gap: 0;
            padding: 12px 16px 14px;
        }
        .header-showcase {
            display: flex;
            align-items: center;
            gap: 7px;
        }
        .header-showcase-left {
            justify-content: flex-end;
            padding-right: 18px;
        }
        .header-showcase-right {
            justify-content: flex-start;
            padding-left: 18px;
        }
        .header-brand {
            text-align: center;
            padding: 4px 22px;
            border-left: 1px solid rgba(30, 90, 60, 0.35);
            border-right: 1px solid rgba(30, 90, 60, 0.35);
            min-width: 200px;
        }
        .header-brand img {
            max-width: 220px;
            max-height: 108px;
            width: auto;
            height: auto;
            object-fit: contain;
            display: block;
            margin: 0 auto;
        }
        .header-frame {
            flex: 0 0 auto;
            width: 56px;
            height: 56px;
            padding: 2px;
            background: #fff;
            border: 1.5px solid var(--theme-border);
            border-radius: 4px;
            box-shadow: 0 1px 4px rgba(11, 122, 68, 0.12);
        }
        .header-frame img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 2px;
            display: block;
        }
        .invoice-header-bottom {
            height: 3px;
            background: linear-gradient(
                90deg,
                transparent 0%,
                var(--theme-primary) 15%,
                var(--theme-primary) 85%,
                transparent 100%
            );
        }
        
        /* Section Headers */
        .purple-header {
            background: var(--theme-light);
            color: #000;
            padding: 6px 10px;
            font-weight: bold;
            border-bottom: 1px solid var(--theme-border);
            border-right: 1px solid var(--theme-border);
            font-size: 13px;
            letter-spacing: 0.5px;
        }
        
        /* Bill To & Invoice Details */
        .bill-info-row {
            display: flex;
            border-bottom: 2px solid var(--theme-border);
        }
        .bill-to-box {
            width: 50%;
            border-right: 2px solid var(--theme-border);
        }
        .invoice-details-box {
            width: 50%;
        }
        .info-content {
            padding: 10px;
            min-height: 50px;
            font-size: 13px;
            line-height: 1.6;
        }
        
        /* Main Table */
        .items-table {
            width: 100%;
            border-collapse: collapse;
        }
        .items-table th {
            background-color: var(--theme-light);
            color: #000;
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-top: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 5px 4px;
            font-size: 14px;
            text-align: center;
            font-weight: bold;
        }
        .items-table th:first-child {
            border-left: 1px solid #000;
        }
        .items-table th:last-child {
            border-right: 1px solid #000;
        }
        .items-table td {
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-top: none;
            border-bottom: none;
            padding: 6px 6px;
            font-size: 14px;
            vertical-align: middle;
            line-height: 1.3;
        }
        .items-table tbody {
            display: table-row-group;
        }
        .items-table tbody tr:first-child td {
            border-top: 1px solid #000;
        }
        .empty-filler-row td {
            border-bottom: none !important;
            height: 18px;
            padding: 2px 6px;
            line-height: 1;
        }
        
        /* Total Row */
        .total-row {
            font-weight: bold;
            background-color: transparent;
        }
        .total-row td {
            border-top: 1px solid #000 !important;
            border-bottom: 1px solid #000 !important;
            font-size: 14px;
            padding: 6px 6px;
        }
        
        /* Tax & Amounts Section */
        .tax-amounts-row {
            display: flex;
            border-bottom: 1px solid var(--theme-border);
        }
        .tax-box {
            width: 50%;
            border-right: 1px solid var(--theme-border);
        }
        .amounts-box {
            width: 50%;
        }
        
        .tax-row {
            display: flex;
            justify-content: space-between;
            padding: 2px 5px;
            border-bottom: 1px solid #ccc;
        }
        .tax-row:last-child { border-bottom: none; }
        
        .amount-row {
            display: flex;
            justify-content: space-between;
            padding: 6px 10px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 13px;
        }
        .amount-row.total {
            font-weight: bold;
            border-bottom: none;
            font-size: 15px;
            background: var(--theme-light);
            padding: 8px 10px;
        }
        
        /* Footer Info */
        .footer-row {
            display: flex;
            border-bottom: 1px solid var(--theme-border);
        }
        .payment-summary-section {
            border-bottom: 1px solid var(--theme-border);
            padding: 6px 8px;
        }
        .payment-summary-section .ps-title {
            font-weight: bold;
            font-size: 13px;
            margin-bottom: 4px;
            background: var(--theme-light);
            padding: 4px 8px;
            border-bottom: 1px solid var(--theme-border);
        }
        .payment-summary-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }
        .payment-summary-table th {
            background: #ffffff;
            border: 1px solid #ccc;
            padding: 3px 6px;
            text-align: center;
        }
        .payment-summary-table td {
            border: 1px solid #ccc;
            padding: 3px 6px;
        }
        .words-box {
            width: 50%;
            border-right: 1px solid var(--theme-border);
        }
        .rightBorder {
            border-right: 1px solid var(--theme-border);
        }
        .words-boxWord {
            width: 100%;
            border-bottom: 1px solid var(--theme-border);
        }
        .desc-box {
            width: 50%;
        }
        .footer-content {
            padding: 5px;
            text-align: center;
            min-height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 13px;
            font-weight: 600;
        }
        .amount-words-content {
            border-bottom: 1px solid var(--theme-border);
        }
        
        
        /* Terms & Signature */
        .terms-sign-row {
            display: flex;
        }
        .terms-box {
            width: 50%;
            border-right: 1px solid var(--theme-border);
            font-size: 11px;
        }
        .sign-box {
            width: 50%;
            padding: 8px;
            text-align: right;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 60px;
        }
        .sign-box .text-center {
            font-weight: 600;
            color: var(--theme-primary);
            padding-top: 10px;
            display: inline-block;
            width: 200px;
            margin-left: auto;
        }
        
        ul.terms-list {
            padding-left: 15px;
            margin: 5px 0;
        }
        ul.terms-list li {
            margin-bottom: 2px;
        }
        
        /* Bank Details with QR Code */
        .bank-qr-container {
            display: flex;
            align-items: flex-start;
            padding: 5px;
        }
        .bank-details-text {
            flex: 1;
            line-height: 1.6;
        }
        .qr-code-box {
            margin-left: auto;
            padding-left: 15px;
        }
        .qr-code-box img {
            width: 100px;
            height: 100px;
            border: 2px solid var(--theme-primary);
            border-radius: 8px;
            padding: 3px;
        }
        
        /* Print/Cancel Buttons */
        .print-controls {
            position: fixed;
            top: 10px;
            right: 10px;
            z-index: 1000;
            display: flex;
            gap: 10px;
        }
        .btn {
            padding: 10px 20px;
            font-size: 16px;
            font-weight: bold;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn-print {
            background-color: #4CAF50;
            color: white;
        }
        .btn-print:hover {
            background-color: #45a049;
        }
        .btn-cancel {
            background-color: #f44336;
            color: white;
        }
        .btn-cancel:hover {
            background-color: #da190b;
        }
        
        @media print {
            .print-controls {
                display: none !important;
            }
            .invoice-header-top {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
        }
    </style>
    <script>
        window.onload = function() {
            // Direct print on page load
            window.print();
        };
        
        // Close window after print dialog is closed (either printed or cancelled)
        window.onafterprint = function() {
            window.close();
        };
        
        function printInvoice() {
            window.print();
        }
        
        function cancelPrint() {
            window.close();
        }
    </script>
</head>
<body>

<!-- Print/Cancel Controls -->
<div class="print-controls">
    <button class="btn btn-print" onclick="printInvoice()">🖨️ Print</button>
    <button class="btn btn-cancel" onclick="cancelPrint()">❌ Cancel</button>
</div>



<div class="container">
    <header class="invoice-header">
        <div class="invoice-header-top">Invoice</div>
        <div class="invoice-header-main">
            <div class="header-showcase header-showcase-left">
                <div class="header-frame"><img src="img/1.jpeg" alt=""></div>
                <div class="header-frame"><img src="img/2.jpeg" alt=""></div>
                <div class="header-frame"><img src="img/3.jpeg" alt=""></div>
            </div>
            <div class="header-brand">
                <img src="logo.png" alt="Company Logo">
            </div>
            <div class="header-showcase header-showcase-right">
                <div class="header-frame"><img src="img/4.jpeg" alt=""></div>
                <div class="header-frame"><img src="img/5.jpeg" alt=""></div>
                <div class="header-frame"><img src="img/6.jpeg" alt=""></div>
            </div>
        </div>
        <div class="invoice-header-bottom" aria-hidden="true"></div>
    </header>

    <!-- Bill To & Invoice Details -->
    <div class="bill-info-row">
        <div class="bill-to-box">
            <div class="purple-header">Bill To</div>
            <div class="info-content">
                <div class="font-bold"><%= customerName %></div>
                <% if(customerPhone != null && !customerPhone.equals("-") && !customerPhone.trim().isEmpty()) { %>
                <div>Ph: <%= customerPhone %></div>
                <% } %>
                <% if(customerAddress != null && !customerAddress.equals("-") && !customerAddress.trim().isEmpty()) { %>
                <div><%= customerAddress %></div>
                <% } %>
                <% if(customerGSTIN != null && !customerGSTIN.equals("-") && !customerGSTIN.trim().isEmpty()) { %>
                <div>GSTIN: <%= customerGSTIN %></div>
                <% } %>
            </div>
        </div>
        <div class="invoice-details-box">
            <div class="purple-header text-right">Invoice Details</div>
            <div class="info-content text-right">
                <div>Invoice No.: <%= billNo %></div>
                <div>Date: <%= billDate %></div>
                <div>Place of Supply: Tamil Nadu</div>
                <% if (lrNo != null && !lrNo.trim().isEmpty()) { %>
                <div>LR No.: <%= lrNo %></div>
                <% } %>
                <% if (lrDate != null && !lrDate.trim().isEmpty()) { %>
                <div>LR Date: <%= lrDate %></div>
                <% } %>
                <% if (lrName != null && !lrName.trim().isEmpty()) { %>
                <div>LR Name: <%= lrName %></div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Items Table -->
    <table class="items-table">
        <thead>
            <tr>
                <th style="width: 5%;">S.No</th>
                <th style="width: 48%;">Item name</th>
                <th style="width: 12%;">price/Unit</th>
                <th style="width: 10%;">Qty</th>
                <th style="width: 10%;">Courier</th>
                <th style="width: 15%;">Amount</th>
            </tr>
        </thead>
        <tbody>
            <%
            int count = 1;
            for(Vector<Object> prod : billDetails){
                double itemTotal = Double.parseDouble(prod.get(4).toString());
                double itemPrice = Double.parseDouble(prod.get(2).toString());
                double qty = Double.parseDouble(prod.get(1).toString());
                double itemCourier = (prod.size() > 10 && prod.get(10) != null) ? Double.parseDouble(prod.get(10).toString()) : 0;
                
                String category = "";
                if(prod.size() > 6 && prod.get(6) != null){
                    category = prod.get(6).toString();
                }
                String productName = prod.get(0).toString();
                String displayName = (category.isEmpty()) ? productName : category + " - " + productName;
                
                String unitName = "";
                if(prod.size() > 8 && prod.get(8) != null){
                    unitName = prod.get(8).toString();
                }
            %>
            <tr class="item-row">
                <td class="text-center" style="width: 5%;"><%= count++ %></td>
                <td style="width: 48%;">
                    <div class="font-bold"><%= displayName %></div>
                </td>
                <td class="text-right" style="width: 12%;"><%= df.format(itemPrice) %></td>
                <td class="text-center" style="width: 10%;"><%= qty %><% if(unitName != null && !unitName.trim().isEmpty()) { %> <%= unitName %><% } %></td>
                <td class="text-right" style="width: 10%;"><%= df.format(itemCourier) %></td>
                <td class="text-right" style="width: 15%;"><%= df.format(itemTotal) %></td>
            </tr>
            <% } %>
            
            <!-- Add empty filler rows to maintain fixed height -->
            <% 
            int minRows = 6; // Minimum rows to display
            int actualRows = billDetails.size();
            int emptyRowsNeeded = Math.max(0, minRows - actualRows);
            for(int i = 0; i < emptyRowsNeeded; i++) { 
            %>
            <tr class="empty-filler-row">
                <td class="text-center" style="width: 5%;">&nbsp;</td>
                <td style="width: 48%;">&nbsp;</td>
                <td class="text-right" style="width: 12%;">&nbsp;</td>
                <td class="text-center" style="width: 10%;">&nbsp;</td>
                <td class="text-right" style="width: 10%;">&nbsp;</td>
                <td class="text-right" style="width: 15%;">&nbsp;</td>
            </tr>
            <% } %>
        </tbody>
        <tfoot>
            <tr class="total-row">
                <td colspan="3" class="text-right" style="width: 65%;">Total</td>
                <td class="text-center" style="width: 10%;"><%= totalQty %></td>
                <td class="text-right" style="width: 10%;"><%= df.format(totalCourierCharge) %></td>
                <td class="text-right" style="width: 15%;"> <%= df.format(totalAmount) %></td>
            </tr>
        </tfoot>
    </table>

    <!-- Tax & Amounts -->
    <div class="tax-amounts-row">
        <div class="tax-box">
            <%
            boolean hasInitialPay = initialPayment != null && initialPayment.size() >= 5;
            double ipCash = hasInitialPay && initialPayment.get(1) != null ? Double.parseDouble(initialPayment.get(1).toString()) : 0;
            double ipBank = hasInitialPay && initialPayment.get(2) != null ? Double.parseDouble(initialPayment.get(2).toString()) : 0;
            boolean showSummary = hasInitialPay || (dueCollections != null && dueCollections.size() > 0);
            %>
            <% if (showSummary) { %>
            <div class="payment-summary-section">
                <div class="ps-title">Payment Summary</div>
                <table class="payment-summary-table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Mode</th>
                            <th>Method</th>
                            <th style="text-align:right;">Paid (₹)</th>
                            <th style="text-align:right;">Balance (₹)</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (hasInitialPay) {
                        String ipDate    = initialPayment.get(0) != null ? initialPayment.get(0).toString() : "-";
                        String ipPayType = initialPayment.get(3) != null ? initialPayment.get(3).toString() : "-";
                        String ipBalance = initialPayment.get(4) != null ? initialPayment.get(4).toString() : "0";
                        if (ipCash > 0) { %>
                    <tr>
                        <td class="text-center"><%= ipDate %></td>
                        <td class="text-center">Cash</td>
                        <td class="text-center">-</td>
                        <td class="text-right"><%= df.format(ipCash) %></td>
                        <td class="text-right"><%= df.format(Double.parseDouble(ipBalance)) %></td>
                    </tr>
                    <% } if (ipBank > 0) { %>
                    <tr>
                        <td class="text-center"><%= ipDate %></td>
                        <td class="text-center">Bank</td>
                        <td class="text-center"><%= ipPayType %></td>
                        <td class="text-right"><%= df.format(ipBank) %></td>
                        <td class="text-right"><%= df.format(Double.parseDouble(ipBalance)) %></td>
                    </tr>
                    <% } if (ipCash == 0 && ipBank == 0) { %>
                    <tr>
                        <td class="text-center"><%= ipDate %></td>
                        <td class="text-center">-</td>
                        <td class="text-center">-</td>
                        <td class="text-right">0.00</td>
                        <td class="text-right"><%= df.format(Double.parseDouble(ipBalance)) %></td>
                    </tr>
                    <% } } %>
                    <%
                    if (dueCollections != null) {
                        for (Vector<Object> dc : dueCollections) {
                            String dcDate      = dc.get(6) != null ? dc.get(6).toString() : "-";
                            String dcPaid      = dc.get(2) != null ? dc.get(2).toString() : "0";
                            String dcBalance   = dc.get(3) != null ? dc.get(3).toString() : "0";
                            String dcMode      = dc.get(4) != null ? dc.get(4).toString() : "-";
                            String dcBank      = dc.get(5) != null ? dc.get(5).toString() : "-";
                    %>
                    <tr>
                        <td class="text-center"><%= dcDate %></td>
                        <td class="text-center"><%= dcMode %></td>
                        <td class="text-center"><%= dcBank %></td>
                        <td class="text-right"><%= df.format(Double.parseDouble(dcPaid)) %></td>
                        <td class="text-right"><%= df.format(Double.parseDouble(dcBalance)) %></td>
                    </tr>
                    <% 
                        }
                    }
                    %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
        <div class="amounts-box">
            <div class="purple-header">Amounts</div>
            <div class="amount-row bg-light-purple">
                <div>Sub Total</div>
                <div>₹ <%= df.format(subTotalBeforeDiscount) %></div>
            </div>
            <% if (totalDiscount > 0) { %>
            <div class="amount-row">
                <div>Item Discount</div>
                <div>- ₹ <%= df.format(totalDiscount) %></div>
            </div>
            <% } %>
            <% if (extradisc > 0) { %>
            <div class="amount-row">
                <div>Extra Discount</div>
                <div>- ₹ <%= df.format(extradisc) %></div>
            </div>
            <% } %>
            <% if (totalCourierCharge > 0) { %>
            <div class="amount-row">
                <div>Courier Charge</div>
                <div>₹ <%= df.format(totalCourierCharge) %></div>
            </div>
            <% } %>
            <%
            double dueTotalPaid = 0;
            double currentBalance = balance;
            if (dueCollections != null) {
                for (Vector<Object> dc : dueCollections) {
                    if (dc.get(2) != null) dueTotalPaid += Double.parseDouble(dc.get(2).toString());
                }
                if (!dueCollections.isEmpty()) {
                    Vector<Object> lastDc = dueCollections.get(dueCollections.size() - 1);
                    if (lastDc.get(3) != null) currentBalance = Double.parseDouble(lastDc.get(3).toString());
                }
            }
            double totalPaidAll = paid + dueTotalPaid;
            %>
            <div class="amount-row total">
                <div>Total</div>
                <div>₹ <%= df.format(finalPaid) %></div>
            </div>
            <div class="amount-row">
                <div>Paid</div>
                <div>₹ <%= df.format(totalPaidAll) %></div>
            </div>
            <div class="amount-row">
                <div>Balance</div>
                <div>₹ <%= df.format(currentBalance) %></div>
            </div>
        </div>
    </div>

    <!-- Words & Description -->
    <div class="footer-row" style="border-bottom: none;">
        <div class="words-boxWord">
            <div class="footer-content amount-words-content">
                Amount In Words : <%= numPaid %> 
            </div>
        </div>
        
    </div>
    <div class="footer-row" style="border-bottom: none;">
        
        <div class="desc-box">
            <div class="purple-header">Terms & Conditions</div>
            <div  style="text-align: left; align-items: flex-start;" class="rightBorder">
                <ul class="terms-list">
                    <li>Orders once confirmed cannot be cancelled or refunded.</li>
                    <li>Products will be delivered within 10 to 15 working days from the date of order confirmation.</li>
                    <li>Delivery time may vary based on location and courier service availability.</li>
                    <li>Urgent orders are also accepted based on stock and delivery feasibility.</li>
                    <li>International / Abroad shipping is available with additional shipping charges.</li>
                    <li>Customers must record a continuous unboxing video while opening the courier package.</li>
                    <li>Damage claims without proper unboxing video proof will not be accepted.</li>
                    <li>Any physical damage or missing item issues must be reported on the same day of delivery.</li>
                    <li>Shipping charges are non-refundable under any circumstances.</li>
                </ul>
            </div>
        </div>
        <div class="words-box" style="border-right: none;">
            
            <% if (companyBankDetails != null && !companyBankDetails.trim().isEmpty()) { %>
            <div class="purple-header" style="border-right: none;">Bank Details for Payment</div>
            <div class="footer-content" style="text-align: left; align-items: flex-start; justify-content: flex-start; padding: 0;">
                <div class="bank-qr-container">
                    <div class="bank-details-text">
                    <% 
                    // Split bank details by newlines and display each line
                    String[] bankLines = companyBankDetails.split("\\r?\\n");
                    for (String line : bankLines) {
                        if (line != null && !line.trim().isEmpty()) {
                    %>
                        <div><%= line.trim() %></div>
                    <% 
                        }
                    } 
                    %>
                    </div>
                    <div class="qr-code-box">
                        <img src="qrcode.jpeg" alt="Payment QR Code" onerror="this.style.display='none'">
                    </div>
                </div>
            </div>
            <% } %>          
        </div>
    </div>



</div>

<div style="
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 8px;
    margin: 3px 0 0 0;
    padding: 4px 6px;
    border-top: 1px solid rgba(11,122,68,0.2);
    opacity: 0.55;
">
    
</div>

</body>
</html>
