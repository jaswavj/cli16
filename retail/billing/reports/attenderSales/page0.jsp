<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page language="java" import="java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%
String contextPath = request.getContextPath();
String fromDate = request.getParameter("fromDate");  
String toDate = request.getParameter("toDate");

String attenderParam = request.getParameter("attenderId");
int attenderId = 0;
String attenderName = "All Attenders";
if (attenderParam != null && !attenderParam.isEmpty()) {
    attenderId = Integer.parseInt(attenderParam);
    if (attenderId > 0) {
        // Get attender name
        Vector attenderList = prod.getActiveAttenders();
        for (int i = 0; i < attenderList.size(); i++) {
            Vector row = (Vector) attenderList.elementAt(i);
            if ((Integer)row.get(0) == attenderId) {
                attenderName = row.get(1).toString();
                String code = row.get(2) != null ? row.get(2).toString() : "";
                if (!code.isEmpty()) {
                    attenderName += " (" + code + ")";
                }
                break;
            }
        }
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attender-Wise Sales Report</title>
    <jsp:include page="/assets/common/head.jsp" />
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="container mt-4">
        <p><strong>Attender-Wise Sales Report</strong></p>
        <p><strong>Period:</strong> <%= fromDate %> to <%= toDate %></p>
        <p><strong>Attender:</strong> <%= attenderName %></p>
        
        <div class="mb-3 no-print">
            <a href="<%=contextPath%>/reports/attenderSales/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
            <button class="btn btn-primary btn-sm" onclick="printReport()">🖨 Print</button>
            <button class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Attender_Sales_Report')">📊 Export to Excel</button>
        </div>

        <div class="table-responsive">
            <table id="printTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 12px;">
                <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                    <tr>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bill No</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Customer Name</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Discount</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Payable</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
                        <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Attender</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Vector vec = bill.getAttenderWiseSalesReport(fromDate, toDate, attenderId);
                    double finTotal = 0.0;
                    double finDiscount = 0.0;
                    double finPayable = 0.0; 
                    double finPaid = 0.0;
                    double finBalance = 0.0;
                    
                    for (int i = 0; i < vec.size(); i++) {
                        Vector row = (Vector) vec.elementAt(i);
                        String billNo = row.elementAt(0).toString();
                        double totalAmt = Double.parseDouble(row.elementAt(1).toString());
                        double discount = Double.parseDouble(row.elementAt(2).toString());
                        double payable = Double.parseDouble(row.elementAt(3).toString());
                        double paid = Double.parseDouble(row.elementAt(4).toString());
                        String date = row.elementAt(5).toString();
                        String time = row.elementAt(6).toString();
                        String cusName = row.elementAt(7).toString();
                        double balance = Double.parseDouble(row.elementAt(8).toString());
                        String attender = row.elementAt(9).toString();
                        
                        finTotal += totalAmt;
                        finDiscount += discount;  
                        finPayable += payable;
                        finPaid += paid;
                        finBalance += balance;
                    %>
                    <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                            <a href="<%=contextPath%>/billing/print.jsp?billNo=<%=billNo%>" target="_blank" class="btn btn-sm btn-edit" style="background-color:#5a9fd4; color:#fff;"><%=billNo%></a>
                        </td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=cusName%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.2f", totalAmt)%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.2f", discount)%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.2f", payable)%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.2f", paid)%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.2f", balance)%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=date%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=time%></td>
                        <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=attender%></td>
                    </tr>
                    <%
                    }
                    %>
                    <tr style="background: #f7fafc; border-top: 2px solid #4a5568;">
                        <td colspan="3" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong>Grand Total</strong></td>
                        <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.2f", finTotal)%></strong></td>
                        <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.2f", finDiscount)%></strong></td>
                        <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.2f", finPayable)%></strong></td>
                        <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.2f", finPaid)%></strong></td>
                        <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.2f", finBalance)%></strong></td>
                        <td colspan="3" style="padding: 0.4rem; border: none;"></td>
                    </tr>
                </tbody>
            </table>
        </div>
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
            
            if (navigator.msSaveOrOpenBlob) {
                var blob = new Blob(['\ufeff', tableHTML], {
                    type: dataType
                });
                navigator.msSaveOrOpenBlob(blob, filename);
            } else {
                downloadLink.href = 'data:' + dataType + ', ' + tableHTML;
                downloadLink.download = filename;
                downloadLink.click();
            }
        }
    </script>

    <style>
        @media print {
            .no-print {
                display: none;
            }
            body {
                margin: 0;
                padding: 10px;
            }
            .container {
                max-width: 100%;
            }
        }
    </style>
</body>
</html>
