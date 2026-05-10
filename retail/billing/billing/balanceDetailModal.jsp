<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="user" class="user.userBean" />
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
    
    String head3 = user.getHead3();

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

<div class="container-fluid p-0">
    <h5 class="mb-3">Bill No: <%= billId %></h5>
    
    <div class="table-responsive">
        <table class="table table-bordered table-sm">
            <thead style="background: linear-gradient(135deg, #3d1a52, #570a57);">
                <tr>
                    <th style="color: #fff;">S.No</th>
                    <th style="color: #fff;"><%=head3%></th>
                    <th style="color: #fff;">Qty</th>
                    <th style="color: #fff;">Price</th>
                    <th style="color: #fff;">Discount</th>
                    <th style="color: #fff;">Total</th>
                </tr>
            </thead>
            <tbody>
            <%
                for (int i = 0; i < details.size(); i++) {
                    Vector row = (Vector) details.elementAt(i);
            %>
                <tr>
                    <td><%= i+1 %></td>
                    <td><%= row.elementAt(3) %></td>
                    <td><%= row.elementAt(4) %></td>
                    <td><%= row.elementAt(5) %></td>
                    <td><%= row.elementAt(6) %></td>
                    <td><%= row.elementAt(7) %></td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
    
    <div class="row mt-3">
        <div class="col-md-8 offset-md-2">
            <table class="table table-bordered table-sm">
                <tr>
                    <th style="background-color: #f8f9fa;">Total</th>
                    <td><%= total %></td>
                </tr>
                <tr>
                    <th style="background-color: #f8f9fa;"><%=head3%> Discount</th>
                    <td><%= prodDiscount %></td>
                </tr>
                <tr>
                    <th style="background-color: #f8f9fa;">Extra Discount</th>
                    <td><%= extraDiscount %></td>
                </tr>
                <tr>
                    <th style="background-color: #f8f9fa;">Payable</th>
                    <td><%= payable %></td>
                </tr>
                <tr style="background-color: #d4edda;">
                    <th>Paid</th>
                    <td><%= paid %></td>
                </tr>
                <tr style="background-color: #d4edda;">
                    <th>Cash Paid</th>
                    <td><%= cash %></td>
                </tr>
                <tr style="background-color: #d4edda;">
                    <th>Bank Paid</th>
                    <td><%= bank %></td>
                </tr>
                <tr style="background-color: #f8d7da;">
                    <th>Balance</th>
                    <td><%= balance %></td>
                </tr>
                <tr style="background-color: #f8d7da;">
                    <th>Current Balance</th>
                    <td><%= currentBalance %></td>
                </tr>
            </table>
        </div>
    </div>
</div>
