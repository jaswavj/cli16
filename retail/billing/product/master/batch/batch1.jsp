<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
String catName = request.getParameter("catName");
String catId = request.getParameter("catId"); 
int existingProdId = prod.checkTheProductNameExist(catName);
if(existingProdId == 0){
%>
    <script>
        alert("Product not found. Please select the Existing Product");
        setTimeout(function() {
            window.location.href = "<%=contextPath%>/product/master/batch/batch.jsp";
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
    <title>Products - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <link href="../../../dist/css/bootstrap.min.css" rel="stylesheet">
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

    <div class="container mt-4">
        <h3>Product Management</h3>

        <!-- Add Product Form -->
        <div class="card mb-4">
            <div class="card-body">
                <h5>Add New Batch</h5>
                <form action="<%=contextPath%>/product/master/batch/batch2.jsp" method="post" class="row g-3">
                    <input type="hidden" id="catName" name="catName" value="<%=catName%>">
                    <input type="hidden" id="catId" name="catId" value="<%=catId%>">

                    <div class="col-md-3">
                        <input type="text" name="catNames" class="form-control"  value="<%=catName%>" disabled>
                    </div>
                    <div class="col-md-3">
                        <input type="text" name="batchName" class="form-control"  placeholder="Batch Name"  required>
                    </div>
                    
                    <div class="col-md-3">
                        
                        <input type="number" step="0.001" name="cost" class="form-control" placeholder="Enter Cost Price" required>
                    </div>
                    <div class="col-md-3">
                        <input type="number" step="0.001" name="mrp" class="form-control" placeholder="Enter mrp Price" required>
                    </div>
                    
                    <div class="col-md-2">
                        <select class="form-control" id="discType" name="discType" onchange="handleDiscTypeChange(this)" required>
                            <option value="0">Discount Type</option>
                            <option value="1">Rs</option>
                            <option value="2">Percentage</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <input type="text" id="discValue" name="discValue" class="form-control" value="0.00" disabled>
                    </div>
                    <div class="col-md-3">
                        <input type="number" name="stock" class="form-control" placeholder="Enter stock" required>
                    </div>
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Add Product</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        <div class="card">
            <div class="card-body">
                <h5>Batch List</h5>
                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Batch Name</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Mrp</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">discount</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">added stock</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Current stock</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Functions</th>
                            
                            
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Vector batchList = prod.getAllProductBatch(catId);
                            for (int i = 0; i < batchList.size(); i++) {
                                Vector row = (Vector) batchList.get(i);
                                String batchName = row.elementAt(0).toString();
                                
                                double mrp = Double.parseDouble(row.elementAt(1).toString());
                                String discount = row.elementAt(2).toString();
                                int batchId = Integer.parseInt(row.elementAt(3).toString());
                                double stock = Double.parseDouble(row.elementAt(4).toString());
                                double addedStock = Double.parseDouble(row.elementAt(5).toString());
                               
                        %>
                        <tr>
                            <td><%=i+1%></td>
                            <td><%=batchName%></td>
                            <td><%=mrp%></td>
                            <td><%=discount%></td>
                            <td><%=addedStock%></td>
                            <td><%=stock%></td>
                            <td>
                                <a href="<%=contextPath%>/product/master/batch/editProduct.jsp?batchId=<%=batchId%>" class="btn btn-warning btn-sm btn-edit">Edit</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="../../../dist/js/bootstrap.bundle.min.js"></script>
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
</body>
</html>
