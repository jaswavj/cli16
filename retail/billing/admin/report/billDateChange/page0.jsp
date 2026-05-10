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
    <title>Bill Date Change Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container my-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>Bill Date Change Report</h2>
            <div class="no-print">
                <a href="<%=contextPath%>/admin/report/billDateChange/page.jsp" class="btn btn-secondary me-2">
                    <i class="fas fa-arrow-left"></i> Back
                </a>
                <button class="btn btn-primary me-2" onclick="printReport()">🖨 Print</button>
                <button class="btn btn-success" onclick="exportTableToExcel()">📊 Export to Excel</button>
            </div>
        </div>
        
        <div class="alert alert-info mb-4">
            <strong>Report Period:</strong> <%= fromDate %> to <%= toDate %>
        </div>

        <div class="table-responsive">
            <table id="billDateChangeTable" class="table table-hover">
                <thead>
                    <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">S.No</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Bill No</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Old Date</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">New Date</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Change Date</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Change Time</th>
                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Changed By</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector list = bill.getBillDateChangeReport(fromDate, toDate);
                    if (list != null && !list.isEmpty()) {
                        for (int i = 0; i < list.size(); i++) {
                            Vector row = (Vector) list.get(i);
                            int billId = Integer.parseInt(row.elementAt(0).toString());
                    %>
                    <tr>
                        <td><%=i+1%></td>
                        <td>
                            <a href="#" onclick="loadBillDetails(<%=billId%>); return false;" 
                               class="btn btn-sm btn-edit" 
                               style="background-color:hsl(222, 86%, 89%); color:#000000;">
                                <%=row.elementAt(1)%>
                            </a>
                        </td>
                        <td><%=row.elementAt(2)%></td>
                        <td><%=row.elementAt(3)%></td>
                        <td><%=row.elementAt(4)%></td>
                        <td><%=row.elementAt(5)%></td>
                        <td><%=row.elementAt(6)%></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="7" class="text-center">No date changes found for the selected period.</td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>

        <% if (list != null && !list.isEmpty()) { %>
        <div class="alert alert-secondary mt-3">
            <strong>Total Records:</strong> <%= list.size() %>
        </div>
        <% } %>
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
    h2 {
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
    const table = document.getElementById('billDateChangeTable');
    const filename = 'Bill_Date_Change_Report.xls';
    
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

function loadBillDetails(billId) {
  var modal = new bootstrap.Modal(document.getElementById('billDetailModal'));
  modal.show();
  document.getElementById('billDetailContent').innerHTML = '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>';
  fetch('<%=contextPath%>/billing/balanceDetailModal.jsp?billId=' + billId)
    .then(response => response.text())
    .then(data => { document.getElementById('billDetailContent').innerHTML = data; })
    .catch(error => { document.getElementById('billDetailContent').innerHTML = '<div class="alert alert-danger" role="alert"><i class="fas fa-exclamation-triangle"></i> Error loading bill details. Please try again.</div>'; console.error('Error:', error); });
}
</script>

<!-- Bill Details Modal -->
<div class="modal fade" id="billDetailModal" tabindex="-1" aria-labelledby="billDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header" style="background: linear-gradient(135deg, #3d1a52, #570a57); color: white;">
        <h5 class="modal-title" id="billDetailModalLabel">Bill Details</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="billDetailContent">
        <div class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div></div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

</body>
</html>
