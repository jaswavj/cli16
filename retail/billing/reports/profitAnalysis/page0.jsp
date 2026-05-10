<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String contextPath = request.getContextPath();
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Profit Analysis Report</title>
    <jsp:include page="/assets/common/head.jsp" />
</head>
<body > 
    <jsp:include page="/assets/navbar/navbar.jsp" />

<div class="container mt-4 ">
<p><strong>Profit Analysis Report From:</strong> <%= fromDate %> - <%= toDate %></p>
    <div class="mb-3 no-print">
        <a href="<%=contextPath%>/reports/profitAnalysis/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
        <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
        <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Profit_Analysis_Report')">📊 Export to Excel</button>
    </div>

<%
        Vector vec = bill.getProfitAnalysisReport(fromDate, toDate);
        double totalCostSum = 0.0;
        double totalSaleSum = 0.0;
        double totalProfitSum = 0.0;
        
        for(int i = 0; i < vec.size(); i++) {
            Vector row = (Vector)vec.elementAt(i);
            double totalCost = Double.parseDouble(row.elementAt(4).toString());
            double saleTotal = Double.parseDouble(row.elementAt(5).toString());
            double profit = saleTotal - totalCost;
            
            totalCostSum += totalCost;
            totalSaleSum += saleTotal;
            totalProfitSum += profit;
        }
        double overallProfitPercent = (totalCostSum > 0) ? (totalProfitSum / totalCostSum) * 100 : 0;
%>

<!-- Summary Cards -->
<div class="row mb-4 g-3">
    <div class="col-md-3">
        <div class="card border-info">
            <div class="card-body">
                <h6 class="text-muted">Total Cost</h6>
                <h4 class="text-info">&#8377; <%= String.format("%,.2f", totalCostSum) %></h4>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-primary">
            <div class="card-body">
                <h6 class="text-muted">Total Sales</h6>
                <h4 class="text-primary">&#8377; <%= String.format("%,.2f", totalSaleSum) %></h4>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-success">
            <div class="card-body">
                <h6 class="text-muted">Total Profit</h6>
                <h4 class="<%= totalProfitSum >= 0 ? "text-success" : "text-danger" %>">&#8377; <%= String.format("%,.2f", totalProfitSum) %></h4>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card border-warning">
            <div class="card-body">
                <h6 class="text-muted">Profit Margin</h6>
                <h4 class="<%= overallProfitPercent >= 0 ? "text-success" : "text-danger" %>"><%= String.format("%.1f", overallProfitPercent) %>%</h4>
            </div>
        </div>
    </div>
</div>

<div class="table-responsive">
<table id="printTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 12px;">
    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
        <tr>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bill No</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Product</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Qty</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Cost Price</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total Cost</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Sale Total</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Profit</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Profit %</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
        </tr>
    </thead>
    <tbody>
        <%
        for(int i = 0; i < vec.size(); i++) {
            Vector row = (Vector)vec.elementAt(i);
            String billNo = row.elementAt(0).toString();
            String productName = row.elementAt(1).toString();
            double qty = Double.parseDouble(row.elementAt(2).toString());
            double costPrice = Double.parseDouble(row.elementAt(3).toString());
            double totalCost = Double.parseDouble(row.elementAt(4).toString());
            double saleTotal = Double.parseDouble(row.elementAt(5).toString());
            double profit = saleTotal - totalCost;
            double profitPercent = (totalCost > 0) ? (profit / totalCost) * 100 : 0;
            String billDate = row.elementAt(6).toString();
            
            //totalCostSum += totalCost;
            //totalSaleSum += saleTotal;
            //totalProfitSum += profit;
            
            String rowColor = (i % 2 == 0) ? "#ffffff" : "#f8f9fa";
        %><td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0;"><%= i + 1 %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0;"><%= billNo %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0;"><%= productName %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0; text-align: center;"><%= qty %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0; text-align: right;">&#8377; <%= String.format("%.3f", costPrice) %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0; text-align: right;">&#8377; <%= String.format("%.3f", totalCost) %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0; text-align: right;">&#8377; <%= String.format("%.3f", saleTotal) %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0; text-align: right; color: <%= profit >= 0 ? "#10b981" : "#ef4444" %>; font-weight: 600;">&#8377; <%= String.format("%.3f", profit) %></td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0; text-align: right; color: <%= profitPercent >= 0 ? "#10b981" : "#ef4444" %>"><%= String.format("%.1f", profitPercent) %>%</td>
            <td style="padding: 0.5rem; border: none; border-bottom: 1px solid #e2e8f0;"><%= billDate %></td>
        </tr>
        <%
        }
        %>
    </tbody>
    <tfoot style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); font-weight: 700;">
            <td colspan="5" style="padding: 0.75rem; text-align: right; border: none; font-size: 0.9rem;">Grand Total:</td>
            <td style="padding: 0.75rem; text-align: right; border: none; font-size: 0.9rem;">&#8377; <%= String.format("%,.2f", totalCostSum) %></td>
            <td style="padding: 0.75rem; text-align: right; border: none; font-size: 0.9rem;">&#8377; <%= String.format("%,.2f", totalSaleSum) %></td>
            <td style="padding: 0.75rem; text-align: right; border: none; font-size: 0.9rem; color: <%= totalProfitSum >= 0 ? "#10b981" : "#ef4444" %>">&#8377; <%= String.format("%,.2f", totalProfitSum) %></td>
            <td style="padding: 0.75rem; text-align: right; border: none; font-size: 0.9rem; color: <%= overallProfitPercent >= 0 ? "#10b981" : "#ef4444" %>"><%= String.format("%.1f", overallProfitPercent) %>%</td>
            <td style="border: none;"></td>
        </tr>
    </tfoot>
</table>
</div>

<!-- Summary Cards -->

</div>

<script>
function printReport() {
    window.print();
}

function exportTableToExcel(tableID, filename = '') {
    var downloadLink;
    var dataType = 'application/vnd.ms-excel';
    var tableSelect = document.getElementById(tableID);
    var tableHTML = tableSelect.outerHTML.replace(/ /g, '%20');
    
    filename = filename ? filename + '.xls' : 'excel_data.xls';
    
    downloadLink = document.createElement("a");
    
    document.body.appendChild(downloadLink);
    
    if(navigator.msSaveOrOpenBlob){
        var blob = new Blob(['\ufeff', tableHTML], {
            type: dataType
        });
        navigator.msSaveOrOpenBlob( blob, filename);
    } else {
        downloadLink.href = 'data:' + dataType + ', ' + tableHTML;
        downloadLink.download = filename;
        downloadLink.click();
    }
}
</script>

<style>
@media print {
    .no-print, .btn, .navbar, .sidebar {
        display: none !important;
    }
    .container {
        max-width: 100% !important;
    }
}
</style>

</body>
</html>
