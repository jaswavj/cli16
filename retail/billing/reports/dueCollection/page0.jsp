<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
%>
<jsp:useBean id="bill" class="billing.billingBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
        <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container my-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">Due Collection Report</h2>
            <div class="no-print">
                <a href="<%=contextPath%>/reports/dueCollection/page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
                <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
                <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Due_Collection_Report')">📊 Export to Excel</button>
            </div>
        </div>
        <div class="table-responsive">
        <table id="printTable" class="table table-hover">
            <thead>
                <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">S.No</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Bill No</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Customer name</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Balance</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Paid</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Final Balance</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Mode</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">User</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Date</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Time</th>
                </tr>
            </thead>
            <tbody>
                <%
                Vector list = bill.getDueCollection(fromDate, toDate);
                if (list != null && !list.isEmpty()) {
                    for (int i = 0; i < list.size(); i++) {
                        Vector row = (Vector) list.get(i);
                        
                %>
                <tr>
                    <td><%=i+1%></td>
                    <td><%=row.elementAt(0)%></td>
                    <td><%=row.elementAt(1)%></td>
                    <td><%=row.elementAt(2)%></td>
                    <td><%=row.elementAt(3)%></td>
                    <td><%=row.elementAt(4)%></td>
                    <td><%=row.elementAt(5)%></td>
                    <td><%=row.elementAt(6)%></td>
                    <td><%=row.elementAt(7)%></td>
                    <td><%=row.elementAt(8)%></td>
                    
                </tr>
                <%
                    }
                } 
                %>
                <!-- Add more rows as needed -->
            </tbody>
        </table>
        </div>
    </div>

<script>
function printReport(title) {
    var printContent = document.getElementById('printTable').outerHTML;
    var originalContent = document.body.innerHTML;

    document.body.innerHTML = '<html><head><title>' + title + '</title></head><body>' +
        '<h2>' + title + '</h2>' +
        '<p>Period: <%= fromDate %> to <%= toDate %></p>' +
        printContent +
        '</body></html>';

    window.print();
    document.body.innerHTML = originalContent;
}
</script>

<style>
@media print {
    @page { margin: 0.3cm; size: portrait; }
    body { margin: 0; padding: 0; }
    .no-print { display: none !important; }
    body * { visibility: hidden; }
    #printArea, #printArea * { visibility: visible; }
    #printArea { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
    #printArea .container { max-width: 100% !important; margin: 0 !important; padding: 0 5px !important; }
    #printArea table { width: 100% !important; font-size: 8px !important; }
    #printArea table th, #printArea table td { padding: 1px 2px !important; font-size: 8px !important; word-wrap: break-word; max-width: 80px; }
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
