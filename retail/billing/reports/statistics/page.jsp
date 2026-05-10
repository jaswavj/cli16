<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String contextPath = request.getContextPath();
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    response.sendRedirect(contextPath + "/index.jsp");
    return;
}

// Get categories, brands for dropdowns
Vector categories = prod.getCategoryName();
Vector brands = prod.getBrandsName();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Statistics - Billing App</title>
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        .stat-card {
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            transition: transform 0.2s;
        }
        .stat-card:hover {
            transform: translateY(-3px);
        }
        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            margin: 8px 0;
        }
        .stat-label {
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stat-card .fa-2x {
            font-size: 1.5rem;
        }
        /* Mild pastel colors */
        .bg-mild-purple {
            background: linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%);
            color: #4a4a4a;
        }
        .bg-mild-green {
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
            color: #4a4a4a;
        }
        .bg-mild-yellow {
            background: linear-gradient(135deg, #ffeaa7 0%, #fdcb6e 100%);
            color: #4a4a4a;
        }
        .bg-mild-blue {
            background: linear-gradient(135deg, #a8d8ea 0%, #aa96da 100%);
            color: #4a4a4a;
        }
        .chart-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        .filter-section {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <jsp:include page="/assets/navbar/navbar.jsp" />
        
        <div class="content-area">
            <div class="container-fluid">
                <!-- Header -->
                

                <!-- Filters -->
                <div class="filter-section">
                    <h5 class="mb-3"><i class="fas fa-filter"></i>Statistics Filters</h5>
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label">From Date</label>
                            <input type="date" id="fromDate" class="form-control" value="<%=new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())%>">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">To Date</label>
                            <input type="date" id="toDate" class="form-control" value="<%=new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())%>">
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Category</label>
                            <select id="categoryId" class="form-select" onchange="loadBrandsByCategory()">
                                <option value="">All Categories</option>
                                <%
                                if (categories != null) {
                                    for (int i = 0; i < categories.size(); i++) {
                                        Vector row = (Vector) categories.elementAt(i);
                                        String name = row.get(0).toString();
                                        String id = row.get(1).toString();
                                %>
                                <option value="<%=id%>"><%=name%></option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Brand</label>
                            <select id="brandId" class="form-select" onchange="loadProductsByFilters()">
                                <option value="">All Brands</option>
                                <%
                                if (brands != null) {
                                    for (int i = 0; i < brands.size(); i++) {
                                        Vector row = (Vector) brands.elementAt(i);
                                        String name = row.get(0).toString();
                                        String id = row.get(1).toString();
                                %>
                                <option value="<%=id%>"><%=name%></option>
                                <%
                                    }
                                }
                                %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Product</label>
                            <select id="productId" class="form-select">
                                <option value="">All Products</option>
                            </select>
                        </div>
                    </div>
                    <div class="row mt-3">
                        <div class="col-12">
                            <button class="btn btn-primary" onclick="loadStatistics()">
                                <i class="fas fa-search"></i> Generate Report
                            </button>
                            <button class="btn btn-secondary" onclick="resetFilters()">
                                <i class="fas fa-redo"></i> Reset
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Statistics Cards -->
                <div class="row g-3" id="statsCards">
                    <div class="col-md-3">
                        <div class="stat-card bg-mild-purple">
                            <i class="fas fa-receipt fa-2x mb-2"></i>
                            <div class="stat-label">Total Bills</div>
                            <div class="stat-value" id="totalBills">0</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-mild-green">
                            <i class="fas fa-rupee-sign fa-2x mb-2"></i>
                            <div class="stat-label">Total Sales</div>
                            <div class="stat-value" id="totalSales">₹0</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-mild-yellow">
                            <i class="fas fa-boxes fa-2x mb-2"></i>
                            <div class="stat-label">Total Quantity</div>
                            <div class="stat-value" id="totalQty">0</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card bg-mild-blue">
                            <i class="fas fa-chart-line fa-2x mb-2"></i>
                            <div class="stat-label">Avg Bill Value</div>
                            <div class="stat-value" id="avgBill">₹0</div>
                        </div>
                    </div>
                </div>

                <!-- Detailed Table -->
                <div class="chart-container mt-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0"><i class="fas fa-table"></i> Detailed Report</h5>
                        <span class="badge bg-secondary" id="recordCount">0 records</span>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover" id="detailsTable">
                            <thead class="table-dark">
                                <tr>
                                    <th>Bill No</th>
                                    <th>Date</th>
                                    <th>Product</th>
                                    <th>Category</th>
                                    <th>Brand</th>
                                    <th>Qty</th>
                                    <th>Price</th>
                                    <th>Discount</th>
                                    <th>Total</th>
                                </tr>
                            </thead>
                            <tbody id="detailsBody">
                                <tr>
                                    <td colspan="9" class="text-center">No data available. Please select filters and generate report.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script>
        const contextPath = '<%=contextPath%>';

        // Load statistics on page load with default date
        $(document).ready(function() {
            loadProductsByFilters(); // Load all products on page load
            loadStatistics();
        });

        function loadBrandsByCategory() {
            const categoryId = $('#categoryId').val();
            if (!categoryId) {
                // Reload all brands
                $('#brandId').val('');
                loadProductsByFilters();
                return;
            }
            
            $.get(contextPath + '/product/master/getBrandsByCategory.jsp', { categoryId: categoryId }, function(data) {
                $('#brandId').html('<option value="">All Brands</option>' + data);
                loadProductsByFilters();
            });
        }

        function loadProductsByFilters() {
            const categoryId = $('#categoryId').val();
            const brandId = $('#brandId').val();
            
            $.get(contextPath + '/reports/statistics/getProducts.jsp', { 
                categoryId: categoryId,
                brandId: brandId 
            }, function(data) {
                $('#productId').html('<option value="">All Products</option>' + data);
            });
        }

        function loadStatistics() {
            const fromDate = $('#fromDate').val();
            const toDate = $('#toDate').val();
            const categoryId = $('#categoryId').val();
            const brandId = $('#brandId').val();
            const productId = $('#productId').val();

            if (!fromDate || !toDate) {
                alert('Please select date range');
                return;
            }

            // Show loading - add opacity instead of replacing content
            $('#statsCards').css('opacity', '0.5');
            $('#detailsBody').html('<tr><td colspan="9" class="text-center"><div class="spinner-border" role="status"></div></td></tr>');

            $.ajax({
                url: contextPath + '/reports/statistics/getData.jsp',
                type: 'GET',
                dataType: 'json',
                data: {
                    fromDate: fromDate,
                    toDate: toDate,
                    categoryId: categoryId,
                    brandId: brandId,
                    productId: productId
                },
                success: function(data) {
                    // Remove loading state
                    $('#statsCards').css('opacity', '1');
                    updateStatistics(data);
                },
                error: function(xhr, status, error) {
                    // Remove loading state
                    $('#statsCards').css('opacity', '1');
                    console.error('Error:', error);
                    console.error('Response:', xhr.responseText);
                    alert('Error loading statistics: ' + error);
                }
            });
        }

        function updateStatistics(data) {
            // Update cards
            $('#totalBills').text(data.totalBills || 0);
            $('#totalSales').text('₹' + (data.totalSales || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2}));
            $('#totalQty').text((data.totalQty || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2}));
            $('#avgBill').text('₹' + (data.avgBill || 0).toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2}));

            // Update table
            let html = '';
            let recordCount = 0;
            if (data.details && data.details.length > 0) {
                recordCount = data.details.length;
                data.details.forEach(function(row) {
                    html += '<tr>';
                    html += '<td>' + row.billNo + '</td>';
                    html += '<td>' + row.date + '</td>';
                    html += '<td>' + row.productName + '</td>';
                    html += '<td>' + row.categoryName + '</td>';
                    html += '<td>' + row.brandName + '</td>';
                    html += '<td>' + parseFloat(row.qty).toFixed(2) + '</td>';
                    html += '<td>₹' + parseFloat(row.price).toFixed(2) + '</td>';
                    html += '<td>₹' + parseFloat(row.disc).toFixed(2) + '</td>';
                    html += '<td>₹' + parseFloat(row.total).toFixed(2) + '</td>';
                    html += '</tr>';
                });
            } else {
                html = '<tr><td colspan="9" class="text-center">No data found for selected filters</td></tr>';
            }
            $('#detailsBody').html(html);
            $('#recordCount').text(recordCount + ' record' + (recordCount !== 1 ? 's' : ''));
        }

        function resetFilters() {
            const today = new Date().toISOString().split('T')[0];
            $('#fromDate').val(today);
            $('#toDate').val(today);
            $('#categoryId').val('');
            $('#brandId').val('');
            $('#productId').html('<option value="">All Products</option>');
            loadStatistics();
        }
    </script>
</body>
</html>
