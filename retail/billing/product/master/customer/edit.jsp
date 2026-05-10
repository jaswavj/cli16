<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
int id = Integer.parseInt(request.getParameter("id"));
Vector customerData = prod.getCustomerById(id);

String Name = customerData.elementAt(0).toString();
String phn = customerData.elementAt(1).toString();
String address = customerData.elementAt(2).toString();
String gstin = customerData.elementAt(3).toString();
int isGst = Integer.parseInt(customerData.elementAt(4).toString());
int salesman = Integer.parseInt(customerData.elementAt(5).toString());
int area = Integer.parseInt(customerData.elementAt(6).toString());
double creditLimit = Double.parseDouble(customerData.elementAt(7).toString());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Customer - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body {
            background: #f5f7fa;
        }
        .navbar {
            background-color: #4e73df;
        }
        .navbar-brand {
            color: #fff !important;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        .btn-edit, .btn-delete {
            margin: 0 2px;
        }

    </style>
    
</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h3>Edit Customer</h3>
        
        <!-- Edit Customer Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/customer/edit1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="custName" class="form-control" placeholder="" value="<%=Name%>" required>
                        <label>Customer Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="custPhn" class="form-control" placeholder="" value="<%=phn%>">
                        <label>Phone Number</label>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-check mt-3">
                            <input class="form-check-input" type="checkbox" id="isGstRegistered" name="isGst" value="1" onchange="toggleGstinField()" <%=isGst == 1 ? "checked" : ""%>>
                            <label class="form-check-label" for="isGstRegistered">
                                GST Registered
                            </label>
                        </div>
                    </div>
                    
                    <div class="col-md-6 input-outline">
                        <input type="text" name="gstin" id="gstinField" class="form-control" placeholder="" value="<%=gstin != null ? gstin : ""%>" maxlength="15" <%=isGst == 0 ? "disabled" : ""%>>
                        <label>GSTIN <span class="text-danger" id="gstinRequired" style="display:<%=isGst == 1 ? "inline" : "none"%>;">*</span></label>
                        <small id="gstinError" class="text-danger" style="display:none;">GSTIN must be exactly 15 characters</small>
                    </div>
                    
                    <div class="col-md-6 input-outline">
                        <select name="salesman" class="form-control">
                            <option value="">Select Salesman</option>
                            <%
                                Vector salesmanList = prod.getActiveSalesmanList();
                                for (int s = 0; s < salesmanList.size(); s++) {
                                    Vector sm = (Vector) salesmanList.get(s);
                                    int smId = Integer.parseInt(sm.elementAt(0).toString());
                                    String smName = sm.elementAt(1).toString();
                            %>
                            <option value="<%=smId%>" <%=smId == salesman ? "selected" : ""%>><%=smName%></option>
                            <% } %>
                        </select>
                        <label>Salesman</label>
                    </div>
                    
                    <div class="col-md-6 input-outline">
                        <select name="area" class="form-control">
                            <option value="">Select Area</option>
                            <%
                                Vector areaList = prod.getActiveAreaList();
                                for (int a = 0; a < areaList.size(); a++) {
                                    Vector ar = (Vector) areaList.get(a);
                                    int arId = Integer.parseInt(ar.elementAt(0).toString());
                                    String arName = ar.elementAt(1).toString();
                            %>
                            <option value="<%=arId%>" <%=arId == area ? "selected" : ""%>><%=arName%></option>
                            <% } %>
                        </select>
                        <label>Area</label>
                    </div>
                    
                    <div class="col-md-6 input-outline">
                        <input type="number" name="creditLimit" class="form-control" placeholder="" step="0.001" value="<%=creditLimit%>">
                        <label>Credit Limit</label>
                    </div>
                    
                    <div class="col-md-6 input-outline">
                        <textarea name="custAddress" class="form-control" placeholder="" rows="3"><%=address%></textarea>
                        <label>Address</label>
                    </div>
                    
                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" id="block" name="block">
                        <label class="form-check-label" for="block">
                            Block Customer
                        </label>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update Customer</button>
                        <a href="<%=contextPath%>/product/master/customer/page.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>

    </div>

    <script>
    function toggleGstinField() {
        const checkbox = document.getElementById('isGstRegistered');
        const gstinField = document.getElementById('gstinField');
        const gstinRequired = document.getElementById('gstinRequired');
        const gstinError = document.getElementById('gstinError');
        
        if (checkbox.checked) {
            gstinField.disabled = false;
            gstinField.required = true;
            gstinRequired.style.display = 'inline';
            gstinField.focus();
        } else {
            gstinField.disabled = true;
            gstinField.required = false;
            gstinField.value = '';
            gstinRequired.style.display = 'none';
            gstinError.style.display = 'none';
            gstinField.style.borderColor = '';
        }
    }
    
    // Real-time GSTIN validation
    document.addEventListener('DOMContentLoaded', function() {
        const gstinField = document.getElementById('gstinField');
        const gstinError = document.getElementById('gstinError');
        const isGstCheckbox = document.getElementById('isGstRegistered');
        const form = document.querySelector('form');
        
        // Real-time validation on input
        gstinField.addEventListener('input', function() {
            if (isGstCheckbox.checked) {
                const length = this.value.length;
                if (length > 0 && length !== 15) {
                    this.style.borderColor = '#dc3545';
                    gstinError.style.display = 'block';
                } else if (length === 15) {
                    this.style.borderColor = '#28a745';
                    gstinError.style.display = 'none';
                } else {
                    this.style.borderColor = '';
                    gstinError.style.display = 'none';
                }
            }
        });
        
        // Form submit validation
        form.addEventListener('submit', function(e) {
            if (isGstCheckbox.checked) {
                const gstinValue = gstinField.value.trim();
                if (gstinValue.length !== 15) {
                    e.preventDefault();
                    gstinField.style.borderColor = '#dc3545';
                    gstinError.style.display = 'block';
                    gstinField.focus();
                    alert('GSTIN must be exactly 15 characters for GST registered customers');
                    return false;
                }
            }
        });
    });
    </script>

</body>
</html>
