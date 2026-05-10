<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
out.print(contextPath);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Brands - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <link href="../../../dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="../../../dist/css/jquery-ui.css">
<script src="../../../dist/js/jquery-3.6.0.min.js"></script>
<script src="../../../dist/js/jquery-ui.js"></script>

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

    <script>
$(function () {
    $("#catName").autocomplete({
        source: function (request, response) {
            $.ajax({
                url: "auto_complet.jsp",
                type: "GET",
                data: { productSearch: request.term },
                success: function (data) {
                    response($.parseJSON(data));
                }
            });
        },
        minLength: 2,
        select: function (event, ui) {
            // ui.item.label = name, ui.item.value = id
            $("#catName").val(ui.item.label);
            $("#catId").val(ui.item.value); 
            return false;
        }
    });
});

</script>


</head>
<body onload="document.form.opregInput.focus();">

    <!-- Top Navbar -->


    <div class="container mt-4 ">
        <h3>Batch Management</h3>
        
        <!-- Add Category Form -->
        <div class="card mb-4">
            <div class="card-body">
                <h5>Product</h5>
                <form action="<%=contextPath%>/product/master/batch/batch1.jsp" method="post" class="row g-3">
                    <input type="hidden" id="catId" name="catId">
                    <div class="col-md-6">
                        <input type="text" id="catName" name="catName" class="form-control"  placeholder="Search Product" required>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Search</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        <div class="card">
            <div class="card-body">
                <h5>Product List</h5>
                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Product Name</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Code</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Category</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Brand</th>
                            
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Vector productList = prod.getAllProductsReverse();
                            for (int i = 0; i < productList.size(); i++) {
                                Vector row = (Vector) productList.get(i);
                                String productName = row.elementAt(0).toString();
                                String categoryName = row.elementAt(1).toString();
                                String brandName = row.elementAt(2).toString();
                                int productId = Integer.parseInt(row.elementAt(3).toString());
                                String prodCode = row.elementAt(4).toString();
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=productName%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=prodCode%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=categoryName%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=brandName%></td>
                            
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        
    </div>
</div>
    <!-- Bootstrap JS -->
    <script src="../../../dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
