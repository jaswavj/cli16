<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<jsp:useBean id="prodBean" class="product.productBean" />
<%
    int poId = 0;
    String idParam = request.getParameter("id");
    if (idParam != null && !idParam.isEmpty()) {
        try {
            poId = Integer.parseInt(idParam);
        } catch (Exception e) {
            out.print("<script>alert('Invalid PO ID'); window.location.href='" + request.getContextPath() + "/product/purchase/order/list.jsp';</script>");
            return;
        }
    } else {
        out.print("<script>alert('PO ID required'); window.location.href='" + request.getContextPath() + "/product/purchase/order/list.jsp';</script>");
        return;
    }
    
    // Get PO header
    Vector poHeader = poBean.getPOHeader(poId);
    if (poHeader == null || poHeader.size() == 0) {
        out.print("<script>alert('PO not found'); window.location.href='" + request.getContextPath() + "/product/purchase/order/list.jsp';</script>");
        return;
    }
    
    // Get PO items
    Vector poItems = poBean.getPOAllItems(poId);
    
    // Extract header data
    String poNo = poHeader.get(0).toString();
    String poDate = poHeader.get(1).toString();
    String expectedDate = poHeader.get(2).toString();
    double total = (Double) poHeader.get(3);
    int poStatus = (Integer) poHeader.get(4);
    String poNotes = poHeader.get(5) != null ? poHeader.get(5).toString() : "";
    String supplierName = poHeader.get(6).toString();
    int supplierId = (Integer) poHeader.get(10);
    
    // Check if editable
    if (poStatus != 1) {
        out.print("<script>alert('Only draft purchase orders can be edited'); window.location.href='" + request.getContextPath() + "/product/purchase/order/details.jsp?id=" + poId + "';</script>");
        return;
    }
    
    // Get all suppliers for dropdown
    Vector suppliers = prodBean.GetSupplier();
    
    // Get all products for autocomplete
    Vector products = prodBean.getProductName();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit PO - <%= poNo %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Edit Purchase Order - <%= poNo %></h4>
                <a href="details.jsp?id=<%= poId %>" class="btn btn-secondary">
                    <i class="fas fa-arrow-left me-2"></i>Cancel
                </a>
            </div>

            <div class="card">
                <div class="card-body">
                    <form id="editPOForm">
                        <input type="hidden" name="poId" value="<%= poId %>">
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Supplier *</label>
                                <select class="form-select" id="supplierId" name="supplierId" required>
                                    <option value="">Select Supplier</option>
                                    <%
                                        for (int i = 0; i < suppliers.size(); i++) {
                                            Vector supplier = (Vector) suppliers.get(i);
                                            String sidStr = supplier.get(0).toString();
                                            int sid = Integer.parseInt(sidStr);
                                            String sname = supplier.get(1).toString();
                                    %>
                                    <option value="<%= sid %>" <%= sid == supplierId ? "selected" : "" %>><%= sname %></option>
                                    <%
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Expected Date</label>
                                <input type="date" class="form-control" id="expectedDate" name="expectedDate" value="<%= expectedDate %>">
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-12">
                                <label class="form-label">Notes</label>
                                <textarea class="form-control" id="poNotes" name="poNotes" rows="2"><%= poNotes %></textarea>
                            </div>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5>Order Items</h5>
                            <button type="button" class="btn btn-success btn-sm" onclick="addNewRow()">
                                <i class="fas fa-plus me-2"></i>Add Product
                            </button>
                        </div>

                        <div class="table-responsive">
                            <table class="table table-bordered" id="itemsTable">
                                <thead class="table-light">
                                    <tr>
                                        <th width="5%">S.No</th>
                                        <th width="30%">Product</th>
                                        <th width="15%">Rate</th>
                                        <th width="15%">Quantity</th>
                                        <th width="15%">Total</th>
                                        <th width="10%">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="itemsBody">
                                    <%
                                        for (int i = 0; i < poItems.size(); i++) {
                                            Vector item = (Vector) poItems.get(i);
                                            
                                            int poDetailId = (Integer) item.get(8);
                                            String prodName = item.get(0).toString();
                                            double rate = (Double) item.get(3);
                                            double qty = Double.parseDouble(item.get(4).toString());
                                            double lineTotal = qty * rate;
                                    %>
                                    <tr data-detail-id="<%= poDetailId %>">
                                        <td><%= i + 1 %></td>
                                        <td><%= prodName %></td>
                                        <td class="text-end">₹<%= String.format("%.3f", rate) %></td>
                                        <td class="text-end"><%= qty %></td>
                                        <td class="text-end">₹<%= String.format("%.3f", lineTotal) %></td>
                                        <td>
                                            <button type="button" class="btn btn-sm btn-danger" onclick="removeExistingRow(this, <%= poDetailId %>)">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                                <tfoot>
                                    <tr class="table-light">
                                        <th colspan="4" class="text-end">Grand Total:</th>
                                        <th class="text-end" id="grandTotal">₹<%= String.format("%.3f", total) %></th>
                                        <th></th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div class="mt-3 text-end">
                            <a href="details.jsp?id=<%= poId %>" class="btn btn-secondary">Cancel</a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Save Changes
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
    // Load products for autocomplete
    let allProducts = [];
    
    <%
        for (int i = 0; i < products.size(); i++) {
            Vector prod = (Vector) products.get(i);
            String pname = prod.get(0).toString();
            String pidStr = prod.get(1).toString();
            int pid = Integer.parseInt(pidStr);
    %>
    allProducts.push({ id: <%= pid %>, name: '<%= pname.replace("'", "\\'") %>', rate: 0 });
    <%
        }
    %>

    function addNewRow() {
        const tbody = $('#itemsBody');
        const rowCount = tbody.find('tr').length;
        
        const newRow = $(`
            <tr class="new-item">
                <td>${rowCount + 1}</td>
                <td>
                    <input type="text" class="form-control form-control-sm product-search" placeholder="Search product...">
                    <input type="hidden" class="product-id" value="0">
                </td>
                <td><input type="number" class="form-control form-control-sm rate-input" step="0.001" min="0" value="0"></td>
                <td><input type="number" class="form-control form-control-sm qty-input" min="1" value="1"></td>
                <td class="text-end line-total">₹0.00</td>
                <td><button type="button" class="btn btn-sm btn-danger" onclick="removeNewRow(this)"><i class="fas fa-trash"></i></button></td>
            </tr>
        `);
        
        tbody.append(newRow);
        
        // Setup autocomplete for new row
        const searchInput = newRow.find('.product-search');
        searchInput.autocomplete({
            source: allProducts.map(p => ({ label: p.name, value: p.name, id: p.id, rate: p.rate })),
            select: function(event, ui) {
                newRow.find('.product-id').val(ui.item.id);
                newRow.find('.rate-input').val(ui.item.rate);
                calculateLineTotal(newRow);
            }
        });
        
        // Calculate line total on rate/qty change
        newRow.find('.rate-input, .qty-input').on('input', function() {
            calculateLineTotal(newRow);
        });
        
        renumberRows();
    }

    function removeNewRow(btn) {
        $(btn).closest('tr').remove();
        renumberRows();
        calculateGrandTotal();
    }

    function removeExistingRow(btn, detailId) {
        Swal.fire({
            title: 'Remove Item?',
            text: 'This item will be removed from the purchase order.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Yes, Remove',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                $(btn).closest('tr').remove();
                renumberRows();
                calculateGrandTotal();
            }
        });
    }

    function calculateLineTotal(row) {
        const rate = parseFloat(row.find('.rate-input').val()) || 0;
        const qty = parseFloat(row.find('.qty-input').val()) || 0;
        const total = rate * qty;
        row.find('.line-total').text('₹' + total.toFixed(3));
        calculateGrandTotal();
    }

    function calculateGrandTotal() {
        let grand = 0;
        $('#itemsBody tr').each(function() {
            const row = $(this);
            if (row.hasClass('new-item')) {
                const rate = parseFloat(row.find('.rate-input').val()) || 0;
                const qty = parseFloat(row.find('.qty-input').val()) || 0;
                grand += (rate * qty);
            } else {
                const totalText = row.find('td:eq(4)').text().replace('₹', '').replace(',', '');
                grand += parseFloat(totalText) || 0;
            }
        });
        $('#grandTotal').text('₹' + grand.toFixed(3));
    }

    function renumberRows() {
        $('#itemsBody tr').each(function(index) {
            $(this).find('td:first').text(index + 1);
        });
    }

    // Submit form
    $('#editPOForm').on('submit', function(e) {
        e.preventDefault();
        
        const supplierId = $('#supplierId').val();
        const expectedDate = $('#expectedDate').val();
        const poNotes = $('#poNotes').val();
        
        if (!supplierId) {
            Swal.fire('Error', 'Please select a supplier', 'error');
            return;
        }
        
        // Collect existing items to update
        const existingItems = [];
        $('#itemsBody tr:not(.new-item)').each(function() {
            const detailId = $(this).data('detail-id');
            if (detailId) {
                existingItems.push(detailId);
            }
        });
        
        // Collect new items
        const newItems = [];
        $('#itemsBody tr.new-item').each(function() {
            const row = $(this);
            const prodId = row.find('.product-id').val();
            const rate = row.find('.rate-input').val();
            const qty = row.find('.qty-input').val();
            
            if (!prodId || prodId == '0') {
                Swal.fire('Error', 'Please select a product for all new items', 'error');
                return false;
            }
            
            newItems.push({
                prodId: prodId,
                rate: rate,
                qty: qty
            });
        });
        
        // Send update request
        $.ajax({
            url: 'updatePO.jsp',
            method: 'POST',
            data: {
                poId: <%= poId %>,
                supplierId: supplierId,
                expectedDate: expectedDate,
                poNotes: poNotes,
                existingItems: JSON.stringify(existingItems),
                newItems: JSON.stringify(newItems)
            },
            success: function(response) {
                if (response.trim() === 'success') {
                    Swal.fire('Success!', 'Purchase order updated successfully', 'success').then(() => {
                        window.location.href = '<%=contextPath%>/product/purchase/order/details.jsp?id=<%= poId %>';
                    });
                } else {
                    Swal.fire('Error', response, 'error');
                }
            },
            error: function() {
                Swal.fire('Error', 'Failed to update purchase order', 'error');
            }
        });
    });
    </script>
</body>
</html>
