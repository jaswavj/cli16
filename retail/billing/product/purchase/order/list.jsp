<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="poBean" class="product.purchaseOrderBean" />
<%
    // Show created purchase orders only
    Vector dataList = poBean.getPurchaseOrders(1); // 1 = all active POs
    String filterLabel = "Created Purchase Orders";
    boolean showRequests = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase Orders - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .progress {
            height: 20px;
        }
    </style>
    <script>
        function sendPOToSupplier(poId) {
            Swal.fire({
                title: 'Send PO to Supplier?',
                text: 'This will send the purchase order to the supplier.',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Send',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Show loading
                    Swal.fire({
                        title: 'Sending...',
                        text: 'Please wait',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    
                    // Send via AJAX
                    $.ajax({
                        type: 'POST',
                        url: 'send.jsp',
                        data: { id: poId },
                        success: function(response) {
                            Swal.fire({
                                title: 'Success!',
                                text: 'Purchase order sent to supplier successfully.',
                                icon: 'success',
                                confirmButtonText: 'OK'
                            }).then(() => {
                                // Reload the page to refresh the list
                                window.location.reload();
                            });
                        },
                        error: function(xhr, status, error) {
                            Swal.fire({
                                title: 'Error',
                                text: 'Failed to send purchase order: ' + error,
                                icon: 'error',
                                confirmButtonText: 'OK'
                            });
                        }
                    });
                }
            });
        }
    </script>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Purchase Orders</h4>
                <a href="<%=contextPath%>/product/purchase/order/create.jsp" class="btn btn-success">
                    <i class="fas fa-plus me-2"></i>New PO (Standalone)
                </a>
            </div>

            <!-- Data List Table -->
            <div class="alert alert-info mb-3">
                <i class="fas fa-info-circle me-2"></i>
                Showing <%= dataList.size() %> <%= filterLabel.toLowerCase() %>
            </div>
            <div class="table-responsive">
                <% if (showRequests) { %>
                <!-- Approved Requests Table -->
                <table class="table table-hover table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>S.No</th>
                            <th>Request No</th>
                            <th>Date</th>
                            <th>Supplier</th>
                            <th>Requester</th>
                            <th>Amount</th>
                            <th>Approver</th>
                            <th>Approved Date</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (dataList.size() == 0) {
                        %>
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">
                                <i class="fas fa-inbox fa-3x mb-2"></i>
                                <p>No approved purchase requests found</p>
                            </td>
                        </tr>
                        <%
                            } else {
                                for (int i = 0; i < dataList.size(); i++) {
                                    Vector row = (Vector) dataList.get(i);
                                    
                                    int id = (Integer) row.get(0);
                                    String reqNo = row.get(1).toString();
                                    String reqDate = row.get(2).toString();
                                    String reqTime = row.get(3).toString();
                                    double total = (Double) row.get(4);
                                    int prStatus = (Integer) row.get(5);
                                    String notes = row.get(6).toString();
                                    String supplierName = row.get(7).toString();
                                    String requesterName = row.get(8).toString();
                                    String approverName = row.get(9).toString();
                                    String approvedDate = row.get(10).toString();
                        %>
                        <tr>
                            <td><%= i + 1 %></td>
                            <td><strong><%= reqNo %></strong></td>
                            <td><%= reqDate %></td>
                            <td><%= supplierName %></td>
                            <td><%= requesterName %></td>
                            <td class="text-end">₹<%= String.format("%.3f", total) %></td>
                            <td><%= approverName.isEmpty() ? "-" : approverName %></td>
                            <td><%= approvedDate.isEmpty() ? "-" : approvedDate %></td>
                            <td>
                                <a href="../request/details.jsp?id=<%= id %>" class="btn btn-sm btn-info" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="<%=contextPath%>/product/purchase/order/create.jsp?prId=<%= id %>" class="btn btn-sm btn-primary" title="Convert to PO">
                                    <i class="fas fa-arrow-right"></i> Create PO
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
                <% } else { %>
                <!-- Purchase Orders Table -->
                <table class="table table-hover table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>S.No</th>
                            <th>PO Number</th>
                            <th>Date</th>
                            <th>Expected Date</th>
                            <th>Supplier</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Completion</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (dataList.size() == 0) {
                        %>
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">
                                <i class="fas fa-inbox fa-3x mb-2"></i>
                                <p>No purchase orders found</p>
                            </td>
                        </tr>
                        <%
                            } else {
                                for (int i = 0; i < dataList.size(); i++) {
                                    Vector row = (Vector) dataList.get(i);
                                    
                                    int id = (Integer) row.get(0);
                                    String poNo = row.get(1).toString();
                                    String poDate = row.get(2).toString();
                                    String expectedDate = row.get(3).toString();
                                    double total = (Double) row.get(4);
                                    int poStatus = (Integer) row.get(5);
                                    String poNotes = row.get(6).toString();
                                    String supplierName = row.get(7).toString();
                                    String userName = row.get(8).toString();
                                    int totalOrdered = (Integer) row.get(9);
                                    int totalReceived = (Integer) row.get(10);
                                    int totalPending = (Integer) row.get(11);
                                    double completionPercent = (Double) row.get(12);
                                    
                                    String statusText = "";
                                    String statusBadge = "";
                                    switch (poStatus) {
                                        case 1: statusText = "Draft"; statusBadge = "bg-secondary"; break;
                                        case 2: statusText = "Sent"; statusBadge = "bg-info"; break;
                                        case 3: statusText = "Partial"; statusBadge = "bg-warning"; break;
                                        case 4: statusText = "Completed"; statusBadge = "bg-success"; break;
                                        default: statusText = "Unknown"; statusBadge = "bg-dark";
                                    }
                        %>
                        <tr>
                            <td><%= i + 1 %></td>
                            <td><strong><%= poNo %></strong></td>
                            <td><%= poDate %></td>
                            <td><%= expectedDate != null ? expectedDate : "-" %></td>
                            <td><%= supplierName %></td>
                            <td class="text-end">₹<%= String.format("%.3f", total) %></td>
                            <td><span class="badge <%= statusBadge %>"><%= statusText %></span></td>
                            <td>
                                <div class="progress">
                                    <div class="progress-bar <%= completionPercent >= 100 ? "bg-success" : "bg-primary" %>" 
                                         role="progressbar" 
                                         style="width: <%= completionPercent %>%">
                                        <%= String.format("%.0f", completionPercent) %>%
                                    </div>
                                </div>
                                <small class="text-muted">
                                    <%= totalReceived %>/<%= totalOrdered %> items
                                </small>
                            </td>
                            <td>
                                <a href="<%=contextPath%>/product/purchase/order/details.jsp?id=<%= id %>" class="btn btn-sm btn-info" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <% if (poStatus == 1) { %>
                                <button type="button" class="btn btn-sm btn-success" title="Send to Supplier" 
                                   onclick="sendPOToSupplier(<%= id %>)">
                                    <i class="fas fa-paper-plane"></i> Send
                                </button>
                                <% } %>
                                <% if (poStatus == 2 || poStatus == 3) { %>
                                <a href="../../purchase/page.jsp?poId=<%= id %>" class="btn btn-sm btn-primary" title="Receive Goods">
                                    <i class="fas fa-truck"></i> Receive
                                </a>
                                <% } %>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
