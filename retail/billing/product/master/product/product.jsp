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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Products - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body {
            background: #f5f7fa;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        @media (max-width: 768px) {
            .card-header .input-group {
                width: 100% !important;
                margin-top: 0.5rem;
            }
            .card-header .d-flex {
                flex-direction: column;
                align-items: stretch !important;
            }
            .card-header h6 {
                margin-bottom: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / warning / danger / info
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container-fluid mt-2" style="max-width: 1600px;">
        <div class="row g-2">
            <!-- Left Column - Add Product Form -->
            <div class="col-md-5">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px;">
                    <div class="card-header" style="background: var(--page-header-card-bg); color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <h6 class="mb-0" style="font-weight: 600; font-size: 0.95rem;"><i class="fas fa-plus-circle me-2"></i>Add New <%=head3%></h6>
                    </div>
                    <div class="card-body" style="padding: 1rem;">
                        <form id="productForm" action="<%=contextPath%>/product/master/product/product1.jsp" method="post" class="row g-2">
                            <input type="hidden" name="productId" id="editProductId" value="0">
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;"><%=head1%> <span style="color:red">*</span></label>
                                <select name="categoryId" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                    <option value="">Select <%=head1%></option>
                                    <%
                                        Vector categories = prod.getCategoryName();
                                        if (categories != null) {
                                            for (int i = 0; i < categories.size(); i++) {
                                                Vector cat = (Vector) categories.get(i);
                                                if (cat != null && cat.elementAt(0) != null && cat.elementAt(1) != null) {
                                                    String categoryName = cat.elementAt(0).toString();
                                                    String categoryId = cat.elementAt(1).toString();
                                    %>
                                        <option value="<%=categoryId%>"><%=categoryName%></option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;"><%=head2%> <span style="color:red">*</span></label>
                                <select name="brandId" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                    <option value="">Select <%=head2%></option>
                                    <%
                                        Vector brands = prod.getBrandsName();
                                        String othersBrandId = "";
                                        if (brands != null) {
                                            for (int i = 0; i < brands.size(); i++) {
                                                Vector brand = (Vector) brands.get(i);
                                                if (brand != null && brand.elementAt(0) != null && brand.elementAt(1) != null) {
                                                    String brandName = brand.elementAt(0).toString();
                                                    String brandId = brand.elementAt(1).toString();
                                                    if (brandName.equalsIgnoreCase("others") || brandName.equalsIgnoreCase("other")) {
                                                        othersBrandId = brandId;
                                                    }
                                    %>
                                        <option value="<%=brandId%>" <%=brandId.equals(othersBrandId) && !othersBrandId.isEmpty() ? "selected" : ""%>><%=brandName%></option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-12">
                                <label style="font-size: 0.85rem;"><%=head3%> Name <span style="color:red">*</span></label><input type="text" name="productName" class="form-control" placeholder="" style="padding: 7px 10px; font-size: 0.9rem;" required>
                            </div>
                            <div class="col-md-6 ">
                                <label style="font-size: 0.85rem;"><%=head3%> Code <span style="color:red">*</span></label><input type="text" name="productCode" class="form-control" placeholder="" style="padding: 7px 10px; font-size: 0.9rem;" >
                            </div>
                            <div class="col-md-6 ">
                                <label style="font-size: 0.85rem;">HSN Code</label><input type="text" name="hsn" class="form-control" placeholder=" " style="padding: 7px 10px; font-size: 0.9rem;">
                            </div>
                            
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;">Unit/Size</label>
                                <select name="unitId" id="unitSelect" class="form-select" style="padding: 7px 10px; font-size: 0.9rem;" onchange="handleUnitChange(this)" required>
                                    <option value="">Select Unit/Size</option>
                                    <%
                                        Vector units = prod.getUnits();
                                        if (units != null) {
                                            for (int i = 0; i < units.size(); i++) {
                                                Vector unit = (Vector) units.get(i);
                                                if (unit != null && unit.elementAt(0) != null && unit.elementAt(1) != null) {
                                                    String unitName = unit.elementAt(0).toString();
                                                    String unitId = unit.elementAt(1).toString();
                                                    String convertionUnit = (unit.size() > 2 && unit.elementAt(2) != null) ? unit.elementAt(2).toString() : "";
                                                    String convertionCalculation = (unit.size() > 3 && unit.elementAt(3) != null) ? unit.elementAt(3).toString() : "";
                                                    String selected = (unitName.equalsIgnoreCase("Nos") || unitName.equalsIgnoreCase("NOS") || unitName.equalsIgnoreCase("PCS")) ? "selected" : "";
                                    %>
                                        <option value="<%=unitId%>" data-convertion-unit="<%=convertionUnit%>" data-convertion-calculation="<%=convertionCalculation%>" <%=selected%>><%=unitName%></option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            
                            <div class="col-md-6 ">
                                <label style="font-size: 0.85rem;">Stock</label><input type="number" name="stock" id="stockInput" class="form-control" placeholder="" style="padding: 7px 10px; font-size: 0.9rem;" min="0" step="0.01" value="0" required>
                                <small id="stockConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            
                            <div class="col-md-6 ">
                                <label id="costPriceLabel" style="font-size: 0.85rem;">Cost Price <span style="color:red">*</span></label><input type="number" step="0.001" name="cost" id="costInput" class="form-control" placeholder=" " style="padding: 7px 10px; font-size: 0.9rem;" required>
                                <small id="costConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            <div class="col-md-6 ">
                                <label id="mrpLabel" style="font-size: 0.85rem;">MRP <span style="color:red">*</span></label><input type="number" step="0.001" name="mrp" id="mrpInput" class="form-control" placeholder=" " style="padding: 7px 10px; font-size: 0.9rem;" required>
                                <small id="mrpConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            <div class="col-md-6 ">
                                <label style="font-size: 0.85rem;">Commission (Rs)</label><input type="number" step="0.01" name="commission" id="commissionInput" class="form-control" placeholder="0.00" style="padding: 7px 10px; font-size: 0.9rem;" value="0.00">
                                <small id="commissionConversionNote" class="text-muted d-block mt-1"></small>
                            </div>
                            <div class="col-md-6 ">
                                <label style="font-size: 0.85rem;">Discount Type</label>
                                <select class="form-select" id="discType" name="discType" onchange="handleDiscTypeChange(this)" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                    <option value="0">Select Type</option>
                                    <option value="1">Rs</option>
                                    <option value="2">%</option>
                                </select>
                            </div>
                            <div class="col-md-6 ">
                                <label id="discountLabel" style="font-size: 0.85rem;">Discount</label><input type="text" id="discValue" name="discValue" class="form-control" value="0.00" style="padding: 7px 10px; font-size: 0.9rem;" readonly>
                            </div>
                            
                            <div class="col-md-6">
                                <label style="font-size: 0.85rem;">GST %</label>
                                <select class="form-select" name="gst" style="padding: 7px 10px; font-size: 0.9rem;" required>
                                    <option value="">Select GST %</option>
                                    <option value="0" selected>0%</option>
                                    <option value="5">5%</option>
                                    <option value="12">12%</option>
                                    <option value="18">18%</option>
                                    <option value="28">28%</option>
                                </select>
                            </div>
                            <div class="col-md-12 mt-2 d-flex gap-2">
                                <button type="submit" id="submitBtn" class="btn btn-primary flex-grow-1" style="padding: 8px 10px; font-size: 0.9rem;">
                                    <i class="fas fa-save me-1" id="submitBtnIcon"></i><span id="submitBtnText">Add <%=head3%></span>
                                </button>
                                <button type="button" id="cancelEditBtn" class="btn btn-secondary" style="padding: 8px 10px; font-size: 0.9rem; display: none;" onclick="resetForm()">
                                    <i class="fas fa-times me-1"></i>Cancel
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Column - Product List Table -->
            <div class="col-md-7">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px;">
                    <div class="card-header" style="background: white; border-bottom: 1px solid #f7fafc; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <div class="d-flex justify-content-between align-items-center">
                            <h6 class="mb-0" style="color: #2d3748; font-weight: 600; font-size: 0.95rem;"><i class="fas fa-list me-2"></i><%=head3%> List</h6>
                            <div class="input-group" style="width: 300px;">
                                <span class="input-group-text" style="background: #f8f9fa; border: 1px solid #dee2e6;"><i class="fas fa-search"></i></span>
                                <input type="text" id="productSearch" class="form-control" placeholder="Search products..." style="border-left: none; font-size: 0.85rem;">
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0; max-height: 380px; overflow-y: auto; overflow-x: auto;">
                        <div class="table-responsive">
                        <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; font-size: 0.85rem; table-layout: fixed; width: 100%; min-width: 600px;">
                            <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%); position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 5%;">#</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; text-align: center; border: none; font-size: 0.8rem; width: 10%;">Action</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 18%;">Name</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 10%;">Code</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 12%;"><%=head1%></th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 10%;">MRP</th>
                                    <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.8rem; width: 10%;">Stock</th>
                                </tr>
                            </thead>
                            <tbody id="productTableBody">
                                <tr>
                                    <td colspan="7" class="text-center" style="padding: 2rem;">
                                        <div class="spinner-border text-primary" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        </div>
                    </div>
                    <div class="card-footer" style="background: white; border-top: 1px solid #f7fafc; padding: 0.75rem 1rem;">
                        <div class="d-flex justify-content-between align-items-center">
                            <div id="productInfo" style="font-size: 0.85rem; color: #718096;">
                                Loading...
                            </div>
                            <nav>
                                <ul class="pagination pagination-sm mb-0" id="pagination" style="font-size: 0.8rem;">
                                    <!-- Pagination buttons will be inserted here -->
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->

    <script>
    const contextPath = '<%=contextPath%>';

    function updateStockConversionNote() {
        const unitSelect = document.getElementById('unitSelect');
        const stockInput = document.getElementById('stockInput');
        const note = document.getElementById('stockConversionNote');
        if (!unitSelect || !stockInput || !note) return;

        const selectedOption = unitSelect.options[unitSelect.selectedIndex];
        if (!selectedOption || unitSelect.value === '') {
            note.textContent = '';
            return;
        }

        const baseUnitName = selectedOption.text || '';
        const convertionUnit = selectedOption.getAttribute('data-convertion-unit') || '';
        const convertionCalculation = parseFloat(selectedOption.getAttribute('data-convertion-calculation') || '0');
        const stockValue = parseFloat(stockInput.value || '0');

        if (convertionUnit.trim() === '' || isNaN(convertionCalculation) || convertionCalculation <= 0) {
            note.textContent = '';
            return;
        }

        if (!isNaN(stockValue) && stockValue > 0) {
            const convertedStock = stockValue * convertionCalculation;
            note.textContent = 'Converted: ' + convertedStock.toFixed(3) + ' ' + convertionUnit + ' (' + stockValue + ' x ' + convertionCalculation + ')';
        } else {
            note.textContent = 'Enter stock: how many ' + convertionUnit + ' per ' + baseUnitName + '.';
        }
    }

    function updateConvertedPriceNotes() {
        const unitSelect = document.getElementById('unitSelect');
        const costInput = document.getElementById('costInput');
        const mrpInput = document.getElementById('mrpInput');
        const commissionInput = document.getElementById('commissionInput');
        const costNote = document.getElementById('costConversionNote');
        const mrpNote = document.getElementById('mrpConversionNote');
        const commissionNote = document.getElementById('commissionConversionNote');
        if (!unitSelect || !costInput || !mrpInput || !commissionInput || !costNote || !mrpNote || !commissionNote) return;

        const selectedOption = unitSelect.options[unitSelect.selectedIndex];
        if (!selectedOption || unitSelect.value === '') {
            costNote.textContent = '';
            mrpNote.textContent = '';
            commissionNote.textContent = '';
            return;
        }

        const convertionUnit = selectedOption.getAttribute('data-convertion-unit') || '';
        const convertionCalculation = parseFloat(selectedOption.getAttribute('data-convertion-calculation') || '0');
        const costValue = parseFloat(costInput.value || '0');
        const mrpValue = parseFloat(mrpInput.value || '0');
        const commissionValue = parseFloat(commissionInput.value || '0');

        if (convertionUnit.trim() === '' || isNaN(convertionCalculation) || convertionCalculation <= 0) {
            costNote.textContent = '';
            mrpNote.textContent = '';
            commissionNote.textContent = '';
            return;
        }

        if (!isNaN(costValue) && costValue > 0) {
            const convertedCost = costValue / convertionCalculation;
            costNote.textContent = 'Converted Cost per ' + convertionUnit + ': ' + convertedCost.toFixed(3);
        } else {
            costNote.textContent = '';
        }

        if (!isNaN(mrpValue) && mrpValue > 0) {
            const convertedMrp = mrpValue / convertionCalculation;
            mrpNote.textContent = 'Converted MRP per ' + convertionUnit + ': ' + convertedMrp.toFixed(3);
        } else {
            mrpNote.textContent = '';
        }

        if (!isNaN(commissionValue) && commissionValue > 0) {
            const convertedCommission = commissionValue / convertionCalculation;
            commissionNote.textContent = 'Converted Commission per ' + convertionUnit + ': ' + convertedCommission.toFixed(3);
        } else {
            commissionNote.textContent = '';
        }
    }

    function handleUnitChange(select) {
        const selectedText = select.options[select.selectedIndex].text;
        const costPriceLabel = document.getElementById('costPriceLabel');
        const mrpLabel = document.getElementById('mrpLabel');
        const discountLabel = document.getElementById('discountLabel');
        
        if (select.value === "") {
            costPriceLabel.textContent = "Cost Price";
            mrpLabel.textContent = "MRP";
            discountLabel.textContent = "Discount";
        } else {
            costPriceLabel.textContent = "Cost Price per " + selectedText;
            mrpLabel.textContent = "MRP per " + selectedText;
            discountLabel.textContent = "Discount per " + selectedText;
        }

        updateStockConversionNote();
        updateConvertedPriceNotes();
    }
    
    function handleDiscTypeChange(select) {
        const discValueInput = document.getElementById('discValue');
        if (select.value === "0") {
            discValueInput.value = "0.00";
            discValueInput.readOnly = true;
        } else {
            discValueInput.readOnly = false;
            discValueInput.value = "";
        }
    }

    // Pagination and search variables
    let currentPage = 1;
    let currentSearch = '';
    let searchTimeout = null;

    // Load products with pagination and search
    function loadProducts(page = 1, search = '') {
        currentPage = page;
        currentSearch = search;

        const tbody = document.getElementById('productTableBody');
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center" style="padding: 2rem;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </td>
            </tr>
        `;

        fetch(contextPath + '/product/master/product/getProducts.jsp?page=' + page + '&search=' + encodeURIComponent(search))
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayProducts(data);
                    updatePagination(data);
                } else {
                    tbody.innerHTML = `
                        <tr>
                            <td colspan="7" class="text-center text-danger" style="padding: 2rem;">
                                Error: ${data.error || 'Failed to load products'}
                            </td>
                        </tr>
                    `;
                }
            })
            .catch(error => {
                console.error('Error loading products:', error);
                tbody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center text-danger" style="padding: 2rem;">
                            Error loading products. Please try again.
                        </td>
                    </tr>
                `;
            });
    }

    // Display products in table
    function displayProducts(data) {
        const tbody = document.getElementById('productTableBody');
        
        if (data.products.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="7" class="text-center" style="padding: 2rem; color: #718096;">
                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                        <p class="mb-0">No products found. ${currentSearch ? 'Try a different search term.' : 'Add your first product above.'}</p>
                    </td>
                </tr>
            `;
            document.getElementById('productInfo').textContent = 'No products found';
            return;
        }

        let html = '';
        data.products.forEach(product => {
            html += `
                <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 5%;">${product.index}</td>
                    <td style="padding: 0.4rem; text-align: center; border: none; width: 10%;">
                        <button onclick="populateForm(${JSON.stringify(product).replace(/"/g, '&quot;')})" class="btn btn-sm" style="background: var(--primary-gradient); color: white; padding: 3px 10px; border-radius: 5px; border: none; font-weight: 500; font-size: 0.8rem;">
                            <i class="fas fa-edit me-1"></i>Edit
                        </button>
                    </td>
                    <td style="padding: 0.4rem; color: #2d3748; font-weight: 500; border: none; width: 18%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${product.productName}">${product.productName}</td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 10%;"><span class="badge bg-secondary">${product.prodCode || '-'}</span></td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 12%;">${product.categ}</td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 10%;">${product.mrp}</td>
                    <td style="padding: 0.4rem; color: #718096; border: none; width: 10%;">${product.stock}${product.convertionUnit ? ' <small class="text-muted">' + product.convertionUnit + '</small>' : ' ' + (product.unit || '')}</td>
                </tr>
            `;
        });

        tbody.innerHTML = html;

        // Update product info
        const start = (data.currentPage - 1) * data.pageSize + 1;
        const end = Math.min(data.currentPage * data.pageSize, data.totalProducts);
        document.getElementById('productInfo').textContent = `Showing ${start}-${end} of ${data.totalProducts} products`;
    }

    // Update pagination controls
    function updatePagination(data) {
        const pagination = document.getElementById('pagination');
        let html = '';

        // Previous button
        if (data.currentPage > 1) {
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${data.currentPage - 1}, '${currentSearch}')">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>
            `;
        } else {
            html += `
                <li class="page-item disabled">
                    <span class="page-link"><i class="fas fa-chevron-left"></i></span>
                </li>
            `;
        }

        // Page numbers
        const maxPagesToShow = 5;
        let startPage = Math.max(1, data.currentPage - Math.floor(maxPagesToShow / 2));
        let endPage = Math.min(data.totalPages, startPage + maxPagesToShow - 1);

        // Adjust start page if we're near the end
        if (endPage - startPage < maxPagesToShow - 1) {
            startPage = Math.max(1, endPage - maxPagesToShow + 1);
        }

        // First page
        if (startPage > 1) {
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(1, '${currentSearch}')">1</a>
                </li>
            `;
            if (startPage > 2) {
                html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
            }
        }

        // Page numbers
        for (let i = startPage; i <= endPage; i++) {
            if (i === data.currentPage) {
                html += `
                    <li class="page-item active">
                        <span class="page-link">${i}</span>
                    </li>
                `;
            } else {
                html += `
                    <li class="page-item">
                        <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${i}, '${currentSearch}')">${i}</a>
                    </li>
                `;
            }
        }

        // Last page
        if (endPage < data.totalPages) {
            if (endPage < data.totalPages - 1) {
                html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
            }
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${data.totalPages}, '${currentSearch}')">${data.totalPages}</a>
                </li>
            `;
        }

        // Next button
        if (data.currentPage < data.totalPages) {
            html += `
                <li class="page-item">
                    <a class="page-link" href="javascript:void(0)" onclick="loadProducts(${data.currentPage + 1}, '${currentSearch}')">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
            `;
        } else {
            html += `
                <li class="page-item disabled">
                    <span class="page-link"><i class="fas fa-chevron-right"></i></span>
                </li>
            `;
        }

        pagination.innerHTML = html;
    }

    // Product search functionality with debouncing
    document.getElementById('stockInput').addEventListener('input', updateStockConversionNote);
    document.getElementById('costInput').addEventListener('input', updateConvertedPriceNotes);
    document.getElementById('mrpInput').addEventListener('input', updateConvertedPriceNotes);
    document.getElementById('commissionInput').addEventListener('input', updateConvertedPriceNotes);

    document.getElementById('productSearch').addEventListener('input', function() {
        const searchTerm = this.value.trim();
        
        // Clear previous timeout
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        
        // Set new timeout to avoid too many requests
        searchTimeout = setTimeout(() => {
            loadProducts(1, searchTerm); // Reset to page 1 when searching
        }, 500); // Wait 500ms after user stops typing
    });

    // Populate form for editing
    function populateForm(product) {
        document.getElementById('editProductId').value = product.productId;
        document.getElementById('productForm').action = 'edit1.jsp';

        // Set form field values
        const form = document.getElementById('productForm');
        form.querySelector('[name="productName"]').value = product.productName || '';
        form.querySelector('[name="productCode"]').value = product.prodCode || '';
        form.querySelector('[name="hsn"]').value = product.hsn || '';
        form.querySelector('[name="commission"]').value = product.commission || '0.00';
        form.querySelector('[name="discValue"]').value = product.discount || '0.00';
        form.querySelector('[name="stock"]').value = '';
        form.querySelector('[name="stock"]').removeAttribute('required');
        form.querySelector('[name="stock"]').disabled = true;

        // Set category dropdown
        const catSelect = form.querySelector('[name="categoryId"]');
        for (let opt of catSelect.options) {
            if (opt.text === product.categ) { opt.selected = true; break; }
        }

        // Set brand dropdown
        const brandSelect = form.querySelector('[name="brandId"]');
        for (let opt of brandSelect.options) {
            if (opt.text === product.brandss) { opt.selected = true; break; }
        }

        // Set unit dropdown
        const unitSelect = form.querySelector('[name="unitId"]');
        for (let opt of unitSelect.options) {
            if (opt.value == product.unitId) { opt.selected = true; break; }
        }

        // In edit mode, show values in selected unit if conversion exists.
        const selectedUnitOption = unitSelect.options[unitSelect.selectedIndex];
        const convertionCalculation = selectedUnitOption ? parseFloat(selectedUnitOption.getAttribute('data-convertion-calculation') || '0') : 0;
        const parsedCost = parseFloat(product.cost || '0');
        const parsedMrp = parseFloat(product.mrp || '0');
        const editCost = (!isNaN(convertionCalculation) && convertionCalculation > 0 && !isNaN(parsedCost)) ? (parsedCost * convertionCalculation) : parsedCost;
        const editMrp = (!isNaN(convertionCalculation) && convertionCalculation > 0 && !isNaN(parsedMrp)) ? (parsedMrp * convertionCalculation) : parsedMrp;
        form.querySelector('[name="cost"]').value = !isNaN(editCost) ? editCost : '';
        form.querySelector('[name="mrp"]').value = !isNaN(editMrp) ? editMrp : '';

        handleUnitChange(unitSelect);

        // Set GST dropdown
        const gstSelect = form.querySelector('[name="gst"]');
        for (let opt of gstSelect.options) {
            if (opt.value == product.gst) { opt.selected = true; break; }
        }

        // Set discount type
        const discTypeSelect = document.getElementById('discType');
        for (let opt of discTypeSelect.options) {
            if (opt.value == product.discType) { opt.selected = true; break; }
        }
        handleDiscTypeChange(discTypeSelect);
        document.getElementById('discValue').value = product.discount || '0.00';

        // Update button
        document.getElementById('submitBtnText').textContent = 'Update';
        document.getElementById('submitBtnIcon').className = 'fas fa-pen me-1';
        document.getElementById('submitBtn').classList.remove('btn-primary');
        document.getElementById('submitBtn').classList.add('btn-success');
        document.getElementById('cancelEditBtn').style.display = 'inline-block';

        // Update card header
        document.querySelector('.card-header h6').innerHTML = '<i class="fas fa-edit me-2"></i>Edit ' + (product.productName || '');

        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Reset form back to Add mode
    function resetForm() {
        document.getElementById('editProductId').value = '0';
        document.getElementById('productForm').action = 'product1.jsp';
        document.getElementById('productForm').reset();

        // Re-enable stock
        const stockInput = document.querySelector('[name="stock"]');
        stockInput.disabled = false;
        stockInput.setAttribute('required', 'required');
        stockInput.value = '0';

        // Reset button
        document.getElementById('submitBtnText').textContent = 'Add';
        document.getElementById('submitBtnIcon').className = 'fas fa-save me-1';
        document.getElementById('submitBtn').classList.remove('btn-success');
        document.getElementById('submitBtn').classList.add('btn-primary');
        document.getElementById('cancelEditBtn').style.display = 'none';

        // Reset card header
        document.querySelector('.card-header h6').innerHTML = '<i class="fas fa-plus-circle me-2"></i>Add New Product';

        // Reset discount
        document.getElementById('discValue').value = '0.00';
        document.getElementById('discValue').readOnly = true;

        // Reset commission
        document.getElementById('commissionInput').value = '0.00';

        // Reset labels
        document.getElementById('costPriceLabel').textContent = 'Cost Price';
        document.getElementById('mrpLabel').textContent = 'MRP';
        document.getElementById('discountLabel').textContent = 'Discount';
        document.getElementById('costConversionNote').textContent = '';
        document.getElementById('mrpConversionNote').textContent = '';

        // Re-select defaults (NOS unit, Others brand, 0% GST)
        const unitSelect = document.querySelector('[name="unitId"]');
        for (let opt of unitSelect.options) {
            if (opt.text === 'NOS' || opt.text === 'Nos' || opt.text === 'PCS') { opt.selected = true; break; }
        }
        const brandSelect = document.querySelector('[name="brandId"]');
        for (let opt of brandSelect.options) {
            if (opt.text.toLowerCase() === 'others' || opt.text.toLowerCase() === 'other') { opt.selected = true; break; }
        }
        const gstSelect = document.querySelector('[name="gst"]');
        for (let opt of gstSelect.options) {
            if (opt.value === '0') { opt.selected = true; break; }
        }

        handleUnitChange(unitSelect);
        updateStockConversionNote();
        updateConvertedPriceNotes();
    }

    // Load products on page load
    document.addEventListener('DOMContentLoaded', function() {
        loadProducts(1, '');
        handleUnitChange(document.getElementById('unitSelect'));
        updateStockConversionNote();
        updateConvertedPriceNotes();
    });
</script>
</body>
</html>
