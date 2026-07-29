<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String contextPath = request.getContextPath();
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
if (fromDate == null || fromDate.trim().isEmpty() || toDate == null || toDate.trim().isEmpty()) {
    response.sendRedirect(contextPath + "/reports/delivered/page.jsp");
    return;
}
%>
<%!
private String formatDateDDMMYYYY(String dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty()) return "-";
    String value = dateStr.trim();
    String[] patterns = {
        "yyyy-MM-dd", "yyyy-M-d", "yyyy/MM/dd", "yyyy/M/d",
        "dd-MM-yyyy", "d-M-yyyy", "dd/MM/yyyy", "d/M/yyyy",
        "dd-MMM-yyyy", "d-MMM-yyyy"
    };
    for (int i = 0; i < patterns.length; i++) {
        try {
            SimpleDateFormat in = new SimpleDateFormat(patterns[i], Locale.ENGLISH);
            in.setLenient(false);
            Date parsed = in.parse(value);
            return new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH).format(parsed);
        } catch (Exception ignore) {}
    }
    return dateStr;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delivered Report</title>
    <jsp:include page="/assets/common/head.jsp" />

<style>
    .sales-report-wrap > p,
    .sales-report-wrap > p strong {
        font-size: 1.05rem;
    }

    .sales-report-wrap .btn,
    .sales-report-wrap .btn.btn-sm {
        font-size: 0.95rem;
    }

    .sales-report-wrap #printTable {
        font-size: 1rem !important;
        table-layout: fixed;
        width: 100%;
    }

    .sales-report-wrap #printTable th,
    .sales-report-wrap #printTable td {
        padding: 0.28rem 0.35rem !important;
        vertical-align: middle;
    }

    @media screen {
        .sales-report-wrap #printTable col.col-w-sno { width: 3%; }
        .sales-report-wrap #printTable col.col-w-bill { width: 6%; }
        .sales-report-wrap #printTable col.col-w-name,
        .sales-report-wrap #printTable col.col-w-item { width: 14%; }
        .sales-report-wrap #printTable col.col-w-amt { width: 7%; }
        .sales-report-wrap #printTable col.col-w-date { width: 8%; }
        .sales-report-wrap #printTable col.col-w-text { width: 9%; }

        .sales-report-wrap #printTable th {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .sales-report-wrap #printTable th:nth-child(1),
        .sales-report-wrap #printTable td:nth-child(1) { text-align: center; padding-inline: 0.2rem !important; }
        .sales-report-wrap #printTable th:nth-child(6),
        .sales-report-wrap #printTable td:nth-child(6) { text-align: right; white-space: nowrap; }
        .sales-report-wrap #printTable th:nth-child(2),
        .sales-report-wrap #printTable td:nth-child(2),
        .sales-report-wrap #printTable th:nth-child(7),
        .sales-report-wrap #printTable td:nth-child(7),
        .sales-report-wrap #printTable th:nth-child(8),
        .sales-report-wrap #printTable td:nth-child(8),
        .sales-report-wrap #printTable th:nth-child(10),
        .sales-report-wrap #printTable td:nth-child(10) { white-space: nowrap; }

        .sales-report-wrap #printTable .col-item-name,
        .sales-report-wrap #printTable .col-name {
            max-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
    }

    .sales-report-wrap #printTable .cell-stack {
        display: flex;
        flex-direction: column;
        gap: 2px;
        line-height: 1.25;
    }

    .sales-report-wrap #printTable th {
        font-size: 0.95rem !important;
        font-weight: 700 !important;
        color: #000 !important;
    }

    .sales-report-wrap #printTable td {
        font-size: 0.98rem !important;
        color: #000 !important;
    }

    .sales-report-wrap #printTable tbody tr.click-row {
        cursor: pointer;
        border-bottom: 1px solid #f1f5f9;
        transition: all 0.2s;
    }

    .sales-report-wrap #printTable tbody tr.click-row:hover {
        background: #f0f7ff;
    }

    @media screen {
        .sales-report-wrap #printTable .cell-sub {
            font-size: 0.88rem;
            color: #000 !important;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .sales-report-wrap #printTable .cell-sub a {
            color: #25D366;
            text-decoration: none;
            font-weight: 500;
        }
    }

    .sales-report-wrap #printTable .col-name a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        color: #000 !important;
    }

    @media (max-width: 768px) {
        .sales-report-wrap > p,
        .sales-report-wrap > p strong,
        .sales-report-wrap .btn,
        .sales-report-wrap .btn.btn-sm,
        .sales-report-wrap #printTable th,
        .sales-report-wrap #printTable td,
        .sales-report-wrap #printTable {
            font-size: 0.92rem !important;
        }
    }

@media print {
    @page {
        margin: 0.5cm;
        size: A4 landscape;
    }

    body {
        margin: 0;
        padding: 0;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
    }

    .no-print {
        display: none !important;
    }

    body * {
        visibility: hidden;
    }

    #printArea,
    #printArea * {
        visibility: visible;
    }

    #printArea {
        position: absolute;
        left: 0;
        top: 0;
        width: 100%;
        margin: 0;
        padding: 0;
    }

    #printArea .container,
    #printArea .sales-report-wrap {
        max-width: 100% !important;
        width: 100% !important;
        margin: 0 !important;
        padding: 0 4px !important;
    }

    #printArea .table-responsive {
        overflow: visible !important;
    }

    #printArea .report-title {
        font-size: 15px !important;
        font-weight: 700 !important;
        color: #000 !important;
        margin: 0 0 6px 0 !important;
        padding: 0 !important;
    }

    #printArea #printTable {
        width: 100% !important;
        font-size: 12px !important;
        table-layout: fixed !important;
        border-collapse: collapse !important;
        border-spacing: 0 !important;
    }

    #printArea #printTable thead,
    #printArea #printTable thead tr,
    #printArea #printTable thead th {
        background: #d9d9d9 !important;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
    }

    #printArea #printTable th,
    #printArea #printTable td {
        padding: 5px 4px !important;
        font-size: 12px !important;
        line-height: 1.35 !important;
        vertical-align: top;
        border: 1px solid #000 !important;
        color: #000 !important;
        background: #fff !important;
    }

    #printArea #printTable th {
        font-weight: 700 !important;
        font-size: 12px !important;
        text-align: left;
    }

    #printArea #printTable .cell-stack {
        display: block !important;
    }

    #printArea #printTable .cell-sub,
    #printArea #printTable .cell-sub a {
        display: block !important;
        font-size: 12px !important;
        line-height: 1.35 !important;
        color: #000 !important;
        font-weight: 400 !important;
        margin-top: 2px !important;
        overflow: visible !important;
        text-overflow: clip !important;
        white-space: normal !important;
    }

    #printArea #printTable .col-item-name,
    #printArea #printTable .col-name {
        overflow: visible !important;
        text-overflow: clip !important;
        white-space: normal !important;
        word-wrap: break-word !important;
        overflow-wrap: anywhere !important;
        max-width: none !important;
        min-width: 0 !important;
    }

    #printArea #printTable a {
        color: #000 !important;
        text-decoration: none !important;
        font-weight: inherit !important;
    }

    #printArea #printTable col.col-w-sno { width: 3% !important; }
    #printArea #printTable col.col-w-bill { width: 6% !important; }
    #printArea #printTable col.col-w-name,
    #printArea #printTable col.col-w-item { width: 16% !important; }
    #printArea #printTable col.col-w-amt { width: 7% !important; }
    #printArea #printTable col.col-w-date { width: 8% !important; }
    #printArea #printTable col.col-w-text { width: 9% !important; }

    #printArea #printTable th.col-name,
    #printArea #printTable td.col-name,
    #printArea #printTable th.col-item-name,
    #printArea #printTable td.col-item-name {
        width: 16% !important;
        max-width: none !important;
    }

    #printArea #printTable th.col-sno,
    #printArea #printTable td.col-sno,
    #printArea #printTable th:nth-child(1),
    #printArea #printTable td:nth-child(1) { text-align: center !important; }

    #printArea #printTable th.col-amt-num,
    #printArea #printTable td.col-amt-num,
    #printArea #printTable th:nth-child(6),
    #printArea #printTable td:nth-child(6) { text-align: right !important; }
}
</style>

</head>
<body>

    <jsp:include page="/assets/navbar/navbar.jsp" />

<div class="container mt-4 sales-report-wrap">
<p class="report-title"><strong>Delivered Report From:</strong> <%= formatDateDDMMYYYY(fromDate) %> - <%= formatDateDDMMYYYY(toDate) %></p>
    <div class="mb-3 no-print">
        <a href="<%=contextPath%>/reports/delivered/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
        <button id="printBtn" class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
        <button id="exportBtn" class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Delivered_Report')">📊 Export to Excel</button>
    </div>
<div class="table-responsive">
<table id="printTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 13px;">
    <colgroup>
        <col class="col-w-sno">
        <col class="col-w-bill">
        <col class="col-w-name">
        <col class="col-w-item">
        <col class="col-w-amt">
        <col class="col-w-date">
        <col class="col-w-date">
        <col class="col-w-text">
        <col class="col-w-text">
        <col class="col-w-text">
    </colgroup>
    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
        <tr>
            <th class="col-sno" style="padding: 0.28rem 0.2rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">#</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Bill No</th>
            <th class="col-name" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Name</th>
            <th class="col-item-name" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Item Name</th>
            <th class="col-amt col-amt-num" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Payable</th>
            <th class="col-datetime" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Delivery Date</th>
            <th class="col-datetime" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Delivered Date</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Place</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Person</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Staff</th>
        </tr>
    </thead>
    <tbody>
    <%
    Vector list = bill.getDeliveredReport(fromDate, toDate);
    int count = 0;
    if (list != null && list.size() > 0) {
        for (int i = 0; i < list.size(); i++) {
            Vector row = (Vector) list.elementAt(i);
            int billId = Integer.parseInt(row.elementAt(0).toString());
            String billNo = row.elementAt(1).toString();
            String cusName = row.elementAt(2).toString();
            String cusPhn = row.elementAt(3).toString();
            String payable = row.elementAt(4).toString();
            String deliveryDate = row.elementAt(5).toString();
            String deliveredDate = row.elementAt(6).toString();
            String deliveryPlace = row.elementAt(7).toString();
            String deliveryPerson = row.elementAt(8).toString();
            String itemNames = row.elementAt(12).toString();
            String staff = row.elementAt(11).toString();
            count++;
            String detailUrl = contextPath + "/reports/delivered/detail.jsp?billId=" + billId + "&fromDate=" + fromDate + "&toDate=" + toDate;
    %>
        <tr class="click-row" onclick="window.location.href='<%=detailUrl%>'" title="Click for bill detail &amp; print" style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
            <td class="col-sno" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= count %></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= billNo %></td>
            <td class="col-name" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                <div class="cell-stack">
                    <div><%= cusName %></div>
                    <div class="cell-sub">
                        <% if (cusPhn != null && !cusPhn.trim().isEmpty()) { %>
                            <a href="https://wa.me/<%=cusPhn%>" target="_blank" onclick="event.stopPropagation();"><%= cusPhn %></a>
                        <% } else { %>
                            -
                        <% } %>
                    </div>
                </div>
            </td>
            <td class="col-item-name" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;" title="<%= itemNames %>"><%= itemNames %></td>
            <td class="col-amt col-amt-num" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; text-align:right;"><%= String.format("%.1f", Double.parseDouble(payable)) %></td>
            <td class="col-datetime" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= formatDateDDMMYYYY(deliveryDate) %></td>
            <td class="col-datetime" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= formatDateDDMMYYYY(deliveredDate) %></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= deliveryPlace.isEmpty() ? "-" : deliveryPlace %></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= deliveryPerson.isEmpty() ? "-" : deliveryPerson %></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= staff %></td>
        </tr>
    <%
        }
    } else {
    %>
        <tr><td colspan="10" class="text-center text-muted py-4" style="border: none;">No delivered bills found for this period.</td></tr>
    <% } %>
    </tbody>
</table>
</div>
<% if (count > 0) { %>
<p class="mt-2 text-muted small no-print">Total: <%= count %> bill(s). Click a row to view detail and print.</p>
<% } %>
</div>

<script>
function preparePrintTable(root) {
    root.querySelectorAll('.no-print').forEach(function(el) {
        el.remove();
    });

    root.querySelectorAll('thead, thead tr, thead th, tbody tr, tbody td, tbody th').forEach(function(el) {
        el.removeAttribute('style');
    });

    var table = root.querySelector('#printTable');
    if (table) {
        table.removeAttribute('style');
        table.classList.add('print-ready');

        table.querySelectorAll('tbody tr').forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells.length === 10) {
                cells[0].classList.add('col-sno');
                cells[2].classList.add('col-name');
                cells[3].classList.add('col-item-name');
                cells[4].classList.add('col-amt-num');
                cells[5].classList.add('col-datetime');
                cells[6].classList.add('col-datetime');
            }
        });
    }

    if (root.classList.contains('sales-report-wrap')) {
        root.classList.remove('sales-report-wrap');
    }
}

function printReport() {
    var reportWrap = document.querySelector('.sales-report-wrap');
    if (!reportWrap) {
        window.print();
        return;
    }

    var printArea = document.createElement('div');
    printArea.id = 'printArea';

    var tableClone = reportWrap.cloneNode(true);
    preparePrintTable(tableClone);

    printArea.appendChild(tableClone);
    document.body.appendChild(printArea);
    window.print();
    document.body.removeChild(printArea);
}

function exportTableToExcel(tableID, filename) {
    var table = document.getElementById(tableID);
    if (!table) {
        alert('Table not found!');
        return;
    }

    var tableClone = table.cloneNode(true);
    tableClone.querySelectorAll('.no-print').forEach(function(el) {
        el.remove();
    });

    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
    html += '<head><meta charset="UTF-8">';
    html += '<style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style>';
    html += '</head><body>';
    html += '<table border="1">' + tableClone.innerHTML + '</table>';
    html += '</body></html>';

    filename = filename ? filename + '.xls' : 'delivered_report.xls';

    var blob = new Blob(['\ufeff', html], {
        type: 'application/vnd.ms-excel'
    });

    var downloadLink = document.createElement('a');
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = filename;
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}
</script>

</body>
</html>
