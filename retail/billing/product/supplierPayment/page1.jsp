<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
int supId = Integer.parseInt(request.getParameter("supId"));

Vector billList = bill.getDueSupplierBills(supId);

    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Billing - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
    .red-text {
        color: red !important;
        
    }
</style>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">

        <!-- Navbar -->
        <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-4">
  <h4 class="mb-3">Billing Details</h4>

  <div class="table-responsive">
    <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
      <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
        <tr>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Inv/GR No</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Invoice date</th>
          <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total</th>
          <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid</th>
          <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date/Time</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">User</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Supplier</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Action</th>
        </tr>
      </thead>
      <tbody>
        <%
            for (int i = 0; i < billList.size(); i++) {
                Vector row = (Vector) billList.get(i);
                
                String currentBalance   = row.get(5).toString();
                int billId		= Integer.parseInt(row.elementAt(0).toString());

            %>
        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
          <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><a href="<%=contextPath%>/product/purchase/report/purchaseRegister/purchaseDetails.jsp?id=<%=billId%>" class="btn  btn-sm btn-edit" style="background-color:hsl(222, 86%, 89%); color:#000000;"><%=row.elementAt(1)%>/<%=row.elementAt(9)%></a></td>
          <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(2)%></td>
          <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(3)%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(4)%></td>
          <td class="text-end <%= (Double.parseDouble(currentBalance) > 0) ? "red-text" : "" %>" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=currentBalance%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(6)%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(7)%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=row.elementAt(8)%></td>
          <td class="text-center" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
            <a href="<%=contextPath%>/product/supplierPayment/payBalance.jsp?billId=<%=billId%>&supId=<%=supId%>"
            class="btn btn-sm btn-outline-primary">
            Pay Balance
          </a>
          </td>
        </tr>
        <%
    }
        %>
        
      </tbody>
    </table>
  </div>
</div>

        
<script src="billing.js"></script>
</body>
</html>
    

