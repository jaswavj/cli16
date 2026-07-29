<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
int billId = 0;
try {
    billId = Integer.parseInt(request.getParameter("billId"));
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/reports/delivered/page.jsp");
    return;
}

Vector billInfo = bill.getDeliveredBillInfo(billId);
if (billInfo == null || billInfo.isEmpty()) {
    response.sendRedirect(request.getContextPath() + "/reports/delivered/page.jsp");
    return;
}

String billNo = billInfo.elementAt(0).toString();
String cusName = billInfo.elementAt(1).toString();
String cusPhn = billInfo.elementAt(2).toString();
String description = billInfo.elementAt(3).toString();
String deliveryDate = billInfo.elementAt(4).toString();
String deliveredDate = billInfo.elementAt(5).toString();
String deliveryPlace = billInfo.elementAt(6).toString();
String deliveryPerson = billInfo.elementAt(7).toString();
String billDate = billInfo.elementAt(8).toString();
String billTime = billInfo.elementAt(9).toString();

Vector details = bill.getBillDetails(billId);
Vector totals = bill.getExtraDisc(billId);

double total = 0, prodDiscount = 0, extraDiscount = 0, payable = 0, paid = 0;
double cash = 0, bank = 0, balance = 0, currentBalance = 0;
if (totals != null && totals.size() >= 9) {
    total = Double.parseDouble(totals.elementAt(0).toString());
    prodDiscount = Double.parseDouble(totals.elementAt(1).toString());
    extraDiscount = Double.parseDouble(totals.elementAt(2).toString());
    payable = Double.parseDouble(totals.elementAt(3).toString());
    paid = Double.parseDouble(totals.elementAt(4).toString());
    cash = Double.parseDouble(totals.elementAt(5).toString());
    bank = Double.parseDouble(totals.elementAt(6).toString());
    balance = Double.parseDouble(totals.elementAt(7).toString());
    currentBalance = Double.parseDouble(totals.elementAt(8).toString());
}

String backUrl = request.getContextPath() + "/reports/delivered/page0.jsp?fromDate="
    + (fromDate != null ? fromDate : "") + "&toDate=" + (toDate != null ? toDate : "");
%>
<%!
private String formatDateDDMMYYYY(String dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty()) return "-";
    try {
        SimpleDateFormat in = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
        in.setLenient(false);
        Date parsed = in.parse(dateStr.trim());
        return new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH).format(parsed);
    } catch (Exception e) {
        return dateStr;
    }
}

private String formatTime12(String timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty()) return "-";
    String value = timeStr.trim();
    String[] patterns = {"HH:mm:ss", "H:mm:ss", "HH:mm", "H:mm", "hh:mm:ss a", "h:mm:ss a", "hh:mm a", "h:mm a"};
    for (int i = 0; i < patterns.length; i++) {
        try {
            SimpleDateFormat in = new SimpleDateFormat(patterns[i], Locale.ENGLISH);
            in.setLenient(false);
            Date parsed = in.parse(value);
            return new SimpleDateFormat("hh:mm a", Locale.ENGLISH).format(parsed);
        } catch (Exception ignore) {}
    }
    return value;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivered Bill - <%= billNo %></title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        @media print {
            .no-print { display: none !important; }
            body { padding: 0; }
        }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; }
        .info-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; }
        .info-box label { display: block; font-size: 0.75rem; color: #64748b; margin-bottom: 4px; text-transform: uppercase; }
        .info-box strong { font-size: 0.95rem; color: #0f172a; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container my-4" id="detailArea">
        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2 no-print">
            <h2 class="mb-0">Delivered Bill Detail</h2>
            <div>
                <a href="<%= backUrl %>" class="btn btn-secondary btn-sm">⬅ Back to Report</a>
                <button class="btn btn-primary btn-sm" onclick="printBill()">🖨 Print Bill</button>
                <button class="btn btn-outline-secondary btn-sm" onclick="window.print()">🖨 Print Detail</button>
            </div>
        </div>

        <div class="info-grid mb-4">
            <div class="info-box"><label>Bill No</label><strong><%= billNo %></strong></div>
            <div class="info-box"><label>Customer</label><strong><%= cusName %></strong></div>
            <div class="info-box"><label>Phone</label><strong><%= cusPhn %></strong></div>
            <div class="info-box"><label>Bill Date</label><strong><%= formatDateDDMMYYYY(billDate) %> <%= formatTime12(billTime) %></strong></div>
            <div class="info-box"><label>Delivery Date</label><strong><%= formatDateDDMMYYYY(deliveryDate) %></strong></div>
            <div class="info-box"><label>Delivered Date</label><strong><%= formatDateDDMMYYYY(deliveredDate) %></strong></div>
            <div class="info-box"><label>Delivery Place</label><strong><%= deliveryPlace.isEmpty() ? "-" : deliveryPlace %></strong></div>
            <div class="info-box"><label>Delivery Person</label><strong><%= deliveryPerson.isEmpty() ? "-" : deliveryPerson %></strong></div>
        </div>

        <% if (description != null && !description.trim().isEmpty()) { %>
        <div class="mb-3"><strong>Description:</strong> <%= description %></div>
        <% } %>

        <table class="table table-bordered table-sm">
            <thead class="table-light">
                <tr>
                    <th>#</th>
                    <th>Item</th>
                    <th>Qty</th>
                    <th class="text-end">Price</th>
                    <th class="text-end">Discount</th>
                    <th class="text-end">Total</th>
                </tr>
            </thead>
            <tbody>
            <%
            if (details != null) {
                for (int i = 0; i < details.size(); i++) {
                    Vector row = (Vector) details.elementAt(i);
            %>
                <tr>
                    <td><%= i + 1 %></td>
                    <td><%= row.elementAt(3) %></td>
                    <td><%= row.elementAt(4) %></td>
                    <td class="text-end"><%= row.elementAt(5) %></td>
                    <td class="text-end"><%= row.elementAt(6) %></td>
                    <td class="text-end"><%= row.elementAt(7) %></td>
                </tr>
            <% } } %>
            </tbody>
        </table>

        <div class="row mt-3">
            <div class="col-md-6 offset-md-6">
                <table class="table table-bordered table-sm">
                    <tr><th>Total</th><td class="text-end"><%= String.format("%.2f", total) %></td></tr>
                    <tr><th>Product Discount</th><td class="text-end"><%= String.format("%.2f", prodDiscount) %></td></tr>
                    <tr><th>Extra Discount</th><td class="text-end"><%= String.format("%.2f", extraDiscount) %></td></tr>
                    <tr><th>Payable</th><td class="text-end"><strong><%= String.format("%.2f", payable) %></strong></td></tr>
                    <tr><th>Paid</th><td class="text-end"><%= String.format("%.2f", paid) %></td></tr>
                    <tr><th>Cash</th><td class="text-end"><%= String.format("%.2f", cash) %></td></tr>
                    <tr><th>Bank</th><td class="text-end"><%= String.format("%.2f", bank) %></td></tr>
                    <tr><th>Balance</th><td class="text-end"><%= String.format("%.2f", balance) %></td></tr>
                </table>
            </div>
        </div>
    </div>

<script>
function printBill() {
    window.open('<%= contextPath %>/billing/print.jsp?billNo=<%= billNo %>', '_blank');
}
</script>
</body>
</html>
