<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%


int billId = Integer.parseInt(request.getParameter("billId"));
Vector billDetails = bill.getBillAmount(billId);


       double total = Double.parseDouble(billDetails.get(0).toString());
       double balance = Double.parseDouble(billDetails.get(2).toString());
              double paid = total - balance;
String billNo = (billDetails.size() > 3 && billDetails.get(3) != null) ? billDetails.get(3).toString() : "";


%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Pay Balance - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f8f9fa; }
        h4 { font-weight: 600; }
        .form-label { font-weight: 500; }
    </style>
</head>
<body>
<div class="container-fluid  d-flex flex-column">

    <!-- Navbar -->
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h4 class="mb-4">Pay Balance</h4>
        <% if ("1".equals(request.getParameter("saved"))) { %>
        <div class="alert alert-success">Payment saved successfully.</div>
        <% } %>

        <form id="payForm" action="<%= request.getContextPath() %>/billing/saveDuePayment.jsp" method="post" class="row g-3">
            <input type="hidden" name="billId" value="<%=billId%>">

            <!-- Totals -->
            <div class="col-md-4">
                <label class="form-label">Total</label>
                <input type="text" class="form-control" name="total" id="total"
                       value="<%=total%>" readonly>
            </div>

            <div class="col-md-4">
                <label class="form-label">Paid</label>
                <input type="text" class="form-control" name="paid" id="paid"
                       value="<%=paid%>" readonly>
            </div>

            <div class="col-md-4">
                <label class="form-label">Balance</label>
                <input type="text" class="form-control" name="balance" id="balance"
                       value="<%=balance%>" readonly>
            </div>

            <!-- Payment Mode -->
            <div class="col-md-4">
                <label class="form-label">Payment Mode</label>
                <select class="form-select" id="mode" name="mode">
                    <option value="1">Cash</option>
                    <option value="2" selected>Bank</option>
                </select>
            </div>

            <!-- Bank Options -->
            <div class="col-md-4">
                <label class="form-label">Bank Options</label>
                <select class="form-select" id="bankOption" name="bankOption">
                    <option value="0">--Select--</option>
                    <option value="1" selected>UPI</option>
                    <option value="2">Debit Card</option>
                    <option value="3">Credit Card</option>
                    <option value="4">Net Banking</option>
                    <option value="5">Wallet</option>
                    <option value="6">Cheque</option>
                </select>
            </div>

            <!-- Pay Now -->
            <div class="col-md-4">
                <label class="form-label">Amount to Pay</label>
                <input type="number" class="form-control" name="payNow" id="payNow"
                       min="0" step="0.001" placeholder="Enter amount" required autofocus>
            </div>

            

            <div class="col-12">
                <button type="submit" class="btn btn-primary w-25">Submit Payment</button>
                <a href="<%= request.getContextPath() %>/billing/print.jsp?billNo=<%=billNo%>" target="_blank" class="btn btn-secondary ms-2">Print</a>
            </div>
        </form>
    </div>
</div>
<br>
        <div class="card">
            <div class="card-body">
                <h5>Due Paid List</h5>

                <table class="table table-bordered" >
                    <thead class="table-primary">
                        <tr>
                            <th>#</th>
                            <th>Name</th>
                            <th>Balance</th>
                            <th>Paid</th>
                            <th>Final Balance</th>
                            <th>Mode</th>
                            <th>Bank Option</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Biller</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                            
                            Vector duePaidList = bill.getDuePaidList(billId);
                            for (int i = 0; i < duePaidList.size(); i++) {
                                Vector vec1 = (Vector) duePaidList.get(i); // inner vector (row)
                                String customerName =vec1.elementAt(0).toString();
                                double balanceAmount = Double.parseDouble(vec1.elementAt(1).toString());
                                double paidAmount = Double.parseDouble(vec1.elementAt(2).toString());
                                double finalBalance = Double.parseDouble(vec1.elementAt(3).toString());
                                String mode = vec1.elementAt(4).toString();
                                String bankOption = vec1.elementAt(5).toString();
                                String date = vec1.elementAt(6).toString();
                                String time = vec1.elementAt(7).toString();
                                String biller = vec1.elementAt(8).toString();


                        %>
                        <tr>
                            <td><%=i+1%></td>
                            <td><%=customerName%></td>
                            <td><%=balanceAmount%></td>
                            <td><%=paidAmount%></td> 
                            <td><%=finalBalance%></td>
                            <td><%=mode%></td>
                            <td><%=bankOption%></td>
                            <td><%=date%></td>
                            <td><%=time%></td>
                            <td><%=biller%></td>   
                        </tr>
                        <%
                    }
                        %>
                        <%-- Dynamic rows will come here --%>
                    </tbody>
                </table>
            </div>
        </div>
<script>
    const payForm = document.getElementById("payForm");
    const payNowInput = document.getElementById("payNow");
    const balanceInput = document.getElementById("balance");
    const modeSelect = document.getElementById("mode");
    const bankOption = document.getElementById("bankOption");

    // Validate amount: cannot exceed balance
    payNowInput.addEventListener("input", function () {
        const entered = parseFloat(this.value) || 0;
        const balance = parseFloat(balanceInput.value) || 0;
        if (entered > balance) {
            alert("Entered amount cannot be greater than the balance!");
            this.value = "";
            this.focus();
        }
    });

    // Enable/disable bank options
    modeSelect.addEventListener("change", function () {
        if (this.value === "2") {
            bankOption.removeAttribute("disabled");
            if (!bankOption.value || bankOption.value === "0") {
                bankOption.value = "1";
            }
        } else {
            bankOption.value = "0";
            bankOption.setAttribute("disabled", "disabled");
        }
    });

    // Initialize defaults on page load
    modeSelect.dispatchEvent(new Event("change"));

    // Ensure bankOption is posted even if disabled (cash mode)
    payForm.addEventListener("submit", function () {
        if (modeSelect.value === "1") {
            bankOption.removeAttribute("disabled");
            bankOption.value = "0";
        }
    });
</script>

</body>
</html>
