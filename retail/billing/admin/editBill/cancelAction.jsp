<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*, java.math.BigDecimal"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="bill" class="billing.salesReturnBean" />
<%
int uid = (Integer)session.getAttribute("userId");
int billId = 0;
if(request.getParameter("billId") != null){
    billId = Integer.parseInt(request.getParameter("billId"));
}
String cancelReason = request.getParameter("cancelReason");



bill.cancelBill(billId, cancelReason,uid);
Vector details = bill.getBillDetails(billId);
for(int i=0; i<details.size(); i++){
    Vector row = (Vector)details.elementAt(i);
    int prodId = Integer.parseInt(row.elementAt(2).toString());
    BigDecimal qty = new BigDecimal(row.elementAt(4).toString());
    int status =bill.getStatus(billId,prodId);
    if(status == 0){
        bill.updateStockAfterCancel(prodId, qty,uid);
    }
    
}
response.sendRedirect(request.getContextPath() + "/admin/editBill/page.jsp");
%>