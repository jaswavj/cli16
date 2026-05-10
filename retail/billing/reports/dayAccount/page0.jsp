<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ page language="java" import="java.util.*" %>
    <%@ page language="java" import="java.util.*,java.text.*" %>
      <jsp:useBean id="bill" class="billing.billingBean" />
      <jsp:useBean id="prod" class="product.productBean" />
      <% 
        String fromDate=request.getParameter("fromDate"); 
        String toDate=request.getParameter("toDate"); 
        Vector vec=prod.getCategoryName(); 
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

            <div class="container mt-4">
              <div class="d-flex justify-content-between align-items-center mb-3">
                <p class="mb-0"><strong>Account Report From:</strong>
                  <%= fromDate %> - <%= toDate %>
                </p>
                <div class="no-print">
                  <a href="<%=contextPath%>/reports/dayAccount/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
                  <button class="btn btn-primary btn-sm"
                    onclick="printReport()">🖨 Print</button>
                  <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Day_Account_Report')">📊 Export to Excel</button>
                </div>
              </div>

              <div class="table-responsive">
              <table id="printTable" class="table table-hover mt-3">
                <thead>
                  <tr style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); border-bottom: 2px solid #e2e8f0;">
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568;">Category Name</th>
                    <th style="padding: 0.4rem; font-size: 0.85rem; font-weight: 600; color: #4a5568; text-align: right;">Collection</th>
                  </tr>
                </thead>
                <tbody>
                  <% double grandTotal=0; for (int i=0; i < vec.size(); i++) { Vector row=(Vector) vec.get(i); String
                    categoryName=row.get(0).toString(); String categoryId=row.get(1).toString(); int
                    categoryIdInt=Integer.parseInt(categoryId); double
                    salesAmount=bill.getSalesByCategory(categoryIdInt, fromDate, toDate); 
                    grandTotal +=salesAmount; %>
                    <tr>
                      <td>
                        <%= categoryName %>
                      </td>
                      <td><a href="<%=contextPath%>/reports/dayAccount/details.jsp?categoryId=<%=categoryIdInt%>&fromDate=<%=fromDate%>&toDate=<%=toDate%>"
                          class="btn  btn-sm btn-edit" style="background-color:hsl(222, 100%, 96%); color:#000000;">
                          <%= salesAmount %>
                        </a>
                      </td>

                    </tr>
                    <% } %>
                    <tr class="table-secondary">
                      <th class="text-end">Collection Total</th>
                      <th><%= grandTotal %></th>
                    </tr>
              </table>
              </div>
              <table class="table table-bordered table-striped mt-3">
                <thead class="table-dark">
                  <tr>
                    <th>Payment Method</th>
                    <th>Amount</th>

                  </tr>
                </thead>
                <tbody>
                  <% double cashAmount=bill.getSalesCashTotal( fromDate, toDate); double
                    bankAmount=bill.getSalesBankTotal( fromDate, toDate); double
                    balanceAmount=bill.getSalesBalanceTotal( fromDate, toDate); double
                    DiscAmount=bill.getSalesDiscountTotal( fromDate, toDate); double totalPaid=cashAmount +
                    bankAmount+balanceAmount+DiscAmount; %>
                    <tr>
                      <td>Cash</td>
                      <td>
                        <%=cashAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Bank</td>
                      <td>
                        <%=bankAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Disount</td>
                      <td>
                        <%=DiscAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Due</td>
                      <td>
                        <%=balanceAmount%>
                      </td>
                    </tr>
                    <tr>
                      <th class="text-end"> Total</th>
                      <th>
                        <%=totalPaid %>
                      </th>
                    </tr>

                </tbody>
              </table>
              <table class="table table-bordered table-striped mt-3">
                <thead class="table-dark">
                  <tr>
                    <th>Due Collection</th>
                    <th>Amount</th>

                  </tr>
                </thead>
                <tbody>
                  <% double cashDueAmount=bill.getDueCashTotal( fromDate, toDate); double
                    bankDueAmount=bill.getDueBankTotal( fromDate, toDate); double totalDuePaid=cashDueAmount +
                    bankDueAmount; %>
                    <tr>
                      <td>Cash</td>
                      <td>
                        <%=cashDueAmount%>
                      </td>
                    </tr>
                    <tr>
                      <td>Bank</td>
                      <td>
                        <%=bankDueAmount%>
                      </td>
                    </tr>

                    <tr>
                      <th class="text-end"> Total</th>
                      <th>
                        <%=totalDuePaid %>
                      </th>
                    </tr>

                </tbody>
              </table>
            </div>
            <div class="text-center my-3">
              <div class="alert alert-info d-inline-block px-4 py-2 rounded">
                <strong>Total Difference:</strong>
                <%= (grandTotal - totalPaid) %>
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