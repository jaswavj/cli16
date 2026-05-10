<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
    int billId = Integer.parseInt(request.getParameter("billId"));
    Vector details = bill.getBillDetails(billId);
    double total = 0;
double prodDiscount = 0;
double extraDiscount = 0;
double payable = 0;
double paid = 0;
double cash = 0;
double bank = 0;
double balance = 0;
double currentBalance = 0;

Vector billInfo = bill.getExtraDisc(billId);
if (billInfo != null && !billInfo.isEmpty()) {
    total        = Double.parseDouble(billInfo.elementAt(0).toString());
    prodDiscount = Double.parseDouble(billInfo.elementAt(1).toString());
    extraDiscount= Double.parseDouble(billInfo.elementAt(2).toString());
    payable      = Double.parseDouble(billInfo.elementAt(3).toString());
    paid         = Double.parseDouble(billInfo.elementAt(4).toString());
    cash         = Double.parseDouble(billInfo.elementAt(5).toString());
    bank         = Double.parseDouble(billInfo.elementAt(6).toString());
    balance      = Double.parseDouble(billInfo.elementAt(7).toString());
    currentBalance      = Double.parseDouble(billInfo.elementAt(8).toString());
} else {
    out.print("<p style='color:red'>No bill info found for Bill No: " + billId + "</p>");
}

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bill Details</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
<%@ include file="/assets/common/head.jsp" %>
    
 
</head>
<body onload="document.form.opregInput.focus();">

<!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h4>Bill Details (Bill No: <%= billId %>)</h4>
    <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
        <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
            <tr>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Product</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Qty</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Price</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Discount</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total</th>
            </tr>
        </thead>
        <tbody>
        <%
            for (int i = 0; i < details.size(); i++) {
                Vector row = (Vector) details.elementAt(i);
        %>
            <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= i+1 %></td>
                <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.elementAt(3) %></td> <!-- product_name -->
                <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.elementAt(4) %></td> <!-- qty -->
                <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.elementAt(5) %></td> <!-- price -->
                <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.elementAt(6) %></td> <!-- discount -->
                <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= row.elementAt(7) %></td> <!-- total -->
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
    <div class="row mt-4">
        <div class="col-md-6 offset-md-6">
            <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= total %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Product Discount</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= prodDiscount %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Extra Discount</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= extraDiscount %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Payable</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= payable %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s; background-color: #f0fdf4;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= paid %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s; background-color: #f0fdf4;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Cash Paid</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= cash %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s; background-color: #f0fdf4;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bank Paid</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= bank %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s; background-color: #fee;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= balance %></td>
                </tr>
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s; background-color: #fee;">
                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Pending Balance</th>
                    <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%= currentBalance %></td>
                </tr>
            </table>
        </div>
    </div>
</div>
    <!-- Bootstrap JS -->

</body>
</html>
