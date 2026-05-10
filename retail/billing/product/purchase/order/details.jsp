<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
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
    
    // Get ALL PO items (for details view)
    Vector poItems = poBean.getPOAllItems(poId);
    
    // Get receipt history
    Vector receiptHistory = poBean.getPOReceiptHistory(poId);
    
    // Extract header data
    String poNo = poHeader.get(0).toString();
    String poDate = poHeader.get(1).toString();
    String expectedDate = poHeader.get(2).toString();
    double total = (Double) poHeader.get(3);
    int poStatus = (Integer) poHeader.get(4);
    String poNotes = poHeader.get(5) != null ? poHeader.get(5).toString() : "";
    String supplierName = poHeader.get(6).toString();
    String userName = poHeader.get(7).toString();
    Integer prId = poHeader.get(8) != null ? (Integer) poHeader.get(8) : null;
    String prNo = poHeader.get(9) != null ? poHeader.get(9).toString() : null;
    
    String statusText = "";
    String statusBadge = "";
    switch (poStatus) {
        case 1: statusText = "Draft"; statusBadge = "bg-secondary"; break;
        case 2: statusText = "Sent to Supplier"; statusBadge = "bg-info"; break;
        case 3: statusText = "Partially Received"; statusBadge = "bg-warning"; break;
        case 4: statusText = "Completed"; statusBadge = "bg-success"; break;
        default: statusText = "Unknown"; statusBadge = "bg-dark";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PO Details - <%= poNo %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Purchase Order Details</h4>
                <a href="<%=contextPath%>/product/purchase/order/list.jsp" class="btn btn-secondary">
                    <i class="fas fa-arrow-left me-2"></i>Back to List
                </a>
            </div>

            <!-- PO Header Card -->
            <div class="card mb-3">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0">
                        <i class="fas fa-file-invoice me-2"></i>
                        <%= poNo %>
                        <span class="badge <%= statusBadge %> float-end"><%= statusText %></span>
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <p><strong>PO Date:</strong> <%= poDate %></p>
                            <p><strong>Expected Date:</strong> <%= expectedDate != null ? expectedDate : "Not specified" %></p>
                            <p><strong>Supplier:</strong> <%= supplierName %></p>
                            <p><strong>Created By:</strong> <%= userName %></p>
                            <% if (prId != null && prNo != null) { %>
                            <p><strong>From PR:</strong> 
                                <a href="<%=contextPath%>/product/purchase/request/details.jsp?id=<%= prId %>" class="btn btn-sm btn-link">
                                    <%= prNo %>
                                </a>
                            </p>
                            <% } %>
                        </div>
                        <div class="col-md-6">
                            <p><strong>Total Amount:</strong> <span class="text-success fs-4">₹<%= String.format("%.3f", total) %></span></p>
                            <% if (poNotes != null && !poNotes.isEmpty()) { %>
                            <p><strong>Notes:</strong><br><%= poNotes %></p>
                            <% } %>
                        </div>
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="mt-3">
                        <% if (poStatus == 1) { %>
                        <button type="button" class="btn btn-warning" onclick="editPO()">
                            <i class="fas fa-edit me-2"></i>Edit PO
                        </button>
                        <button type="button" class="btn btn-danger" onclick="cancelPO()">
                            <i class="fas fa-times-circle me-2"></i>Cancel Order
                        </button>
                        <% } %>
                        <% if (poStatus == 2 || poStatus == 3) { %>
                        <a href="<%=contextPath%>/product/purchase/order/receiveGoods.jsp?poId=<%= poId %>" class="btn btn-primary">
                            <i class="fas fa-truck me-2"></i>Receive Goods
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- PO Items Card -->
            <div class="card mb-3">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-list me-2"></i>Order Items
                    </h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>S.No</th>
                                    <th>Product</th>
                                    <th>Batch</th>
                                    <th>Unit</th>
                                    <th class="text-end">Rate</th>
                                    <th class="text-end">Ordered Qty</th>
                                    <th class="text-end">Received Qty</th>
                                    <th class="text-end">Pending Qty</th>
                                    <th class="text-end">Total</th>
                                    <th>Status</th>
                                    <% if (poStatus == 1) { %>
                                    <th>Action</th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    double grandTotal = 0;
                                    int totalOrdered = 0;
                                    int totalReceived = 0;
                                    int totalPending = 0;
                                    
                                    for (int i = 0; i < poItems.size(); i++) {
                                        Vector item = (Vector) poItems.get(i);
                                        
                                        int poDetailId = (Integer) item.get(8); // Added detail ID for editing
                                        String prodName = item.get(0).toString();
                                        String batchName = item.get(1).toString();
                                        String unitName = item.get(2).toString();
                                        double rate = (Double) item.get(3);
                                        int orderedQty = (Integer) item.get(4);
                                        int receivedQty = (Integer) item.get(5);
                                        int pendingQty = (Integer) item.get(6);
                                        int isFullyReceived = (Integer) item.get(7);
                                        double lineTotal = orderedQty * rate;
                                        
                                        grandTotal += lineTotal;
                                        totalOrdered += orderedQty;
                                        totalReceived += receivedQty;
                                        totalPending += pendingQty;
                                        
                                        String itemStatus = isFullyReceived == 1 ? "Complete" : (receivedQty > 0 ? "Partial" : "Pending");
                                        String itemBadge = isFullyReceived == 1 ? "bg-success" : (receivedQty > 0 ? "bg-warning" : "bg-secondary");
                                %>
                                <tr id="row-<%= poDetailId %>">
                                    <td><%= i + 1 %></td>
                                    <td><%= prodName %></td>
                                    <td><%= batchName %></td>
                                    <td><%= unitName %></td>
                                    <td class="text-end">₹<%= String.format("%.3f", rate) %></td>
                                    <td class="text-end"><%= orderedQty %></td>
                                    <td class="text-end text-success"><%= receivedQty %></td>
                                    <td class="text-end text-danger"><%= pendingQty %></td>
                                    <td class="text-end">₹<%= String.format("%.3f", lineTotal) %></td>
                                    <td><span class="badge <%= itemBadge %>"><%= itemStatus %></span></td>
                                    <% if (poStatus == 1) { %>
                                    <td>
                                        <button class="btn btn-sm btn-primary" onclick="editItem(<%= poDetailId %>)">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn btn-sm btn-danger" onclick="deleteItem(<%= poDetailId %>, '<%= prodName %>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                    <% } %>
                                </tr>
                                <%
                                    }
                                %>
                                <tr class="table-light">
                                    <th colspan="5" class="text-end">Total:</th>
                                    <th class="text-end"><%= totalOrdered %></th>
                                    <th class="text-end text-success"><%= totalReceived %></th>
                                    <th class="text-end text-danger"><%= totalPending %></th>
                                    <th class="text-end">₹<%= String.format("%.3f", grandTotal) %></th>
                                    <th></th>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Receipt History Card -->
            <% if (receiptHistory.size() > 0) { %>
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">
                        <i class="fas fa-history me-2"></i>Receipt History
                    </h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>S.No</th>
                                    <th>PE Number</th>
                                    <th>Receipt Date</th>
                                    <th>Received By</th>
                                    <th class="text-end">Items Received</th>
                                    <th class="text-end">Amount</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (int i = 0; i < receiptHistory.size(); i++) {
                                        Vector receipt = (Vector) receiptHistory.get(i);
                                        
                                        int peId = (Integer) receipt.get(0);
                                        String peNo = receipt.get(1).toString();
                                        String peDate = receipt.get(2).toString();
                                        String receivedBy = receipt.get(3).toString();
                                        int itemsReceived = (Integer) receipt.get(4);
                                        double peTotal = (Double) receipt.get(5);
                                %>
                                <tr>
                                    <td><%= i + 1 %></td>
                                    <td><strong><%= peNo %></strong></td>
                                    <td><%= peDate %></td>
                                    <td><%= receivedBy %></td>
                                    <td class="text-end"><%= itemsReceived %></td>
                                    <td class="text-end">₹<%= String.format("%.3f", peTotal) %></td>
                                    <td>
                                        <a href="<%=contextPath%>/product/purchase/details.jsp?id=<%= peId %>" class="btn btn-sm btn-info" target="_blank">
                                            <i class="fas fa-external-link-alt"></i> View PE
                                        </a>
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
            <% } %>
        </div>
    </div>

    <script>
    const poId = <%= poId %>;
    const poStatus = <%= poStatus %>;

    // Send to Supplier
    function sendToSupplier() {
        Swal.fire({
            title: 'Send to Supplier?',
            text: 'This will send the purchase order to the supplier.',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Yes, Send',
            cancelButtonText: 'Cancel'
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    url: 'sendToSupplier.jsp',
                    method: 'POST',
                    data: { poId: poId },
                    success: function(response) {
                        if (response.trim() === 'success') {
                            Swal.fire('Sent!', 'Purchase order sent to supplier.', 'success').then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire('Error', response, 'error');
                        }
                    },
                    error: function() {
                        Swal.fire('Error', 'Failed to send purchase order.', 'error');
                    }
                });
            }
        });
    }

    // Edit PO
    function editPO() {
        window.location.href = '<%=contextPath%>/product/purchase/order/edit.jsp?id=' + poId;
    }

    // Cancel PO
    function cancelPO() {
        Swal.fire({
            title: 'Cancel Purchase Order?',
            text: 'This will permanently cancel the entire purchase order. This action cannot be undone.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Yes, Cancel Order',
            cancelButtonText: 'No, Keep It',
            confirmButtonColor: '#d33'
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    url: 'cancelPO.jsp',
                    method: 'POST',
                    data: { poId: poId },
                    success: function(response) {
                        if (response.trim() === 'success') {
                            Swal.fire('Cancelled!', 'Purchase order has been cancelled.', 'success').then(() => {
                                window.location.href = '<%=contextPath%>/product/purchase/order/list.jsp';
                            });
                        } else {
                            Swal.fire('Error', response, 'error');
                        }
                    },
                    error: function() {
                        Swal.fire('Error', 'Failed to cancel purchase order.', 'error');
                    }
                });
            }
        });
    }

    // Edit Item
    function editItem(poDetailId) {
        // Get current row data
        const row = $('#row-' + poDetailId);
        const qty = parseInt(row.find('td:eq(5)').text());
        const rate = parseFloat(row.find('td:eq(4)').text().replace('₹', ''));

        Swal.fire({
            title: 'Edit Item',
            html: `
                <div class="mb-3">
                    <label class="form-label">Quantity</label>
                    <input type="number" id="edit-qty" class="form-control" value="${qty}" min="1">
                </div>
                <div class="mb-3">
                    <label class="form-label">Rate</label>
                    <input type="number" id="edit-rate" class="form-control" value="${rate}" min="0" step="0.001">
                </div>
            `,
            showCancelButton: true,
            confirmButtonText: 'Update',
            preConfirm: () => {
                const newQty = parseInt($('#edit-qty').val());
                const newRate = parseFloat($('#edit-rate').val());
                
                if (!newQty || newQty < 1) {
                    Swal.showValidationMessage('Quantity must be at least 1');
                    return false;
                }
                if (!newRate || newRate < 0) {
                    Swal.showValidationMessage('Rate must be positive');
                    return false;
                }
                
                return { qty: newQty, rate: newRate };
            }
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    url: 'updateItem.jsp',
                    method: 'POST',
                    data: { 
                        poDetailId: poDetailId,
                        qty: result.value.qty,
                        rate: result.value.rate
                    },
                    success: function(response) {
                        if (response.trim() === 'success') {
                            Swal.fire('Updated!', 'Item has been updated.', 'success').then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire('Error', response, 'error');
                        }
                    },
                    error: function() {
                        Swal.fire('Error', 'Failed to update item.', 'error');
                    }
                });
            }
        });
    }

    // Delete Item
    function deleteItem(poDetailId, productName) {
        Swal.fire({
            title: 'Delete Item?',
            text: `Remove "${productName}" from this purchase order?`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Yes, Delete',
            cancelButtonText: 'Cancel',
            confirmButtonColor: '#d33'
        }).then((result) => {
            if (result.isConfirmed) {
                $.ajax({
                    url: 'deleteItem.jsp',
                    method: 'POST',
                    data: { poDetailId: poDetailId },
                    success: function(response) {
                        if (response.trim() === 'success') {
                            Swal.fire('Deleted!', 'Item has been removed.', 'success').then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire('Error', response, 'error');
                        }
                    },
                    error: function() {
                        Swal.fire('Error', 'Failed to delete item.', 'error');
                    }
                });
            }
        });
    }
    </script>
</body>
</html>
