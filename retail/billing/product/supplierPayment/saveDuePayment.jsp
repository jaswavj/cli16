<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="supplierCheque" class="cheque.supplierChequeBean" />
<%
int uid = (Integer) session.getAttribute("userId");
int billId = Integer.parseInt(request.getParameter("billId"));
int supPayID = Integer.parseInt(request.getParameter("supPayID"));
int supId = Integer.parseInt(request.getParameter("supId"));
double balance = Double.parseDouble(request.getParameter("balance"));
double payNow = Double.parseDouble(request.getParameter("payNow")); 
int mode = Integer.parseInt(request.getParameter("mode"));
int bankOption = Integer.parseInt(request.getParameter("bankOption"));

// Save the payment
bill.saveSupplierDuePayment(billId, payNow, mode, bankOption, uid, supId, balance, supPayID);

// Get new balance after payment
Vector billDetails = bill.getSupplierBillAmount(billId);
double newBalance = Double.parseDouble(billDetails.get(2).toString());

// Handle supplier cheque operations
try {
    // If bank payment with cheque option (bankOption = 6)
    if (mode == 2 && bankOption == 6) {
        // Clear allocated cheques for this purchase
        supplierCheque.clearChequeAllocationForPurchase(billId, payNow);
    } 
    // If full payment made (balance is now 0), reverse cheque allocation
    else if (newBalance == 0) {
        supplierCheque.reverseChequeAllocation(billId, payNow);
    }
} catch (Exception e) {
    System.out.println("Supplier cheque operation error: " + e.getMessage());
    e.printStackTrace();
}

response.sendRedirect(request.getContextPath() + "/product/supplierPayment/page.jsp");
%>
