<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.util.*,java.text.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
    String fromDate = request.getParameter("fromDate");
    String toDate = request.getParameter("toDate");
    String reportType = request.getParameter("reportType");

    if (reportType == null) {
        reportType = "summary";
    }

    // Get totals
    double totalSales = bill.getTotalSalesByDateRange(fromDate, toDate);
    double totalPurchases = bill.getTotalPurchasesByDateRange(fromDate, toDate);
    
    // Get total expenses from expense_entry table
    double totalExpenses = 0.0;
    try {
        Vector expenseData = prod.getExpenseReport(fromDate, toDate, 0); // 0 = all types
        if (expenseData != null) {
            for (int i = 0; i < expenseData.size(); i++) {
                Vector row = (Vector) expenseData.get(i);
                if (row.size() > 4) {
                    totalExpenses += Double.parseDouble(row.get(4).toString());
                }
            }
        }
    } catch (Exception e) {
        System.err.println("Error loading expenses for P&L: " + e.getMessage());
        e.printStackTrace();
    }

    // Calculate profit/loss
    double grossProfit = totalSales - totalPurchases;
    double netProfit = grossProfit - totalExpenses;

    // Calculate percentages
    double profitMargin = 0.0;
    double expensePercentage = 0.0;
    if (totalSales > 0) {
        profitMargin = (netProfit / totalSales) * 100;
        expensePercentage = (totalExpenses / totalSales) * 100;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profit & Loss Report</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
    <h3 class="mb-4">Profit & Loss Report</h3>
    <p><strong>Period:</strong> <%= fromDate %> to <%= toDate %></p>

    <div class="mb-3 no-print">
        <a href="<%=contextPath%>/reports/profitLoss/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
        <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
        <button class="btn btn-success btn-sm" onclick="exportTableToExcel()">📊 Export to Excel</button>
    </div>

    <%
    if ("summary".equals(reportType)) {
    %>
    <!-- Summary Report -->
    <div class="row">
        <div class="col-md-8">
            <div class="table-responsive">
            <table id="profitLossTable" class="table table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th>Description</th>
                        <th class="text-end">Amount (₹)</th>
                        <th class="text-end">Percentage</th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="table-primary">
                        <td><strong>Revenue</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalSales) %></strong></td>
                        <td class="text-end"><strong>100.00%</strong></td>
                    </tr>
                    <tr>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Sales</td>
                        <td class="text-end"><%= String.format("%.3f", totalSales) %></td>
                        <td class="text-end">100.00%</td>
                    </tr>

                    <tr class="table-warning">
                        <td><strong>Cost of Goods Sold</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalPurchases) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", (totalSales > 0 ? (totalPurchases/totalSales)*100 : 0)) %>%</strong></td>
                    </tr>
                    <tr>
                        <td>&nbsp;&nbsp;&nbsp;&nbsp;Purchases</td>
                        <td class="text-end"><%= String.format("%.3f", totalPurchases) %></td>
                        <td class="text-end"><%= String.format("%.3f", (totalSales > 0 ? (totalPurchases/totalSales)*100 : 0)) %>%</td>
                    </tr>

                    <tr class="<%= grossProfit >= 0 ? "table-success" : "table-danger" %>">
                        <td><strong>Gross Profit/Loss</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", grossProfit) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", profitMargin) %>%</strong></td>
                    </tr>

                    <tr class="table-info">
                        <td><strong>Operating Expenses</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", totalExpenses) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", expensePercentage) %>%</strong></td>
                    </tr>

                    <tr class="<%= netProfit >= 0 ? "table-success" : "table-danger" %>">
                        <td><strong>Net Profit/Loss</strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", netProfit) %></strong></td>
                        <td class="text-end"><strong><%= String.format("%.3f", profitMargin) %>%</strong></td>
                    </tr>
                </tbody>
            </table>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="card-title mb-0">Profit/Loss Summary</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Total Revenue:</strong><br>
                        <span class="h4 text-primary">₹<%= String.format("%.3f", totalSales) %></span>
                    </div>
                    <div class="mb-3">
                        <strong>Cost of Goods Sold:</strong><br>
                        <span class="h4 text-warning">₹<%= String.format("%.3f", totalPurchases) %></span>
                    </div>
                    <div class="mb-3">
                        <strong>Operating Expenses:</strong><br>
                        <span class="h4 text-info">₹<%= String.format("%.3f", totalExpenses) %></span>
                    </div>
                    <hr>
                    <div class="mb-3">
                        <strong>Net Result:</strong><br>
                        <span class="h4 <%= netProfit >= 0 ? "text-success" : "text-danger" %>">
                            <%= netProfit >= 0 ? "Profit" : "Loss" %>: ₹<%= String.format("%.3f", Math.abs(netProfit)) %>
                        </span>
                    </div>
                    <div class="mb-3">
                        <strong>Profit Margin:</strong><br>
                        <span class="h5 <%= profitMargin >= 0 ? "text-success" : "text-danger" %>">
                            <%= String.format("%.3f", profitMargin) %>%
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <%
    } else if ("productwise".equals(reportType)) {
        // Get product-wise profit/loss data
        Vector productWiseData = bill.getProductWiseProfitLoss(fromDate, toDate);
        
        // Debug output
        System.out.println("Product Wise Data Size: " + productWiseData.size());
        for (int i = 0; i < Math.min(productWiseData.size(), 3); i++) {
            Vector row = (Vector) productWiseData.elementAt(i);
            System.out.println("Row " + i + ": " + row.toString());
        }
    %>
    <!-- Product Wise Report -->
    <div class="alert alert-info">
        <strong>Product Wise Profit & Loss Analysis</strong><br>
        Shows profitability for each product sold within the selected date range.
        Cost price is taken from last purchase or batch cost if no purchase found.
    </div>

    <% if (productWiseData.size() == 0) { %>
    <div class="alert alert-warning">
        <strong>No Data Found</strong><br>
        No product sales were found in the selected date range (<%= fromDate %> to <%= toDate %>).
        Please check if there are sales records for this period.
    </div>
    <% } else { %>

    <table id="profitLossTable" class="table table-bordered table-striped">
        <thead class="table-dark">
            <tr>
                <th>Product Name</th>
                <th class="text-end">Qty Sold</th>
                <th class="text-end">Avg Sale Price (₹)</th>
                <th class="text-end">Cost Price (₹)</th>
                <th class="text-end">Total Sales (₹)</th>
                <th class="text-end">Total Cost (₹)</th>
                <th class="text-end">Profit/Loss (₹)</th>
                <th class="text-end">Margin (%)</th>
            </tr>
        </thead>
        <tbody>
            <%
            double totalProductProfit = 0.0;
            double totalProductSales = 0.0;
            double totalProductCost = 0.0;
            
            for (int i = 0; i < productWiseData.size(); i++) {
                Vector row = (Vector) productWiseData.elementAt(i);
                String productName = (String) row.elementAt(0);
                String qtySold = (String) row.elementAt(1);
                String avgSalePrice = (String) row.elementAt(2);
                String costPrice = (String) row.elementAt(3);
                String productTotalSales = (String) row.elementAt(4);
                String productTotalCost = (String) row.elementAt(5);
                String productProfitLoss = (String) row.elementAt(6);
                String productProfitMargin = (String) row.elementAt(7);
                
                double profit = Double.parseDouble(productProfitLoss);
                double sales = Double.parseDouble(productTotalSales);
                double cost = Double.parseDouble(productTotalCost);
                
                totalProductProfit += profit;
                totalProductSales += sales;
                totalProductCost += cost;
                
                String rowClass = profit >= 0 ? "table-success" : "table-danger";
            %>
            <tr class="<%= rowClass %>">
                <td><strong><%= productName %></strong></td>
                <td class="text-end"><%= qtySold %></td>
                <td class="text-end"><%= avgSalePrice %></td>
                <td class="text-end"><%= costPrice %></td>
                <td class="text-end"><%= productTotalSales %></td>
                <td class="text-end"><%= productTotalCost %></td>
                <td class="text-end"><strong><%= productProfitLoss %></strong></td>
                <td class="text-end"><strong><%= productProfitMargin %>%</strong></td>
            </tr>
            <%
            }
            %>
        </tbody>
        <tfoot class="table-dark">
            <tr>
                <th><strong>TOTAL</strong></th>
                <th class="text-end">-</th>
                <th class="text-end">-</th>
                <th class="text-end">-</th>
                <th class="text-end"><strong><%= String.format("%.3f", totalProductSales) %></strong></th>
                <th class="text-end"><strong><%= String.format("%.3f", totalProductCost) %></strong></th>
                <th class="text-end <%= totalProductProfit >= 0 ? "text-success" : "text-danger" %>"><strong><%= String.format("%.3f", totalProductProfit) %></strong></th>
                <th class="text-end <%= totalProductProfit >= 0 ? "text-success" : "text-danger" %>"><strong><%= String.format("%.3f", totalProductSales > 0 ? (totalProductProfit/totalProductSales)*100 : 0) %>%</strong></th>
            </tr>
        </tfoot>
    </table>

    <div class="row mt-3">
        <div class="col-md-6">
            <div class="card <%= totalProductProfit >= 0 ? "border-success" : "border-danger" %>">
                <div class="card-header <%= totalProductProfit >= 0 ? "bg-success" : "bg-danger" %> text-white">
                    <h5 class="card-title mb-0">Product Wise Summary</h5>
                </div>
                <div class="card-body">
                    <div class="mb-2">
                        <strong>Total Products Sold:</strong> <%= productWiseData.size() %>
                    </div>
                    <div class="mb-2">
                        <strong>Total Sales:</strong> ₹<%= String.format("%.3f", totalProductSales) %>
                    </div>
                    <div class="mb-2">
                        <strong>Total Cost:</strong> ₹<%= String.format("%.3f", totalProductCost) %>
                    </div>
                    <hr>
                    <div class="mb-2">
                        <strong>Net <%= totalProductProfit >= 0 ? "Profit" : "Loss" %>:</strong>
                        <span class="h5 <%= totalProductProfit >= 0 ? "text-success" : "text-danger" %>">
                            ₹<%= String.format("%.3f", Math.abs(totalProductProfit)) %>
                        </span>
                    </div>
                    <div class="mb-2">
                        <strong>Overall Margin:</strong>
                        <span class="h5 <%= totalProductProfit >= 0 ? "text-success" : "text-danger" %>">
                            <%= String.format("%.3f", totalProductSales > 0 ? (totalProductProfit/totalProductSales)*100 : 0) %>%
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <% } %>
    <%
    } else {
    %>
    <!-- Detailed Report -->
    <div class="alert alert-info">
        <strong>Detailed Profit & Loss Report</strong><br>
        Comprehensive breakdown including sales, purchases, operating expenses, and net profit/loss.
    </div>

    <table id="profitLossTable" class="table table-bordered">
        <thead class="table-dark">
            <tr>
                <th>Period</th>
                <th class="text-end">Sales (₹)</th>
                <th class="text-end">Purchases (₹)</th>
                <th class="text-end">Gross Profit (₹)</th>
                <th class="text-end">Expenses (₹)</th>
                <th class="text-end">Net Profit (₹)</th>
                <th class="text-end">Net Margin (%)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><strong><%= fromDate %> to <%= toDate %></strong></td>
                <td class="text-end"><%= String.format("%.3f", totalSales) %></td>
                <td class="text-end"><%= String.format("%.3f", totalPurchases) %></td>
                <td class="text-end <%= grossProfit >= 0 ? "text-success" : "text-warning" %>"><%= String.format("%.3f", grossProfit) %></td>
                <td class="text-end text-info"><%= String.format("%.3f", totalExpenses) %></td>
                <td class="text-end <%= netProfit >= 0 ? "text-success" : "text-danger" %>"><strong><%= String.format("%.3f", netProfit) %></strong></td>
                <td class="text-end <%= profitMargin >= 0 ? "text-success" : "text-danger" %>"><strong><%= String.format("%.3f", profitMargin) %>%</strong></td>
            </tr>
        </tbody>
        <tfoot class="table-secondary">
            <tr>
                <th>Summary</th>
                <th class="text-end">Revenue</th>
                <th class="text-end">COGS</th>
                <th class="text-end">Gross P/L</th>
                <th class="text-end">Op. Expenses</th>
                <th class="text-end">Net P/L</th>
                <th class="text-end">Margin</th>
            </tr>
        </tfoot>
    </table>
    
    <!-- Expense Breakdown -->
    <%
    Vector expenseDetails = prod.getExpenseReport(fromDate, toDate, 0);
    if (expenseDetails != null && expenseDetails.size() > 0) {
    %>
    <div class="mt-4">
        <h5>Operating Expenses Breakdown</h5>
        <table class="table table-bordered table-sm">
            <thead class="table-light">
                <tr>
                    <th>Date & Time</th>
                    <th>Expense Type</th>
                    <th>Content</th>
                    <th>Description</th>
                    <th class="text-end">Amount (₹)</th>
                </tr>
            </thead>
            <tbody>
                <%
                DecimalFormat df = new DecimalFormat("#,##0.00");
                for (int i = 0; i < expenseDetails.size(); i++) {
                    Vector row = (Vector) expenseDetails.get(i);
                    String expDateTime = row.get(0).toString();
                    String expenseType = row.get(1).toString();
                    String content = row.get(2).toString();
                    String description = row.get(3).toString();
                    double amount = Double.parseDouble(row.get(4).toString());
                %>
                <tr>
                    <td><%= new SimpleDateFormat("dd MMM yyyy HH:mm").format(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(expDateTime)) %></td>
                    <td><span class="badge bg-info"><%= expenseType %></span></td>
                    <td><%= content %></td>
                    <td><%= description.isEmpty() ? "-" : description %></td>
                    <td class="text-end text-danger">₹ <%= df.format(amount) %></td>
                </tr>
                <%
                }
                %>
            </tbody>
            <tfoot class="table-secondary">
                <tr>
                    <th colspan="4" class="text-end">Total Operating Expenses:</th>
                    <th class="text-end text-danger">₹ <%= String.format("%.3f", totalExpenses) %></th>
                </tr>
            </tfoot>
        </table>
    </div>
    <% } else { %>
    <div class="alert alert-secondary mt-3">
        <i class="fas fa-info-circle"></i> No operating expenses recorded for this period.
    </div>
    <% } %>
    <%
    }
    %>
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
    h3 {
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
    const table = document.getElementById('profitLossTable');
    const filename = 'Profit_Loss_Report.xls';
    
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
</script>

</body>
</html>