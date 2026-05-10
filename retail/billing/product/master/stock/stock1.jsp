<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
String contextPaths = request.getContextPath();
String catName = request.getParameter("catName");
int catId = Integer.parseInt(request.getParameter("catId")); 

java.math.BigDecimal curStock = prod.getCurrentStock(catId);
int proBatch = prod.getBatch(catId);

// Get product unit and conversion information
Vector batchList = prod.getAllProductBatch(catId);
String unitName = "";
String convertionUnit = "";
java.math.BigDecimal convertionCalculation = java.math.BigDecimal.ZERO;
if (batchList.size() > 0) {
    Vector firstBatch = (Vector) batchList.get(0);
    if (firstBatch.size() > 6 && firstBatch.elementAt(6) != null) {
        unitName = firstBatch.elementAt(6).toString();
    }
    if (firstBatch.size() > 7 && firstBatch.elementAt(7) != null) {
        convertionUnit = firstBatch.elementAt(7).toString();
    }
    if (firstBatch.size() > 8 && firstBatch.elementAt(8) != null) {
        try { convertionCalculation = new java.math.BigDecimal(firstBatch.elementAt(8).toString()); } catch (Exception ex) {}
    }
}

int existingProdId = prod.checkTheProductNameExist(catName);
if(existingProdId == 0){
%>
    <script>
        alert("Product not found. Please select the Existing Product");
        setTimeout(function() {
            window.location.href = "<%=contextPaths%>/product/master/stock/stock.jsp";
        }); 
    </script>
<%
    return; // Stop further JSP execution
}

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Stock - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
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

    <div class="container mt-4">
        <h3>Stock Management</h3>

        <!-- Add Product Form -->
        <div class="card mb-4">
            <div class="card-body">
                
                <form action="<%=contextPath%>/product/master/stock/stock2.jsp" method="post" class="row g-3">
                    <input type="hidden" id="catName" name="catName" value="<%=catName%>">
                    <input type="hidden" id="catId" name="catId" value="<%=catId%>">
                    <input type="hidden" id="curStock" name="curStock" value="<%=curStock%>">
                    <input type="hidden" id="proBatch" name="proBatch" value="<%=proBatch%>">
                    <input type="hidden" id="convertionCalculation" name="convertionCalculation" value="<%=convertionCalculation%>">

                    <div class="col-md-3">
                        <label style="font-size: 0.85rem;">Product Name</label>
                        <input type="text" name="catNames" class="form-control"  value="<%=catName%>" disabled>
                    </div>
                    
                    
                    <div class="col-md-2">
                        <label style="font-size: 0.85rem;">Action Type</label>
                        <select class="form-control" id="discType" name="discType" onchange="handleDiscTypeChange(this)" required>
                            <option value="">Choose The Type</option>
                            <option value="1">Stock Add</option>
                            <option value="2">Stock Remove</option>
                            <option value="3">Damage</option>
                            <option value="4">Internal Use</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label id="quantityLabel" style="font-size: 0.85rem;">Quantity<%=unitName.isEmpty() ? "" : " (" + unitName + ")"%></label>
                        <input type="text" id="discValue" name="discValue" class="form-control" value="0.00" disabled required>
                        <%
                            if (convertionCalculation.compareTo(java.math.BigDecimal.ZERO) > 0 && !convertionUnit.isEmpty()) {
                                java.math.BigDecimal displayStock = curStock.divide(convertionCalculation, 3, java.math.RoundingMode.HALF_UP);
                        %>
                        <small class="text-info d-block mt-1">Current stock: <%=displayStock.stripTrailingZeros().toPlainString()%> <%=convertionUnit%></small>
                        <% } %>
                        <small id="conversionNote" class="text-muted d-block mt-1"></small>
                    </div>
                    <div class="col-md-3">
                        <label style="font-size: 0.85rem;">Reason Category</label>
                        <select class="form-control" id="reasonCategory" name="reasonCategory" disabled>
                            <option value="">-- Select Category --</option>
                            <option value="Broken">Broken</option>
                            <option value="Expired">Expired</option>
                            <option value="Damaged in Transit">Damaged in Transit</option>
                            <option value="Quality Issue">Quality Issue</option>
                            <option value="Office Use">Office Use</option>
                            <option value="Sample/Demo">Sample/Demo</option>
                            <option value="Staff Use">Staff Use</option>
                            <option value="Testing">Testing</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <div class="col-md-6">
                        <label style="font-size: 0.85rem;">Reason/Notes</label>
                        <textarea id="reason" name="reason" class="form-control" placeholder="Type the reason for edit stock" required></textarea>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        <div class="card">
            <div class="card-body" style="overflow-x: auto;">
                <h5>Batch List</h5>
                <div class="table-responsive">
                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 600px;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Code</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Mrp</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">discount</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">added stock</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Current stock</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Unit</th>

                            
                            
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Vector batchListDisplay = prod.getAllProductBatch(catId);
                            for (int i = 0; i < batchListDisplay.size(); i++) {
                                Vector row = (Vector) batchListDisplay.get(i);
                                String batchName = row.elementAt(0).toString();
                                
                                double mrp = Double.parseDouble(row.elementAt(1).toString());
                                String discount = row.elementAt(2).toString();
                                int batchId = Integer.parseInt(row.elementAt(3).toString());
                                double stock = Double.parseDouble(row.elementAt(4).toString());
                                double addedStock = Double.parseDouble(row.elementAt(5).toString());
                                String unit = row.size() > 6 && row.elementAt(6) != null ? row.elementAt(6).toString() : "";
                               
                        %>
                        <tr>
                            <td><%=i+1%></td>
                            <td><%=batchName%></td>
                            <td><%=mrp%></td>
                            <td><%=discount%></td>
                            <td><%=addedStock%></td>
                            <td><%=stock%></td>
                            <td><%=unit%></td>
                            
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
   

    <script>
    function handleDiscTypeChange(select) {
        const discValueInput = document.getElementById('discValue');
        if (select.value === "0") {
            discValueInput.value = "0.00";
            discValueInput.disabled = true;
        } else {
            discValueInput.disabled = false;
            discValueInput.value = "";
        }
    }
</script>
<script>
    const curStock = <%= curStock %>; // JSP variable to JS
    const convertionCalculation = <%= convertionCalculation.compareTo(java.math.BigDecimal.ZERO) > 0 ? convertionCalculation : "0" %>;
    const convertionUnit = "<%=convertionUnit.replace("\"","&quot;")%>";

    document.getElementById('discValue').addEventListener('input', function () {
        const note = document.getElementById('conversionNote');
        if (convertionCalculation > 0 && convertionUnit) {
            const qty = parseFloat(this.value);
            if (!isNaN(qty) && qty > 0) {
                const converted = (qty * convertionCalculation).toFixed(3);
                note.textContent = 'Converted: ' + converted + ' ' + convertionUnit + ' (' + qty + ' x ' + convertionCalculation + ')';
            } else {
                note.textContent = '';
            }
        }
    });
    //alert(curStock);
</script>
<script>
    const discTypeEl = document.getElementById('discType');
    const discValueEl = document.getElementById('discValue');
    const reasonCategoryEl = document.getElementById('reasonCategory');

    discTypeEl.addEventListener('change', function () {
        const selectedType = this.value;
        discValueEl.disabled = (selectedType == "0");

        if (selectedType == "1" || selectedType == "2" || selectedType == "3" || selectedType == "4") {
            discValueEl.disabled = false;
        } else {
            discValueEl.disabled = true;
            discValueEl.value = "0.00";
        }
        
        // Enable reason category dropdown only for Damage (3) or Internal Use (4)
        if (selectedType == "3" || selectedType == "4") {
            reasonCategoryEl.disabled = false;
        } else {
            reasonCategoryEl.disabled = true;
            reasonCategoryEl.value = "";
        }
    });

    discValueEl.addEventListener('input', function () {
        const selectedType = discTypeEl.value;
        const enteredValue = parseFloat(this.value);

        // Check for Remove, Damage, or Internal Use (all reduce stock)
        if ((selectedType == "2" || selectedType == "3" || selectedType == "4") && enteredValue > curStock) {
            alert("You cannot remove more than current stock (" + curStock + ")");
            this.value = curStock; // Optionally reset to max allowed
        }
    });
</script>

</body>
</html>
