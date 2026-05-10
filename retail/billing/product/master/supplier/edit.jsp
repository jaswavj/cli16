<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
String Name = request.getParameter("Name");
String desc = request.getParameter("desc");
String phn = request.getParameter("phn");
String gstin = request.getParameter("gstin");
String isGstParam = request.getParameter("isGst");
int isGst = (isGstParam != null) ? Integer.parseInt(isGstParam) : 0;
int id = Integer.parseInt(request.getParameter("id"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Supplier - Billing App</title>
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
<body onload="document.form.opregInput.focus();">

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h3>Supplier Details</h3>
        
        <!-- Add Category Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/supplier/edit1.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="supName" class="form-control" placeholder="" value="<%=Name%>" required><label >Supplier Name</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <input type="number" name="supPhn" class="form-control" placeholder="" value="<%=phn%>"><label >Phone Number</label>
                    </div>
                    <div class="col-md-6 input-outline">
                        <textarea name="supDesc" placeholder="Description" ><%=desc%></textarea>
                    </div>
                    <div class="col-md-6">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="checkbox" id="isGst" name="isGst" <%= (isGst == 1) ? "checked" : "" %> onchange="toggleGstin()">
                            <label class="form-check-label" for="isGst">
                                GST Registered
                            </label>
                        </div>
                        <div class="input-outline">
                            <input type="text" name="gstin" id="gstin" class="form-control" placeholder="" value="<%=gstin != null ? gstin : ""%>" maxlength="15" <%= (isGst == 1) ? "" : "disabled" %>><label>GSTIN <span class="text-danger" id="gstinRequired" style="display:<%= (isGst == 1) ? "inline" : "none" %>;">*</span></label>
                            <small id="gstinError" class="text-danger" style="display:none;">GSTIN must be exactly 15 characters</small>
                        </div>
                    </div>
                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" id="block" name="block">
                        <label class="form-check-label" for="block">
                            Block
                        </label>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update Supplier</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        
        
    </div>
</div>
    <!-- Bootstrap JS -->
<script>
  // Toggle GSTIN field based on GST checkbox
  function toggleGstin() {
    var isGstChecked = document.getElementById('isGst').checked;
    var gstinField = document.getElementById('gstin');
    var gstinRequired = document.getElementById('gstinRequired');
    var gstinError = document.getElementById('gstinError');
    
    if (isGstChecked) {
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
    var gstinField = document.getElementById('gstin');
    var gstinError = document.getElementById('gstinError');
    var isGstCheckbox = document.getElementById('isGst');
    var form = document.querySelector('form');
    
    // Real-time validation on input
    gstinField.addEventListener('input', function() {
      if (isGstCheckbox.checked) {
        var length = this.value.length;
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
        var gstinValue = gstinField.value.trim();
        if (gstinValue.length !== 15) {
          e.preventDefault();
          gstinField.style.borderColor = '#dc3545';
          gstinError.style.display = 'block';
          gstinField.focus();
          alert('GSTIN must be exactly 15 characters for GST registered suppliers');
          return false;
        }
      }
    });
  });
</script>

</body>
</html>
