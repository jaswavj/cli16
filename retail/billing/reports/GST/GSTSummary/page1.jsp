<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>

<jsp:useBean id="prod" class="product.productBean" />
<%
String from = request.getParameter("startDate");
String end = request.getParameter("endDate");

Vector list = prod.getGSTSummary(from,end);

%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>GST Summary Report</title>
    <%@ include file="/assets/common/head.jsp" %>  <style>
    body { background-color: #f8f9fa; }
    .report-title { font-size: 1.6rem; font-weight: 600; margin-bottom: 1.2rem; }
    .table thead th { vertical-align: middle; }
  </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
  <div class="container my-5">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div class="text-center flex-grow-1">
        <h1 class="report-title">GST Summary Report</h1>
        <p class="text-muted mb-0">From <strong><%=from%></strong> To <strong><%=end%></strong></p>
      </div>
      <div class="no-print">
        <a href="<%=contextPath%>/reports/GST/GSTSummary/page.jsp" class="btn btn-secondary me-2">⬅ Back</a>
        <button class="btn btn-primary me-2" onclick="printReport()">🖨 Print</button>
        <button class="btn btn-success me-2" onclick="exportTableToExcel()">📊 Export to Excel</button>
        <button class="btn btn-info" onclick="exportToJSON()">📄 Export GSTR-3B JSON</button>
      </div>
    </div>

    <!-- Table -->
    <div class="table-responsive shadow-sm rounded">
      <table id="gstSummaryTable" class="table table-hover align-middle">
        <thead>
          <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">#</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">GST Rate</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Invoice Value</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Taxable</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">CGST %</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">CGST Amount</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">SGST %</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">SGST Amount</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Total GST</th>
            <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Total</th>
          </tr>
        </thead>
        <tbody class="text-center">
          
         
    <%
int count = 1;
double finInvValue=0.0;
double finTaxable=0.0;
double finSgst=0.0;
double finCgst=0.0;
double finTotalTax=0.0;
double finTotal=0.0;
double finalTotals=0.0;
for(int i=0;i<list.size();i++){
    Vector row = (Vector) list.get(i);
    Double invValue = Double.parseDouble(row.elementAt(8).toString());
    Double taxable = Double.parseDouble(row.elementAt(1).toString());
    Double sgst = Double.parseDouble(row.elementAt(3).toString());
    Double cgst = Double.parseDouble(row.elementAt(5).toString());
    Double totalTax = Double.parseDouble(row.elementAt(6).toString());
    Double total = Double.parseDouble(row.elementAt(7).toString());
    finInvValue +=invValue;
    finTaxable +=taxable;
    finSgst +=sgst;
    finCgst +=cgst;
    finTotalTax +=totalTax;
    finTotal +=total;
    finalTotals =taxable+totalTax;
    //out.print(finalTotals);
%>
<!--tr>
    <td><%= count++ %></td>
    <td class="text-center"><%= row.get(0).toString() %>%</td>
    <td class="text-end"><%= String.format("%,.2f", invValue) %></td>
    <td class="text-end"><%= String.format("%,.2f", taxable) %></td>    
    <td class="text-center"><%= String.format("%.1f", Double.parseDouble(row.get(2).toString())) %>%</td>
    <td class="text-end"><%= String.format("%,.2f", sgst) %></td>
    <td class="text-center"><%= String.format("%.1f", Double.parseDouble(row.get(4).toString())) %>%</td>
    <td class="text-end"><%= String.format("%,.2f", cgst) %></td>
    <td class="text-end"><%= String.format("%,.2f", totalTax) %></td>
    <td class="text-end"><%= String.format("%,.2f", total) %></td>
</tr-->
<tr>
    <td><%= i+1 %></td>
    <td class="text-center"><%= row.get(0) %>%</td>
    <td class="text-end"><%= invValue %></td>
    <td class="text-end"><%= taxable %></td>    
    <td class="text-center"><%= String.format("%.1f", Double.parseDouble(row.get(2).toString())) %>%</td>
    <td class="text-end"><%= sgst %></td>
    <td class="text-center"><%= String.format("%.1f", Double.parseDouble(row.get(4).toString())) %>%</td>
    <td class="text-end"><%= cgst %></td>
    <td class="text-end"><%= totalTax %></td>
    <td class="text-end"><%= total %></td>
</tr>


<%
}
%>
<tr>
    <td colspan="2">Total</td>
    <td align="right"><%=finInvValue%></td>
    <td align="right"><%=finTaxable%></td>
    <td></td>
    <td align="right"><%=finSgst%></td>
    <td></td>
    <td align="right"><%=finCgst%></td>
    <td align="right"><%=finTotalTax%></td>
    <td align="right"><%=finTotal%></td>
</tr>
          
        </tbody>
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
    h1 {
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
    const table = document.getElementById('gstSummaryTable');
    const filename = 'GST_Summary_Report.xls';
    
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

function exportToJSON() {
    // Calculate taxable and nil-rated values
    let taxableValue = 0;
    let totalCGST = 0;
    let totalSGST = 0;
    let nilRatedValue = 0;
    
    <%
    for(int j=0; j<list.size(); j++){
        Vector row = (Vector) list.get(j);
        Double gstRate = Double.parseDouble(row.elementAt(0).toString());
        Double taxable = Double.parseDouble(row.elementAt(1).toString());
        Double sgst = Double.parseDouble(row.elementAt(3).toString());
        Double cgst = Double.parseDouble(row.elementAt(5).toString());
    %>
    <% if(gstRate == 0) { %>
    nilRatedValue += <%= taxable %>;
    <% } else { %>
    taxableValue += <%= taxable %>;
    totalCGST += <%= cgst %>;
    totalSGST += <%= sgst %>;
    <% } %>
    <%
    }
    %>
    
    const gstr3bData = {
        "gstin": "22AAAAA0000A1Z5",
        "ret_period": "012026",
        "sup_details": {
            "osup_det": {
                "txval": parseFloat(taxableValue.toFixed(3)),
                "igst": 0,
                "cgst": parseFloat(totalCGST.toFixed(3)),
                "sgst": parseFloat(totalSGST.toFixed(3)),
                "cess": 0
            },
            "osup_zero": {
                "txval": 0,
                "igst": 0,
                "cgst": 0,
                "sgst": 0,
                "cess": 0
            },
            "osup_nil_exmp": {
                "txval": parseFloat(nilRatedValue.toFixed(3)),
                "igst": 0,
                "cgst": 0,
                "sgst": 0,
                "cess": 0
            },
            "osup_nongst": {
                "txval": 0
            }
        }
    };
    
    const jsonString = JSON.stringify(gstr3bData, null, 2);
    const blob = new Blob([jsonString], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const downloadLink = document.createElement('a');
    downloadLink.href = url;
    downloadLink.download = 'GSTR3B_Table_3.1_<%=from%>_to_<%=end%>.json';
    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
    URL.revokeObjectURL(url);
}
</script>

</body>
</html>
