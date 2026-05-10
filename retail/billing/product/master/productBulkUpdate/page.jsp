<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

// Get filter parameters
String filterName = request.getParameter("filterName");
String filterCategory = request.getParameter("filterCategory");
if (filterName == null) filterName = "";
if (filterCategory == null) filterCategory = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Bulk Update MRP & GST - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body {
            background: #f5f7fa;
        }
        .filter-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07);
            padding: 1rem;
            margin-bottom: 1rem;
        }
        .product-table {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07);
        }
        .table-header {
            background: var(--page-header-card-bg);
            color: white;
            padding: 0.75rem 1rem;
            border-radius: 8px 8px 0 0;
        }
        .editable-input {
            border: 1px solid #ddd;
            padding: 5px 8px;
            border-radius: 4px;
            width: 100%;
            font-size: 0.9rem;
        }
        .btn-update {
            padding: 5px 15px;
            font-size: 0.85rem;
        }
        .table td, .table th {
            vertical-align: middle;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3 mx-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container-fluid mt-2" style="max-width: 1800px;">
        <!-- Filter Section -->
        <div class="filter-card">
            <form method="get" action="<%=contextPath%>/product/master/productBulkUpdate/page.jsp" class="row g-2 align-items-end">
                <div class="col-md-4">
                    <label class="form-label" style="font-size: 0.85rem; margin-bottom: 0.25rem;">Filter by <%=head3%> Name</label>
                    <input type="text" name="filterName" class="form-control" placeholder="Enter product name..." value="<%=filterName%>" style="padding: 7px 10px; font-size: 0.9rem;">
                </div>
                <div class="col-md-4">
                    <label class="form-label" style="font-size: 0.85rem; margin-bottom: 0.25rem;">Filter by <%=head1%></label>
                    <select name="filterCategory" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;">
                        <option value="">All Categories</option>
                        <%
                            Vector categories = prod.getCategoryName();
                            if (categories != null) {
                                for (int i = 0; i < categories.size(); i++) {
                                    Vector cat = (Vector) categories.get(i);
                                    if (cat != null && cat.elementAt(0) != null && cat.elementAt(1) != null) {
                                        String categoryName = cat.elementAt(0).toString();
                                        String categoryId = cat.elementAt(1).toString();
                                        String selected = categoryId.equals(filterCategory) ? "selected" : "";
                        %>
                            <option value="<%=categoryId%>" <%=selected%>><%=categoryName%></option>
                        <%      }
                                }
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100" style="padding: 7px 10px; font-size: 0.9rem;">
                        <i class="fas fa-filter me-1"></i> Filter
                    </button>
                </div>
                <div class="col-md-2">
                    <a href="<%=contextPath%>/product/master/productBulkUpdate/page.jsp" class="btn btn-secondary w-100" style="padding: 7px 10px; font-size: 0.9rem;">
                        <i class="fas fa-redo me-1"></i> Reset
                    </a>
                </div>
            </form>
        </div>

        <!-- Products Table -->
        <div class="product-table">
            
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead style="background-color: #f8f9fa;">
                        <tr>
                            <th style="width: 5%;">#</th>
                            <th style="width: 20%;"><%=head3%> Name</th>
                            <th style="width: 10%;">Code</th>
                            <th style="width: 12%;"><%=head1%></th>
                            <th style="width: 12%;">Current MRP</th>
                            <th style="width: 12%;">New MRP</th>
                            <th style="width: 10%;">GST (%)</th>
                            <th style="width: 12%;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int count = 0;
                            
                            try {
                                // Get products using bean method
                                Vector products = prod.getProductsForBulkUpdate(filterName, filterCategory);
                                
                                for (int i = 0; i < products.size(); i++) {
                                    Vector product = (Vector) products.get(i);
                                    count++;
                                    
                                    int productId = ((Integer) product.get(0)).intValue();
                                    String productName = (String) product.get(1);
                                    String productCode = (String) product.get(2);
                                    int gst = ((Integer) product.get(3)).intValue();
                                    String categoryName = (String) product.get(4);
                                    double mrp = ((Double) product.get(5)).doubleValue();
                                    int batchId = ((Integer) product.get(6)).intValue();
                        %>
                        <tr id="row-<%=productId%>">
                            <td><%=count%></td>
                            <td><strong><%=productName%></strong></td>
                            <td><span class="badge bg-secondary"><%=productCode != null ? productCode : "-"%></span></td>
                            <td><%=categoryName%></td>
                            <td>₹ <%=String.format("%.2f", mrp)%></td>
                            <td>
                                <input type="number" step="0.01" class="editable-input" id="mrp-<%=productId%>" value="<%=mrp%>">
                            </td>
                            <td>
                                <input type="number" step="1" class="editable-input" id="gst-<%=productId%>" value="<%=gst%>" min="0" max="100">
                            </td>
                            <td>
                                <button class="btn btn-success btn-sm btn-update" onclick="updateProduct(<%=productId%>, <%=batchId%>)">
                                    <i class="fas fa-save me-1"></i> Update
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                                
                                if (count == 0) {
                        %>
                        <tr>
                            <td colspan="8" class="text-center text-muted py-4">
                                <i class="fas fa-inbox fa-2x mb-2"></i>
                                <p class="mb-0">No products found matching your criteria</p>
                            </td>
                        </tr>
                        <%
                                }
                                
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                        <tr>
                            <td colspan="8" class="text-center text-danger py-4">
                                Error loading products: <%=e.getMessage()%>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function updateProduct(productId, batchId) {
            const mrp = document.getElementById('mrp-' + productId).value;
            const gst = document.getElementById('gst-' + productId).value;
            
            if (!mrp || parseFloat(mrp) <= 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Invalid MRP',
                    text: 'Please enter a valid MRP value',
                    confirmButtonColor: '#667eea'
                });
                return;
            }
            
            if (!gst || parseInt(gst) < 0 || parseInt(gst) > 100) {
                Swal.fire({
                    icon: 'error',
                    title: 'Invalid GST',
                    text: 'Please enter a valid GST percentage (0-100)',
                    confirmButtonColor: '#667eea'
                });
                return;
            }
            
            // Show confirmation
            Swal.fire({
                title: 'Update Product?',
                text: 'Are you sure you want to update MRP and GST for this product?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#667eea',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, update it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Show loading
                    Swal.fire({
                        title: 'Updating...',
                        text: 'Please wait',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    
                    // Submit form
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'update.jsp';
                    
                    const fields = {
                        productId: productId,
                        batchId: batchId,
                        mrp: mrp,
                        gst: gst
                    };
                    
                    for (const key in fields) {
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = key;
                        input.value = fields[key];
                        form.appendChild(input);
                    }
                    
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        }
    </script>
</body>
</html>
