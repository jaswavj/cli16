<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="prBean" class="product.purchaseRequestBean" />
<%
    int prId = 0;
    try {
        prId = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        response.sendRedirect(request.getContextPath() + "/product/purchase/request/list.jsp");
        return;
    }
    
    Vector result = prBean.getPurchaseRequestDetails(prId);
    if (result.size() == 0) {
        response.sendRedirect(request.getContextPath() + "/product/purchase/request/list.jsp");
        return;
    }
    
    Vector header = (Vector) result.get(0);
    Vector items = (Vector) result.get(1);
    
    int id = (Integer) header.get(0);
    String reqNo = header.get(1).toString();
    String reqDate = header.get(2).toString();
    int dealId = (Integer) header.get(3);
    String supplierName = header.get(4).toString();
    double total = (Double) header.get(5);
    int prStatus = (Integer) header.get(6);
    String notes = header.get(7).toString();
    String requesterName = header.get(8).toString();
    
    String statusText = "";
    String statusBadge = "";
    switch (prStatus) {
        case 1: statusText = "Draft"; statusBadge = "bg-secondary"; break;
        case 2: statusText = "Submitted"; statusBadge = "bg-info"; break;
        case 3: statusText = "Approved"; statusBadge = "bg-success"; break;
        case 4: statusText = "Rejected"; statusBadge = "bg-danger"; break;
        case 5: statusText = "Converted to PO"; statusBadge = "bg-primary"; break;
        default: statusText = "Unknown"; statusBadge = "bg-dark";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase Request Details - <%= reqNo %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <!-- Navbar -->
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Purchase Request Details</h4>
                <div>
                    <% if (prStatus == 2 || prStatus == 1) { %>
                    <a href="<%=contextPath%>/product/purchase/request/approve.jsp?id=<%= id %>" class="btn btn-success me-2">
                        <i class="fas fa-check-circle me-2"></i>Approve/Reject
                    </a>
                    <% } %>
                    <% if (prStatus == 3) { %>
                    <a href="../order/create.jsp?prId=<%= id %>" class="btn btn-primary me-2">
                        <i class="fas fa-arrow-right me-2"></i>Convert to PO
                    </a>
                    <% } %>
                    <a href="<%=contextPath%>/product/purchase/request/list.jsp" class="btn btn-secondary">
                        <i class="fas fa-arrow-left me-2"></i>Back to List
                    </a>
                </div>
            </div>

            <!-- Request Header -->
            <div class="card mb-3">
                <div class="card-header" style="background: linear-gradient(135deg, #3d1a52, #570a57); color: white;">
                    <h5 class="mb-0">
                        <i class="fas fa-file-alt me-2"></i>Request: <%= reqNo %>
                        <span class="badge <%= statusBadge %> float-end"><%= statusText %></span>
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3">
                            <strong>Request Date:</strong><br>
                            <%= reqDate %>
                        </div>
                        <div class="col-md-3">
                            <strong>Supplier:</strong><br>
                            <%= supplierName %>
                        </div>
                        <div class="col-md-3">
                            <strong>Requested By:</strong><br>
                            <%= requesterName %>
                        </div>
                        <div class="col-md-3">
                            <strong>Total Amount:</strong><br>
                            <span class="fs-5 fw-bold text-primary">₹<%= String.format("%.3f", total) %></span>
                        </div>
                    </div>
                    <% if (!notes.isEmpty()) { %>
                    <div class="row mt-3">
                        <div class="col-md-12">
                            <strong>Notes:</strong><br>
                            <p class="mb-0"><%= notes %></p>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Request Items -->
            <div class="card">
                <div class="card-header">
                    <h6 class="mb-0"><i class="fas fa-list me-2"></i>Requested Items</h6>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th>S.No</th>
                                    <th>Product Name</th>
                                    <th>Pack</th>
                                    <th>Qty/Pack</th>
                                    <th>Quantity</th>
                                    <th>Free</th>
                                    <th>Est. Cost</th>
                                    <th>Est. MRP</th>
                                    <th>Tax%</th>
                                    <th class="text-end">Total</th>
                                    <th class="text-end">Net Amount</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    double grandTotal = 0;
                                    for (int i = 0; i < items.size(); i++) {
                                        Vector item = (Vector) items.get(i);
                                        
                                        int itemId = (Integer) item.get(0);
                                        int prodsId = (Integer) item.get(1);
                                        String productName = item.get(2).toString();
                                        int pack = (Integer) item.get(3);
                                        double qtypack = Double.parseDouble(item.get(4).toString());
                                        double quantity = Double.parseDouble(item.get(5).toString());
                                        int free = (Integer) item.get(6);
                                        double rate = (Double) item.get(7);
                                        double mrp = (Double) item.get(8);
                                        double itemTotal = (Double) item.get(9);
                                        double tax = (Double) item.get(10);
                                        double net = (Double) item.get(11);
                                        
                                        grandTotal += net;
                                %>
                                <tr>
                                    <td><%= i + 1 %></td>
                                    <td><%= productName %></td>
                                    <td><%= pack %></td>
                                    <td><%= qtypack %></td>
                                    <td><%= quantity %></td>
                                    <td><%= free %></td>
                                    <td>₹<%= String.format("%.3f", rate) %></td>
                                    <td>₹<%= String.format("%.3f", mrp) %></td>
                                    <td><%= String.format("%.3f", tax) %>%</td>
                                    <td class="text-end">₹<%= String.format("%.3f", itemTotal) %></td>
                                    <td class="text-end fw-bold">₹<%= String.format("%.3f", net) %></td>
                                </tr>
                                <%
                                    }
                                %>
                                <tr class="table-light">
                                    <td colspan="10" class="text-end fw-bold">Grand Total:</td>
                                    <td class="text-end fw-bold fs-5 text-primary">₹<%= String.format("%.3f", grandTotal) %></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
