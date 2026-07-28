<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="prod" class="product.productBean" />
<%!
private String formatTime12(String timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty()) {
        return "-";
    }
    String value = timeStr.trim();
    String[] patterns = {
        "HH:mm:ss", "H:mm:ss", "HH:mm", "H:mm",
        "hh:mm:ss a", "h:mm:ss a", "hh:mm a", "h:mm a"
    };
    for (int i = 0; i < patterns.length; i++) {
        try {
            SimpleDateFormat in = new SimpleDateFormat(patterns[i], Locale.ENGLISH);
            in.setLenient(false);
            Date parsed = in.parse(value);
            SimpleDateFormat out = new SimpleDateFormat("hh:mm a", Locale.ENGLISH);
            return out.format(parsed);
        } catch (Exception ignore) {}
    }
    return value;
}

private String formatDateDDMMYYYY(String dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty()) {
        return "-";
    }
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
            SimpleDateFormat out = new SimpleDateFormat("dd-MM-yyyy", Locale.ENGLISH);
            return out.format(parsed);
        } catch (Exception ignore) {}
    }
    return value;
}
%>
<%
String contextPath = request.getContextPath();
    String fromDate = request.getParameter("fromDate");  
    String toDate   = request.getParameter("toDate");
    
    String modeParam = request.getParameter("mode");
    int modeId = 0;
    if (modeParam != null && !modeParam.isEmpty()) {
        modeId = Integer.parseInt(modeParam);
    }
    
    String userParam = request.getParameter("userId");
    int userId = 0;
    if (userParam != null && !userParam.isEmpty()) {
        userId = Integer.parseInt(userParam);
    }
    
    String typeParam = request.getParameter("type");
    int typeId = 0;
    if (typeParam != null && !typeParam.isEmpty()) {
        typeId = Integer.parseInt(typeParam);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    
    <meta charset="UTF-8">
    <title>Collection Report</title>
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

    /* Column widths via colgroup — screen (with Approved column) */
    @media screen {
        .sales-report-wrap #printTable col.col-w-sno { width: 3%; }
        .sales-report-wrap #printTable col.col-w-approved { width: 6%; }
        .sales-report-wrap #printTable col.col-w-bill { width: 6%; }
        .sales-report-wrap #printTable col.col-w-name,
        .sales-report-wrap #printTable col.col-w-item { width: 14%; }
        .sales-report-wrap #printTable col.col-w-amt { width: 7.7%; }

        .sales-report-wrap #printTable th {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .sales-report-wrap #printTable th.col-approved {
            font-size: 0.68rem !important;
            line-height: 1.1;
            white-space: normal;
            word-break: break-word;
            padding-inline: 0.15rem !important;
        }

        .sales-report-wrap #printTable th:nth-child(1),
        .sales-report-wrap #printTable td:nth-child(1) { text-align: center; padding-inline: 0.2rem !important; }
        .sales-report-wrap #printTable th:nth-child(2),
        .sales-report-wrap #printTable td:nth-child(2) { text-align: center; padding-inline: 0.15rem !important; }
        .sales-report-wrap #printTable th:nth-child(6),
        .sales-report-wrap #printTable td:nth-child(6),
        .sales-report-wrap #printTable th:nth-child(7),
        .sales-report-wrap #printTable td:nth-child(7),
        .sales-report-wrap #printTable th:nth-child(8),
        .sales-report-wrap #printTable td:nth-child(8),
        .sales-report-wrap #printTable th:nth-child(9),
        .sales-report-wrap #printTable td:nth-child(9),
        .sales-report-wrap #printTable th:nth-child(10),
        .sales-report-wrap #printTable td:nth-child(10) { text-align: right; white-space: nowrap; }
        .sales-report-wrap #printTable th:nth-child(3),
        .sales-report-wrap #printTable td:nth-child(3),
        .sales-report-wrap #printTable th:nth-child(11),
        .sales-report-wrap #printTable td:nth-child(11),
        .sales-report-wrap #printTable th:nth-child(12),
        .sales-report-wrap #printTable td:nth-child(12) { white-space: nowrap; }

        .sales-report-wrap #printTable .col-item-name,
        .sales-report-wrap #printTable .col-name {
            max-width: 0;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .sales-report-wrap #printTable .col-datetime {
            max-width: 0;
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

    .sales-report-wrap .approve-chk {
        transform: scale(1.05);
        margin: 0;
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
</style>




</head>
<body > 

    <jsp:include page="/assets/navbar/navbar.jsp" />



<div class="container mt-4 sales-report-wrap">
<p class="report-title"><strong>Collection Report From:</strong> <%= formatDateDDMMYYYY(fromDate) %> - <%= formatDateDDMMYYYY(toDate) %></p>
    <div class="mb-3 no-print">
        <a href="<%=contextPath%>/reports/sales/page.jsp" class="btn btn-secondary btn-sm me-2">⬅ Back</a>
        <button id="printBtn" class="btn btn-primary btn-sm" onclick="printReport()" disabled>🖨 Print</button>
        <button id="exportBtn" class="btn btn-success btn-sm" onclick="exportTableToExcel('printTable', 'Sales_Report')" disabled>📊 Export to Excel</button>
    </div>
<div class="table-responsive">
<table id="printTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 13px;">
    <colgroup>
        <col class="col-w-sno">
        <col class="col-w-approved no-print">
        <col class="col-w-bill">
        <col class="col-w-name">
        <col class="col-w-item">
        <col class="col-w-amt">
        <col class="col-w-amt">
        <col class="col-w-amt">
        <col class="col-w-amt">
        <col class="col-w-amt">
        <col class="col-w-amt">
        <col class="col-w-amt">
    </colgroup>
    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
        <tr>
            <th class="col-sno" style="padding: 0.28rem 0.2rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">#</th>
            <th class="no-print col-approved" style="padding: 0.28rem 0.15rem; font-weight: 600; color: #4a5568; border: none; text-align:center;">Appr.</th>
            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Bill No</th>
            <th class="col-name" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Name</th>
            <th class="col-item-name" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Item Name</th>
            <th class="col-amt col-amt-num" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Price</th>
            <th class="col-amt col-amt-num" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Courier</th>
            <th class="col-amt col-amt-num" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Total</th>
            <th class="col-amt col-amt-num" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Paid</th>
            <th class="col-amt col-amt-num" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Balance</th>
            <th class="col-amt col-datetime" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Date</th>
            <th class="col-amt" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.88rem;">Staff</th>
            
        </tr>
    </thead>
    <tbody>
        <%
        Vector vec = bill.getsalesCashBankReport(fromDate,toDate,modeId,typeId,userId);
        double finPrice=0.0;
        double finCourier=0.0;
        double finTotal=0.0;
        double finPaid=0.0;
        double finBalance=0.0;
        for(int i=0;i< vec.size();i++)
		{
            Vector row		= (Vector)vec.elementAt(i);
            int billId		= Integer.parseInt(row.elementAt(8).toString());  
            int isApproved = bill.getBillApprovalStatus(billId);
            double paid        = Double.parseDouble(row.elementAt(4).toString());
            double Balance       = Double.parseDouble(row.elementAt(12).toString());
            String billNo    = row.elementAt(0).toString();
            finPaid+=paid;
            finBalance+=Balance;
            String cusPhone = row.elementAt(15).toString();
            Vector itemDetails = bill.getBillDetailsUsingNo(billNo);
            String itemName = "-";
            double itemPrice = 0.0;
            double itemCourier = 0.0;
            double itemTotal = 0.0;

            if (itemDetails != null && itemDetails.size() > 0) {
                Vector itemRow = (Vector) itemDetails.elementAt(0);
                if (itemRow.size() > 0 && itemRow.elementAt(0) != null) itemName = itemRow.elementAt(0).toString();
                if (itemRow.size() > 2 && itemRow.elementAt(2) != null && !itemRow.elementAt(2).toString().trim().isEmpty()) {
                    try { itemPrice = Double.parseDouble(itemRow.elementAt(2).toString()); } catch (Exception e) { itemPrice = 0.0; }
                }
                if (itemRow.size() > 10 && itemRow.elementAt(10) != null && !itemRow.elementAt(10).toString().trim().isEmpty()) {
                    try { itemCourier = Double.parseDouble(itemRow.elementAt(10).toString()); } catch (Exception e) { itemCourier = 0.0; }
                }
                if (itemRow.size() > 4 && itemRow.elementAt(4) != null && !itemRow.elementAt(4).toString().trim().isEmpty()) {
                    try { itemTotal = Double.parseDouble(itemRow.elementAt(4).toString()); } catch (Exception e) { itemTotal = 0.0; }
                }
            }

            finPrice += itemPrice;
            finCourier += itemCourier;
            finTotal += itemTotal;
            


        %>
        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
            <td class="no-print" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; text-align:center;">
                <input type="checkbox" class="approve-chk" data-bill-id="<%=billId%>" onchange="approveBill(this)" <%=isApproved == 1 ? "checked disabled" : ""%>>
            </td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=billNo%></td>
            <td class="col-name" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                <div class="cell-stack">
                    <div>
                        <a href="<%=contextPath%>/billing/print.jsp?billNo=<%=billNo%>" target="_blank" style="color:#2563eb; text-decoration:none; font-weight:500;">
                            <%=row.elementAt(14)%>
                        </a>
                    </div>
                    <div class="cell-sub">
                        <% if (cusPhone != null && !cusPhone.trim().isEmpty()) { %>
                            <a href="https://wa.me/<%=cusPhone%>" target="_blank"><%=cusPhone%></a>
                        <% } else { %>
                            -
                        <% } %>
                    </div>
                </div>
            </td>
            <td class="col-item-name" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;" title="<%=itemName%>"><%=itemName%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.1f", itemPrice)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.1f", itemCourier)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.1f", itemTotal)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(4)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(12)%></td>
            <td class="col-datetime" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                <div class="cell-stack">
                    <div><%=formatDateDDMMYYYY(row.elementAt(5).toString())%></div>
                    <div class="cell-sub"><%=formatTime12(row.elementAt(6).toString())%></div>
                </div>
            </td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(7)%></td>
        </tr>
        <%
        }

        Vector dueDetails = bill.getDuePaidList(fromDate, toDate, userId);
        int serialNo = vec.size();
        for (int j = 0; j < dueDetails.size(); j++) {
            Vector row = (Vector) dueDetails.elementAt(j);

            String cusName     = row.elementAt(0).toString();
            String date        = row.elementAt(6).toString();
            String time        = row.elementAt(7).toString();
            String userName    = row.elementAt(8).toString();
            String billDisplay = row.elementAt(9).toString();
            int dueCollectionId = Integer.parseInt(row.elementAt(11).toString());
            int dueIsApproved  = Integer.parseInt(row.elementAt(12).toString());
            double finalDueBalance = 0.0;
            try { finalDueBalance = Double.parseDouble(row.elementAt(13).toString()); } catch (Exception e) { finalDueBalance = 0.0; }
            String cusPhone    = bill.getCusNumber(billDisplay);

            double cashPaid = Double.parseDouble(row.elementAt(2).toString());
            double bankPaid = Double.parseDouble(row.elementAt(3).toString());
            double totalPaid = cashPaid + bankPaid;

            Vector dueItemDetails = bill.getBillDetailsUsingNo(billDisplay);
            String dueItemName = "-";
            if (dueItemDetails != null && dueItemDetails.size() > 0) {
                Vector dueItemRow = (Vector) dueItemDetails.elementAt(0);
                if (dueItemRow.size() > 0 && dueItemRow.elementAt(0) != null) {
                    dueItemName = dueItemRow.elementAt(0).toString();
                }
            }

            finPaid += totalPaid;
            finBalance += finalDueBalance;
            serialNo++;
        %>
        <tr class="due-row" style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=serialNo%></td>
            <td class="no-print" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem; text-align:center;">
                <input type="checkbox" class="approve-chk" data-kind="due" data-due-collection-id="<%=dueCollectionId%>" onchange="approveBill(this)" <%=dueIsApproved == 1 ? "checked disabled" : ""%>>
            </td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=billDisplay%></td>
            <td class="col-name" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                <div class="cell-stack">
                    <div>
                        <a href="<%=contextPath%>/billing/print.jsp?billNo=<%=billDisplay%>" target="_blank" style="color:#2563eb; text-decoration:none; font-weight:500;"><%=cusName%></a>
                    </div>
                    <div class="cell-sub">
                        <% if (cusPhone != null && !cusPhone.trim().isEmpty()) { %>
                            <a href="https://wa.me/<%=cusPhone%>" target="_blank"><%=cusPhone%></a>
                        <% } else { %>
                            -
                        <% } %>
                    </div>
                </div>
            </td>
            <td class="col-item-name" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;" title="<%=dueItemName%>"><%=dueItemName%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">0.0</td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">0.0</td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">0.0</td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.1f", totalPaid)%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=String.format("%.1f", finalDueBalance)%></td>
            <td class="col-datetime" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                <div class="cell-stack">
                    <div><%=formatDateDDMMYYYY(date)%></div>
                    <div class="cell-sub"><%=formatTime12(time)%></div>
                </div>
            </td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=userName%></td>
        </tr>
        <% } %>
        <tr style="background: #f7fafc; border-top: 2px solid #4a5568;">
            <td colspan="5" class="grand-total-label" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong>Grand Total</strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.1f", finPrice)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.1f", finCourier)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.1f", finTotal)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%=String.format("%.1f", finPaid)%></strong></td>
            <td style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.9rem;"><strong><%//=String.format("%.1f", finBalance)%></strong></td>
            <td style="padding: 0.4rem; border: none;"></td>
            <td style="padding: 0.4rem; border: none;"></td>
        </tr>
    </tbody>
</table>
</div>
</div>

<style>
.due-row td {
    background: #ffeaea !important;
}

@keyframes slideIn {
    from {
        transform: translateX(100%);
        opacity: 0;
    }
    to {
        transform: translateX(0);
        opacity: 1;
    }
}

@keyframes slideOut {
    from {
        transform: translateX(0);
        opacity: 1;
    }
    to {
        transform: translateX(100%);
        opacity: 0;
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

    #printArea .header-box {
        border: 1px solid #000 !important;
        padding: 8px !important;
        margin-bottom: 8px !important;
        text-align: center !important;
    }

    #printArea .header-box h1 {
        font-size: 20px !important;
        margin: 0 0 4px !important;
        color: #000 !important;
        font-weight: 700 !important;
    }

    #printArea .header-box p {
        margin: 2px 0 !important;
        font-weight: 700 !important;
        font-size: 13px !important;
        color: #000 !important;
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

    #printArea #printTable tr.due-row td {
        background: #fff !important;
    }

    #printArea #printTable tr:last-child td {
        font-weight: 700 !important;
        background: #ececec !important;
        border-top: 2px solid #000 !important;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
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
    #printArea #printTable .col-name,
    #printArea #printTable .col-datetime {
        overflow: visible !important;
        text-overflow: clip !important;
        white-space: normal !important;
        word-wrap: break-word !important;
        overflow-wrap: anywhere !important;
        max-width: none !important;
        min-width: 0 !important;
    }

    #printArea #printTable .col-name a {
        overflow: visible !important;
        white-space: normal !important;
        text-overflow: clip !important;
        display: inline !important;
    }

    #printArea #printTable a {
        color: #000 !important;
        text-decoration: none !important;
        font-weight: inherit !important;
    }

    /* Print column widths via colgroup (Approved col removed in JS) */
    #printArea #printTable col.col-w-sno { width: 2.5% !important; }
    #printArea #printTable col.col-w-bill { width: 5% !important; }
    #printArea #printTable col.col-w-name,
    #printArea #printTable col.col-w-item { width: 18% !important; }
    #printArea #printTable col.col-w-amt { width: 8% !important; }

    #printArea #printTable th.col-name,
    #printArea #printTable td.col-name,
    #printArea #printTable th.col-item-name,
    #printArea #printTable td.col-item-name {
        width: 18% !important;
        max-width: none !important;
    }

    #printArea #printTable th.col-amt-num,
    #printArea #printTable td.col-amt-num,
    #printArea #printTable th:nth-child(5),
    #printArea #printTable td:nth-child(5),
    #printArea #printTable th:nth-child(6),
    #printArea #printTable td:nth-child(6),
    #printArea #printTable th:nth-child(7),
    #printArea #printTable td:nth-child(7),
    #printArea #printTable th:nth-child(8),
    #printArea #printTable td:nth-child(8),
    #printArea #printTable th:nth-child(9),
    #printArea #printTable td:nth-child(9) { text-align: right !important; }

    #printArea #printTable th.col-sno,
    #printArea #printTable td.col-sno,
    #printArea #printTable th:nth-child(1),
    #printArea #printTable td:nth-child(1) { text-align: center !important; }
}
</style>

<script>
const reportReloadUrl = '<%=contextPath%>/reports/sales/page0.jsp?fromDate=<%=fromDate%>&toDate=<%=toDate%>&mode=<%=modeId%>&type=<%=typeId%>&userId=<%=userId%>';

// Toast notification function
function showToast(message, type = 'success') {
    const toastColors = {
        success: '#10b981',
        error: '#ef4444',
        info: '#3b82f6'
    };
    
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 12px 20px;
        background-color: ${toastColors[type] || toastColors.success};
        color: white;
        border-radius: 6px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 10000;
        animation: slideIn 0.3s ease-out;
        font-size: 14px;
    `;
    toast.textContent = message;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => document.body.removeChild(toast), 300);
    }, 3000);
}

// Direct thermal print function
function directPrint(billNo) {
    fetch('<%=contextPath%>/billing/directPrint.jsp?billNo=' + billNo, {
        credentials: 'same-origin'
    })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (data.type === 'a4') {
                    // A4 format selected in company settings - open print.jsp
                    window.open('<%=contextPath%>/billing/print.jsp?billNo=' + encodeURIComponent(data.billNo), '_blank');
                    showToast('✓ Opening A4 print preview', 'info');
                } else if (data.type === 'printed') {
                    showToast('✓ Receipt printed successfully!', 'success');
                } else if (data.type === 'txt') {
                    showToast('ℹ No printer found. Receipt saved as TXT file', 'info');
                    alert('Receipt saved to: ' + data.txtPath + '\n\nFile: ' + data.txtFile + '\n\nYou can open this file with Notepad to see how the receipt looks.');
                }
            } else {
                showToast('✗ Print failed: ' + data.message, 'error');
            }
        })
        .catch(error => {
            console.error('Print error:', error);
            showToast('✗ Print failed: ' + error.message, 'error');
        });
}

function updateActionButtons() {
    const checkboxes = document.querySelectorAll('.approve-chk');
    const printBtn = document.getElementById('printBtn');
    const exportBtn = document.getElementById('exportBtn');
    let allApproved = true;

    if (checkboxes.length > 0) {
        for (let i = 0; i < checkboxes.length; i++) {
            if (!checkboxes[i].checked) {
                allApproved = false;
                break;
            }
        }
    }

    printBtn.disabled = !allApproved;
    exportBtn.disabled = !allApproved;
}

function approveBill(checkbox) {
    if (!checkbox.checked) {
        updateActionButtons();
        return;
    }

    const billId = checkbox.getAttribute('data-bill-id');
    const kind = checkbox.getAttribute('data-kind') === 'due' ? 'due' : 'bill';
    const dueCollectionId = checkbox.getAttribute('data-due-collection-id');
    checkbox.disabled = true;

    let requestBody = 'kind=' + encodeURIComponent(kind);
    if (kind === 'due') {
        requestBody += '&dueCollectionId=' + encodeURIComponent(dueCollectionId || '');
    } else {
        requestBody += '&billId=' + encodeURIComponent(billId || '');
    }

    fetch('<%=contextPath%>/reports/sales/updateBillApproval.jsp', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        body: requestBody
    })
    .then(response => response.text())
    .then(data => {
        const result = data.trim();
        if (result === 'OK') {
            showToast('Approval saved', 'success');
            window.location.href = reportReloadUrl;
        } else {
            checkbox.checked = false;
            checkbox.disabled = false;
            showToast(result, 'error');
            window.location.href = reportReloadUrl;
        }
        updateActionButtons();
    })
    .catch(error => {
        checkbox.checked = false;
        checkbox.disabled = false;
        showToast('Failed to save approval: ' + error.message, 'error');
        window.location.href = reportReloadUrl;
        updateActionButtons();
    });
}

document.addEventListener('DOMContentLoaded', function() {
    updateActionButtons();
});

function preparePrintTable(root) {
    root.querySelectorAll('.no-print').forEach(function(el) {
        el.remove();
    });

    var grandTotalLabel = root.querySelector('.grand-total-label');
    if (grandTotalLabel) {
        grandTotalLabel.colSpan = 4;
    }

    root.querySelectorAll('thead, thead tr, thead th, tbody tr, tbody td, tbody th').forEach(function(el) {
        el.removeAttribute('style');
    });

    var table = root.querySelector('#printTable');
    if (table) {
        table.removeAttribute('style');
        table.classList.add('print-ready');

        table.querySelectorAll('tbody tr').forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells.length === 11) {
                cells[0].classList.add('col-sno');
                cells[2].classList.add('col-name');
                cells[3].classList.add('col-item-name');
                for (var i = 4; i <= 8; i++) {
                    cells[i].classList.add('col-amt-num');
                }
                cells[9].classList.add('col-datetime');
            }
        });
    }

    if (root.classList.contains('sales-report-wrap')) {
        root.classList.remove('sales-report-wrap');
    }
}

function printReport() {
    fetch('<%=contextPath%>/printHeader.jsp')
        .then(response => response.text())
        .then(headerHtml => {
            var printArea = document.createElement('div');
            printArea.id = 'printArea';
            printArea.innerHTML = headerHtml;

            var reportWrap = document.querySelector('.sales-report-wrap');
            if (!reportWrap) {
                window.print();
                return;
            }

            var tableClone = reportWrap.cloneNode(true);
            preparePrintTable(tableClone);

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
    tableClone.querySelectorAll('.no-print').forEach(function(el) {
        el.remove();
    });
    var grandTotalLabel = tableClone.querySelector('.grand-total-label');
    if (grandTotalLabel) {
        grandTotalLabel.colSpan = 4;
    }

    // Create HTML content with proper Excel format
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
