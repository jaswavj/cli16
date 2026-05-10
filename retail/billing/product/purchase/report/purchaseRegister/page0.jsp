<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
    int supId = Integer.parseInt(request.getParameter("supId"));
    //out.print(supId);

%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Purchase Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
        <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container my-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="mb-0">Purchase Report</h2>
            <div class="no-print">
                <a href="page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
                <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
                <button class="btn btn-success btn-sm" onclick="exportTableToExcel('purchaseTable', 'Purchase_Report')">📊 Export to Excel</button>
            </div>
        </div>
        <div class="table-responsive">
        <table id="purchaseTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 900px;">
            <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                <tr>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Inv No/GR no</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Invoice Date/Time</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Supplier</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total (₹)</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid (₹)</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance (₹)</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">User</th>
                </tr>
            </thead>
            <tbody>
                <%
                Vector list = prod.getPurchaseReport(fromDate, toDate,supId);
                if (list != null && !list.isEmpty()) {
                    for (int i = 0; i < list.size(); i++) {
                        Vector row = (Vector) list.get(i);
                        String purchaseId = (String) row.elementAt(0);
                        
                %>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
                    <td style="padding: 0.4rem; border: none; font-size: 0.9rem;"><a href="purchaseDetails.jsp?id=<%=purchaseId%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>&supId=<%=supId%>" style="color: #667eea; font-weight: 600; text-decoration: none;"><%=row.elementAt(1)%>/<%=row.elementAt(11)%></a></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(3)%></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(10)%></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(4)%></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(5)%></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(6)%></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(7)%></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(8)%></td>
                    <td style="padding: 0.4rem; color: #2d3748; font-weight: 500; border: none; font-size: 0.9rem;"><%=row.elementAt(9)%></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="10" class="text-center" style="padding: 2rem; color: #718096;">
                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                        <p class="mb-0">No purchase records found for the selected period.</p>
                    </td>
                </tr>
                <%
                } 
                %>
            </tbody>
        </div>
    </div>

<style>
@media (max-width: 768px) {
    .d-flex.justify-content-between {
        flex-direction: column;
        gap: 1rem;
    }
    .no-print {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
    }
    .no-print a, .no-print button {
        width: 100%;
    }
}

<style>
@media print {
    @page {
        margin: 0.3cm;
        size: portrait;
    }
    body {
        margin: 0;
        padding: 0;
    }
    .no-print {
        display: none !important;
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
        margin: 0;
        padding: 0;
    }
    #printArea .container {
        max-width: 100% !important;
        margin: 0 !important;
        padding: 0 5px !important;
    }
    #printArea table {
        width: 100% !important;
        font-size: 8px !important;
    }
    #printArea table th,
    #printArea table td {
        padding: 1px 2px !important;
        font-size: 8px !important;
        word-wrap: break-word;
        max-width: 80px;
    }
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
        .catch(error => {
            console.error('Error loading print header:', error);
            window.print();
        });
}

function exportTableToExcel(tableID, filename = ''){
    var table = document.getElementById(tableID);
    if (!table) {
        alert('Table not found!');
        return;
    }
    
    var tableClone = table.cloneNode(true);
    
    var html = '<html xmlns:x="urn:schemas-microsoft-com:office:excel">';
    html += '<head><meta charset="UTF-8">';
    html += '<style>table {border-collapse: collapse;} td, th {border: 1px solid black; padding: 5px;}</style>';
    html += '</head><body>';
    html += '<table border="1">' + tableClone.innerHTML + '</table>';
    html += '</body></html>';
    
    filename = filename ? filename + '.xls' : 'excel_data.xls';
    
    var blob = new Blob(['\ufeff', html], {
        type: 'application/vnd.ms-excel'
    });
    
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
