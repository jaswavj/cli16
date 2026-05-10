<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page language="java" import="java.util.*" %>
        <%@ page language="java" import="java.util.*,java.text.*" %>
            <jsp:useBean id="bill" class="billing.billingBean" />
            <jsp:useBean id="prod" class="product.productBean" />
            <% 
                String fromDate=request.getParameter("fromDate"); String toDate=request.getParameter("toDate"); int
                categoryId=Integer.parseInt(request.getParameter("categoryId")); // Just for demo - print selected dates
                %>
                <!DOCTYPE html>
                <html lang="en">

                <head>

                    <meta charset="UTF-8">
                    <title>Sales Report</title>
                    <%@ include file="/assets/common/head.jsp" %>
                        <style>
                            body {
                                background: #f5f7fa;
                            }

                            .navbar {
                                background-color: #4e73df;
                            }

                            .navbar-brand {
                                color: #fff !important;
                            }

                            .table td,
                            .table th {
                                vertical-align: middle;
                            }

                            .btn-edit,
                            .btn-delete {
                                margin: 0 2px;
                            }
                        </style>
                </head>

                <body>
                    <!--%@ include file="../menu/reportMenu.jsp" %-->
                    <%@ include file="/assets/navbar/navbar.jsp" %>

                        <div class="container mt-4 ">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <p class="mb-0"><strong>Collection Report From:</strong>
                                    <%= fromDate %> - <%= toDate %>
                                </p>
                                <div class="no-print">
                                    <a href="<%=contextPath%>/reports/salesByCate/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
                                    <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
                                    <button class="btn btn-success btn-sm"
                                        onclick="exportTableToExcel('stockTable', 'Sales_By_Category_Report')">📊 Export to
                                        Excel</button>
                                </div>
                            </div>

                            <div class="table-responsive">
                            <table id="stockTable" class="table table-hover mt-3"
                                style="font-size: 12px; min-width: 1200px;">
                                <thead>
                                    <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">S.No</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Bill No</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Customer Name</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: center;">Qty</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Price</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Discount</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Total</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Paid</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Balance</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Pending balance</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">
                                            <%=head1%>
                                        </th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">
                                            <%=head2%>
                                        </th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Date</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Time</th>
                                        <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Biller</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% Vector vec=bill.getSalesReport(fromDate,toDate,categoryId); double grandTotal=0;
                                        double grandPrice=0; double grandDiscount=0; double finPaid=0.0; double
                                        finBalance=0.0; double finCurBalance=0.0; for(int i=0;i< vec.size();i++) {
                                        Vector row=(Vector)vec.elementAt(i); int
                                        billId=Integer.parseInt(row.elementAt(8).toString()); double
                                        price=Double.parseDouble(row.elementAt(2).toString()); double
                                        total=Double.parseDouble(row.elementAt(4).toString()); double
                                        discount=Double.parseDouble(row.elementAt(3).toString()); double
                                        paid=Double.parseDouble(row.elementAt(4).toString()); double
                                        balance=Double.parseDouble(row.elementAt(13).toString()); double
                                        curBalance=Double.parseDouble(row.elementAt(14).toString()); grandTotal +=total;
                                        grandPrice +=price; grandDiscount +=discount; finPaid+=paid;
                                        finBalance+=balance; finCurBalance+=curBalance; %>
                                        <tr>
                                            <td>
                                                <%=i+1%>
                                            </td>
                                            <td><a href="#" onclick="loadBillDetails(<%=billId%>); return false;"
                                                    class="btn  btn-sm btn-edit"
                                                    style="background-color:hsl(222, 86%, 89%); color:#000000;">
                                                    <%=row.elementAt(0)%>
                                                </a></td>
                                            <td>
                                                <%=row.elementAt(15)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(1)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(2)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(3)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(4)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(4)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(13)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(14)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(10)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(11)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(5)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(6)%>
                                            </td>
                                            <td>
                                                <%=row.elementAt(7)%>
                                            </td>
                                        </tr>
                                        <% } %>
                                            <tr class="table-secondary">
                                                <td colspan="4" class="text-end"><strong>Grand Total:</strong></td>
                                                <td><strong>
                                                        <%=String.format("%.3f", grandPrice)%>
                                                    </strong></td>
                                                <td><strong>
                                                        <%=String.format("%.3f", grandDiscount)%>
                                                    </strong></td>
                                                <td><strong>
                                                        <%=String.format("%.3f", grandTotal)%>
                                                    </strong></td>
                                                <td><strong>
                                                        <%=String.format("%.3f", finPaid)%>
                                                    </strong></td>
                                                <td><strong>
                                                        <%=String.format("%.3f", finBalance)%>
                                                    </strong></td>
                                                <td><strong>
                                                        <%=String.format("%.3f", finCurBalance)%>
                                                    </strong></td>
                                                <td colspan="5"></td>
                                </tbody>
                            </table>
                            </div>

                        </div>
                        <script>
                            // Print function
                            function printReport() {
                                // Get table HTML
                                var table = document.getElementById("stockTable").outerHTML;

                                // Get header/navbar HTML
                                var header = document.getElementById("printHeader"); // wrap navbar in div with id="printHeader"
                                var headerHtml = header ? header.outerHTML : "";

                                // Open new window
                                var newWin = window.open("", "_blank");
                                newWin.document.write(`
        <html>
        <head>
            <title>Billing Report</title>
            <style>
                /* Force all text to black */
                body, h1, h2, h3, h4, h5, h6, p, span, td, th, a, div {
                    color: #000 !important;
                }

                /* Table styles */
                table { 
                    border-collapse: collapse !important; 
                    width: 100%; 
                    font-size: 12px; 
                    color: #000 !important; 
                }
                table, th, td { 
                    border: 1px solid black !important; 
                    padding: 5px !important; 
                    color: #000 !important; 
                }
                th { 
                    background: #ccc !important; 
                    color: #000 !important; 
                }

                a { 
                    color: #000 !important; 
                    text-decoration: none !important; 
                }

                button { display: none !important; } /* hide buttons in print */
            </style>
        </head>
        <body>
            ${headerHtml}
            <h3>Billing Report <%=fromDate%> - <%=toDate%></h3>
            ${table}
        </body>
        </html>
    `);
                                newWin.document.close();
                                newWin.focus();
                                newWin.print();
                                newWin.close();
                            }

                            // Export to Excel function
                            function exportTableToExcel(tableID, filename = '') {
                                var table = document.getElementById(tableID);
                                var tableHTML = table.outerHTML.replace(/ /g, '%20');

                                // Specify file name
                                filename = filename ? filename + '.xls' : 'excel_data.xls';

                                // Create download link
                                var downloadLink = document.createElement("a");
                                document.body.appendChild(downloadLink);

                                if (navigator.msSaveOrOpenBlob) {
                                    // For IE
                                    var blob = new Blob(['\ufeff', tableHTML], { type: 'application/vnd.ms-excel' });
                                    navigator.msSaveOrOpenBlob(blob, filename);
                                } else {
                                    // For other browsers
                                    downloadLink.href = 'data:application/vnd.ms-excel,' + tableHTML;
                                    downloadLink.download = filename;
                                    downloadLink.click();
                                }
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