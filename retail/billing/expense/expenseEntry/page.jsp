<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%

// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head> 
    <meta charset="UTF-8">
    <title>Expense Entry - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body {
            background: #f5f7fa;
        }
    </style>
    
</head>
<body>
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / danger / warning
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-2" style="max-width: 900px;">
        <div class="card" style="border: none; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); border-radius: 12px;">
            <div class="card-header" style="background: #624b88; color: white; border-radius: 12px 12px 0 0; padding: 1rem 1.5rem;">
                <h5 class="mb-0" style="font-weight: 600;"><i class="fas fa-receipt me-2"></i>Add Expense Entry</h5>
            </div>
            <div class="card-body" style="padding: 2rem;">
                <form action="<%=contextPath%>/expense/expenseEntry/saveExpenseEntry.jsp" method="post" onsubmit="return validateForm()">
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="input-outline">
                                <select name="expenseType" id="expenseType" class="form-control" required style="padding: 10px; border: 2px solid #e2e8f0; border-radius: 8px;">
                                    <option value="">-- Select Expense Type --</option>
                                    <%
                                    try {
                                        Vector expTypes = prod.getExpenseTypeList();
                                        for (int i = 0; i < expTypes.size(); i++) {
                                            Vector expType = (Vector) expTypes.get(i);
                                            String typeName = expType.elementAt(0).toString();
                                            String typeId = expType.elementAt(1).toString();
                                    %>
                                        <option value="<%=typeId%>"><%=typeName%></option>
                                    <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<option value=''>Error loading expense types</option>");
                                    }
                                    %>
                                </select>
                                
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="input-outline">
                                <input type="number" step="0.01" name="amount" id="amount" class="form-control" placeholder="" required style="padding: 10px; border: 2px solid #e2e8f0; border-radius: 8px;">
                                <label style="background: white; padding: 0 8px; font-size: 0.9rem;">Amount</label>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <div class="input-outline">
                            <input type="text" name="content" id="content" class="form-control" placeholder="" required style="padding: 10px; border: 2px solid #e2e8f0; border-radius: 8px;">
                            <label style="background: white; padding: 0 8px; font-size: 0.9rem;">Content</label>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <div class="input-outline">
                            <textarea name="description" id="description" class="form-control" rows="4" placeholder="Description(type anything you want to store here)" style="padding: 10px; border: 2px solid #e2e8f0; border-radius: 8px;"></textarea>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div class="input-outline">
                                <input type="date" name="expenseDate" id="expenseDate" class="form-control" required style="padding: 10px; border: 2px solid #e2e8f0; border-radius: 8px;" value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
                                <label style="background: white; padding: 0 8px; font-size: 0.9rem;">Date</label>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <div class="input-outline">
                                <input type="time" name="expenseTime" id="expenseTime" class="form-control" required style="padding: 10px; border: 2px solid #e2e8f0; border-radius: 8px;" value="<%= new java.text.SimpleDateFormat("HH:mm").format(new java.util.Date()) %>">
                                <label style="background: white; padding: 0 8px; font-size: 0.9rem;">Time</label>
                            </div>
                        </div>
                    </div>
                    
                    <div class="d-flex gap-2 justify-content-end mt-4">
                        <button type="reset" class="btn btn-secondary" style="padding: 10px 24px; border-radius: 8px;">
                            <i class="fas fa-undo me-2"></i>Reset
                        </button>
                        <button type="submit" class="btn btn-primary" style="padding: 10px 24px; border-radius: 8px; background: #624b88; border: none;">
                            <i class="fas fa-save me-2"></i>Save Expense
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        function validateForm() {
            const expenseType = document.getElementById('expenseType').value;
            const amount = document.getElementById('amount').value;
            const content = document.getElementById('content').value;
            const expenseDate = document.getElementById('expenseDate').value;
            const expenseTime = document.getElementById('expenseTime').value;
            
            if (!expenseType) {
                alert('Please select an expense type');
                return false;
            }
            
            if (!amount || parseFloat(amount) <= 0) {
                alert('Please enter a valid amount');
                return false;
            }
            
            if (!content.trim()) {
                alert('Please enter content');
                return false;
            }
            
            if (!expenseDate) {
                alert('Please select a date');
                return false;
            }
            
            if (!expenseTime) {
                alert('Please select a time');
                return false;
            }
            
            return true;
        }
    </script>

</body>
</html>
