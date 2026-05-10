<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
String contextPath = request.getContextPath();
Vector billList = bill.getDueBills();
    
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Billing - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    <style>
    .red-text {
        color: red !important;
        
    }
</style>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">

        <!-- Navbar -->
        <jsp:include page="/assets/navbar/navbar.jsp" />

<div class="container mt-4">
  <h4 class="mb-3">Credit Details</h4>

  <!-- Filter Section -->
  <div class="row mb-3">
    <div class="col-md-4">
      <div class="input-group">
        <span class="input-group-text"><i class="fas fa-user"></i></span>
        <input type="text" id="nameFilter" class="form-control" placeholder="Filter by Name..." onkeyup="filterTable()">
      </div>
    </div>
    <div class="col-md-4">
      <div class="input-group">
        <span class="input-group-text"><i class="fas fa-phone"></i></span>
        <input type="text" id="phoneFilter" class="form-control" placeholder="Filter by Phone Number..." onkeyup="filterTable()">
      </div>
    </div>
    <div class="col-md-4">
      <button class="btn btn-secondary" onclick="clearFilters()">
        <i class="fas fa-times"></i> Clear Filters
      </button>
    </div>
  </div>

  <div class="table-responsive">
    <table id="billingTable" class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
      <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
        <tr>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">S.No</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Bill No</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Name</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Phone Number</th>
          <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Total</th>
          <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Paid</th>
          <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Balance</th>
           <th scope="col" class="text-end" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Pending Balance</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Date</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Time</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Biller</th>
          <th scope="col" style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Action</th>
        </tr>
      </thead>
      <tbody>
        <%
            for (int i = 0; i < billList.size(); i++) {
                Vector row = (Vector) billList.get(i);
                
                
                String name  = row.get(0).toString();
                String phno  = row.get(1).toString();
                String payable   = row.get(2).toString();
                String paid   = row.get(3).toString();
                String Balance   = row.get(4).toString();
                String currentBalance   = row.get(10).toString();
                String date   = row.get(5).toString();
                String time   = row.get(6).toString();
                String uname   = row.get(7).toString();
                String billNo   = row.get(8).toString();
                int billId		= Integer.parseInt(row.elementAt(9).toString());

            %>
        <tr class="bill-row" data-name="<%=name.toLowerCase()%>" data-phone="<%=phno%>" style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
          <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
              <a href="#" onclick="loadBillDetails(<%=billId%>); return false;" class="btn btn-sm btn-edit" style="background-color:hsl(222, 86%, 89%); color:#000000;"><%=billNo%></a>
            </td>
          <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=name%></td>
          <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
            <a href="#" onclick="sendToWhatsApp('<%=phno%>', '<%=name%>', '<%=billNo%>', '<%=payable%>', '<%=paid%>', '<%=currentBalance%>', '<%=date%>', <%=billId%>); return false;" class="text-success" title="Send details via WhatsApp">
              <i class="fab fa-whatsapp"></i> <%=phno%>
            </a>
          </td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=payable%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=paid%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=Balance%></td>
          <td class="text-end <%= (Double.parseDouble(currentBalance) > 0) ? "red-text" : "" %>" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=currentBalance%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=date%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=time%></td>
          <td class="text-end" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=uname%></td>
          <td class="text-center" style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
            <a href="<%=contextPath%>/billing/payBalance.jsp?billId=<%=billId%>"
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

<!-- Bill Details Modal -->
<div class="modal fade" id="billDetailModal" tabindex="-1" aria-labelledby="billDetailModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header" style="background: linear-gradient(135deg, #3d1a52, #570a57); color: white;">
        <h5 class="modal-title" id="billDetailModalLabel">Bill Details</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="billDetailContent">
        <div class="text-center py-5">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
      </div>
    </div>
  </div>
</div>

<script>
const contextPath = '<%=contextPath%>';
function sendToWhatsApp(phone, name, billNo, payable, paid, currentBalance, date, billId) {
  // Remove any non-numeric characters from phone
  var cleanPhone = phone.replace(/\D/g, '');
  
  // Format detailed message for WhatsApp
  var message = `*JASXBILL - Bill Details*\n`;
  message += `${'='.repeat(15)}\n\n`;
  message += ` *Customer:* ${name}\n`;
  message += ` *Bill No:* ${billNo}\n`;
  message += ` *Date:* ${date}\n\n`;
  message += `${'='.repeat(15)}\n`;
  message += `*PAYMENT SUMMARY*\n`;
  message += `${'='.repeat(15)}\n\n`;
  message += ` *Total Amount:* ₹${payable}\n`;
  //message += `✅ *Paid:* ₹${paid}\n`;
  message += ` *Pending Balance:* ₹${currentBalance}\n\n`;
  message += `${'='.repeat(15)}\n\n`;
  
  if (parseFloat(currentBalance) > 0) {
    message += ` Please clear the pending balance at your earliest convenience.\n\n`;
  } else {
    message += ` Payment completed. Thank you!\n\n`;
  }
  
  message += `Thank you for your business! \n`;
  message += `For any queries, please contact us.`;
  
  // Encode the message for URL
  var encodedMessage = encodeURIComponent(message);
  
  // Open WhatsApp with pre-filled message
  var whatsappUrl = `https://wa.me/${cleanPhone}?text=${encodedMessage}`;
  window.open(whatsappUrl, '_blank');
}

function loadBillDetails(billId) {
  // Show the modal
  var modal = new bootstrap.Modal(document.getElementById('billDetailModal'));
  modal.show();
  
  // Show loading spinner
  document.getElementById('billDetailContent').innerHTML = `
    <div class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
  `;
  
  // Fetch bill details
  fetch(contextPath + '/billing/balanceDetailModal.jsp?billId=' + billId)
    .then(response => response.text())
    .then(data => {
      document.getElementById('billDetailContent').innerHTML = data;
    })
    .catch(error => {
      document.getElementById('billDetailContent').innerHTML = `
        <div class="alert alert-danger" role="alert">
          <i class="fas fa-exclamation-triangle"></i> Error loading bill details. Please try again.
        </div>
      `;
      console.error('Error:', error);
    });
}

function filterTable() {
  var nameFilter = document.getElementById('nameFilter').value.toLowerCase();
  var phoneFilter = document.getElementById('phoneFilter').value;
  var table = document.getElementById('billingTable');
  var rows = table.getElementsByClassName('bill-row');
  
  for (var i = 0; i < rows.length; i++) {
    var row = rows[i];
    var name = row.getAttribute('data-name');
    var phone = row.getAttribute('data-phone');
    
    var nameMatch = name.includes(nameFilter);
    var phoneMatch = phone.includes(phoneFilter);
    
    if (nameMatch && phoneMatch) {
      row.style.display = '';
    } else {
      row.style.display = 'none';
    }
  }
  
  updateSerialNumbers();
}

function clearFilters() {
  document.getElementById('nameFilter').value = '';
  document.getElementById('phoneFilter').value = '';
  filterTable();
}

function updateSerialNumbers() {
  var table = document.getElementById('billingTable');
  var rows = table.getElementsByClassName('bill-row');
  var visibleCount = 1;
  
  for (var i = 0; i < rows.length; i++) {
    var row = rows[i];
    if (row.style.display !== 'none') {
      row.cells[0].textContent = visibleCount++;
    }
  }
}
</script>

<script>
    var contextPath = '<%=contextPath%>';
</script>        
<script src="billing.js"></script>
</body>
</html>
    

