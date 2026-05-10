<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<%
    int poId = 0;
    String poIdParam = request.getParameter("poId");
    if (poIdParam != null && !poIdParam.isEmpty()) {
        try {
            poId = Integer.parseInt(poIdParam);
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
    
    // Get pending items for receipt  
    Vector pendingData = poBean.getPOPendingItems(poId);
    
    if (pendingData == null || pendingData.size() < 2) {
        out.print("<script>alert('Error loading PO data'); window.location.href='" + request.getContextPath() + "/product/purchase/order/list.jsp';</script>");
        return;
    }
    
    Vector poHeaderData = (Vector) pendingData.get(0);
    Vector pendingItems = (Vector) pendingData.get(1);
    
    if (pendingItems.size() == 0) {
        out.print("<script>alert('No pending items to receive for this PO'); window.location.href='" + request.getContextPath() + "/product/purchase/order/details.jsp?id=" + poId + "';</script>");
        return;
    }
    
    // Extract header data
    String poNo = poHeader.get(0).toString();
    String poDate = poHeader.get(1).toString();
    String expectedDate = poHeader.get(2).toString();
    double total = (Double) poHeader.get(3);
    int poStatus = (Integer) poHeader.get(4);
    String supplierName = poHeader.get(6).toString();
    int supplierId = (Integer) poHeader.get(10);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Receive Goods - <%= poNo %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
    <style>
        .over-qty {
            background-color: #ffcccc !important;
            border-color: #ff0000 !important;
        }
        .table-product input[type="number"] {
            width: 100px;
        }
    </style>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container-fluid mt-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Receive Goods</h4>
                <a href="<%=contextPath%>/product/purchase/order/details.jsp?id=<%= poId %>" class="btn btn-secondary">
                    <i class="fas fa-arrow-left me-2"></i>Back to PO
                </a>
            </div>

            <!-- PO Reference Card -->
            <div class="card mb-3">
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            <p class="mb-1"><strong>PO Number:</strong> <%= poNo %></p>
                            <p class="mb-0"><strong>PO Date:</strong> <%= poDate %></p>
                        </div>
                        <div class="col-md-4">
                            <p class="mb-1"><strong>Supplier:</strong> <%= supplierName %></p>
                            <p class="mb-0"><strong>Expected:</strong> <%= expectedDate %></p>
                        </div>
                        <div class="col-md-4">
                            <p class="mb-1"><strong>Total Amount:</strong> ₹<%= String.format("%.3f", total) %></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Receipt Form -->
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-truck me-2"></i>Goods Receipt Entry
                    </h5>
                </div>
                <div class="card-body">
                    <form id="receiptForm">
                        <input type="hidden" id="poId" value="<%= poId %>">
                        <input type="hidden" id="supplierId" value="<%= supplierId %>">
                        
                        <div class="row mb-3">
                            <div class="col-md-4">
                                <label class="form-label">Receipt Date <span class="text-danger">*</span></label>
                                <input type="date" class="form-control" id="receiptDate" 
                                       value="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Invoice Number</label>
                                <input type="text" class="form-control" id="invoiceNo" placeholder="Supplier Invoice No">
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Challan Number</label>
                                <input type="text" class="form-control" id="challanNo" placeholder="Delivery Challan No">
                            </div>
                        </div>

                        <!-- Pending Items Table -->
                        <div class="table-responsive">
                            <table class="table table-bordered table-product">
                                <thead class="table-light">
                                    <tr>
                                        <th>S.No</th>
                                        <th>Product</th>
                                        <th>Batch</th>
                                        <th>Unit</th>
                                        <th class="text-end">Rate</th>
                                        <th class="text-end">Ordered</th>
                                        <th class="text-end">Previously Received</th>
                                        <th class="text-end">Pending</th>
                                        <th class="text-end">Receive Now <span class="text-danger">*</span></th>
                                        <th class="text-end">Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="productTable">
                                    <%
                                        for (int i = 0; i < pendingItems.size(); i++) {
                                            Vector item = (Vector) pendingItems.get(i);
                                            
                                            int detailsId = (Integer) item.get(8); // prod_purchase_details.id
                                            int prodId = (Integer) item.get(9);
                                            int batchId = (Integer) item.get(10);
                                            String prodName = item.get(0).toString();
                                            String batchName = item.get(1).toString();
                                            String unitName = item.get(2).toString();
                                            double rate = (Double) item.get(3);
                                            int orderedQty = (Integer) item.get(4);
                                            int receivedQty = (Integer) item.get(5);
                                            int pendingQty = (Integer) item.get(6);
                                    %>
                                    <tr data-detail-id="<%= detailsId %>" data-prod-id="<%= prodId %>" data-batch-id="<%= batchId %>">
                                        <td><%= i + 1 %></td>
                                        <td><%= prodName %></td>
                                        <td><%= batchName %></td>
                                        <td><%= unitName %></td>
                                        <td class="text-end">₹<%= String.format("%.3f", rate) %></td>
                                        <td class="text-end ordered-qty"><%= orderedQty %></td>
                                        <td class="text-end received-qty"><%= receivedQty %></td>
                                        <td class="text-end pending-qty"><%= pendingQty %></td>
                                        <td class="text-end">
                                            <input type="number" class="form-control text-end receive-qty" 
                                                   min="0" max="<%= pendingQty %>" value="<%= pendingQty %>" 
                                                   data-rate="<%= rate %>" data-pending="<%= pendingQty %>"
                                                   onchange="validateReceivedQty(this); calculateLineTotal(this);">
                                        </td>
                                        <td class="text-end line-total">₹<%= String.format("%.3f", pendingQty * rate) %></td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                                <tfoot class="table-light">
                                    <tr>
                                        <th colspan="9" class="text-end">Grand Total:</th>
                                        <th class="text-end" id="grandTotal">₹0.00</th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div class="row mt-3">
                            <div class="col-md-6">
                                <label class="form-label">Receipt Notes</label>
                                <textarea class="form-control" id="receiptNotes" rows="3" placeholder="Any remarks about this receipt..."></textarea>
                            </div>
                            <div class="col-md-6">
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    <strong>Important:</strong> You can receive partial quantities. 
                                    Received quantity cannot exceed pending quantity. Enter 0 to skip items.
                                </div>
                            </div>
                        </div>

                        <div class="text-end mt-3">
                            <button type="button" class="btn btn-secondary me-2" onclick="window.location.href='<%=contextPath%>/product/purchase/order/details.jsp?id=<%= poId %>'">
                                <i class="fas fa-times me-2"></i>Cancel
                            </button>
                            <button type="button" class="btn btn-primary" onclick="savePurchaseEntry()">
                                <i class="fas fa-save me-2"></i>Save Receipt
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
    <script>
        $(document).ready(function() {
            calculateGrandTotal();
        });

        function validateReceivedQty(input) {
            var receivedQty = parseInt($(input).val()) || 0;
            var pendingQty = parseInt($(input).data('pending'));
            
            if (receivedQty > pendingQty) {
                $(input).addClass('over-qty');
                Swal.fire({
                    icon: 'error',
                    title: 'Invalid Quantity',
                    text: 'Received quantity cannot exceed pending quantity (' + pendingQty + ')',
                    confirmButtonColor: '#d33'
                });
                $(input).val(pendingQty);
                return false;
            } else {
                $(input).removeClass('over-qty');
                return true;
            }
        }

        function calculateLineTotal(input) {
            var row = $(input).closest('tr');
            var receivedQty = parseInt($(input).val()) || 0;
            var rate = parseFloat($(input).data('rate'));
            var lineTotal = receivedQty * rate;
            
            row.find('.line-total').text('₹' + lineTotal.toFixed(3));
            calculateGrandTotal();
        }

        function calculateGrandTotal() {
            var grandTotal = 0;
            $('.receive-qty').each(function() {
                var receivedQty = parseInt($(this).val()) || 0;
                var rate = parseFloat($(this).data('rate'));
                grandTotal += receivedQty * rate;
            });
            
            $('#grandTotal').text('₹' + grandTotal.toFixed(3));
        }

        function savePurchaseEntry() {
            // Validate receipt date
            var receiptDate = $('#receiptDate').val();
            if (!receiptDate) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Missing Information',
                    text: 'Please enter receipt date',
                    confirmButtonColor: '#ffc107'
                });
                $('#receiptDate').focus();
                return;
            }
            
            // Collect received items
            var receivedItems = [];
            var hasItems = false;
            
            $('#productTable tr').each(function() {
                var row = $(this);
                var receiveQtyInput = row.find('.receive-qty');
                if (receiveQtyInput.length > 0) {
                    var receiveQty = parseFloat(receiveQtyInput.val()) || 0;
                    
                    if (receiveQty > 0) {
                        hasItems = true;
                        var detailsId = row.data('detail-id');
                        var prodId = row.data('prod-id');
                        var batchId = row.data('batch-id');
                        var rate = parseFloat(receiveQtyInput.data('rate'));
                        var pendingQty = parseFloat(receiveQtyInput.data('pending'));
                        
                        // Validate before adding
                        if (receiveQty > pendingQty) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Invalid Quantity',
                                text: 'One or more items have received quantity exceeding pending quantity',
                                confirmButtonColor: '#d33'
                            });
                            return false;
                        }
                        
                        receivedItems.push({
                            detailsId: detailsId,
                            prodId: prodId,
                            batchId: batchId,
                            qty: receiveQty,
                            rate: rate
                        });
                    }
                }
            });
            
            if (!hasItems) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Items',
                    text: 'Please enter at least one received quantity greater than 0',
                    confirmButtonColor: '#ffc107'
                });
                return;
            }
            
            // Prepare data
            var data = {
                poId: $('#poId').val(),
                supplierId: $('#supplierId').val(),
                receiptDate: receiptDate,
                invoiceNo: $('#invoiceNo').val(),
                challanNo: $('#challanNo').val(),
                receiptNotes: $('#receiptNotes').val(),
                items: receivedItems
            };
            
            // Show confirmation
            Swal.fire({
                title: 'Confirm Receipt',
                text: 'Save goods receipt for ' + receivedItems.length + ' item(s)?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#0d6efd',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, save it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Submit to backend
                    $.ajax({
                        url: 'savePurchaseEntry.jsp',
                        type: 'POST',
                        data: JSON.stringify(data),
                        contentType: 'application/json',
                        success: function(response) {
                            response = response.trim();
                            
                            if (response.startsWith('PR')) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Purchase Entry ' + response + ' created successfully',
                                    confirmButtonColor: '#198754'
                                }).then(() => {
                                    window.location.href = '<%=contextPath%>/product/purchase/order/details.jsp?id=' + $('#poId').val();
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Failed',
                                    text: response,
                                    confirmButtonColor: '#d33'
                                });
                            }
                        },
                        error: function() {
                            Swal.fire({
                                icon: 'error',
                                title: 'Network Error',
                                text: 'Failed to save purchase entry',
                                confirmButtonColor: '#d33'
                            });
                        }
                    });
                }
            });
        }
    </script>
</body>
</html>
