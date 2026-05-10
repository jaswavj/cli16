<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="prBean" class="product.purchaseRequestBean" />
<%
    // Show only pending approval requests
    Vector prList = prBean.getPurchaseRequests(1); // 1 = Pending Approval
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Purchase Requests - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <!-- Navbar -->
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="mb-0">Purchase Requests - Waiting for Approval</h4>
                <a href="<%=contextPath%>/product/purchase/request/create.jsp" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i>New Request
                </a>
            </div>

            <!-- Request List Table -->
            <div class="alert alert-info mb-3">
                <i class="fas fa-info-circle me-2"></i>
                Showing <%= prList.size() %> request(s) waiting for approval
            </div>
            <div class="table-responsive">
                <table class="table table-hover table-bordered">
                    <thead class="table-light">
                        <tr>
                            <th>S.No</th>
                            <th>Request No</th>
                            <th>Date</th>
                            <th>Supplier</th>
                            <th>Requester</th>
                            <th>Amount</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (prList.size() == 0) {
                        %>
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">
                                <i class="fas fa-inbox fa-3x mb-2"></i>
                                <p>No purchase requests found</p>
                            </td>
                        </tr>
                        <%
                            } else {
                                for (int i = 0; i < prList.size(); i++) {
                                    Vector row = (Vector) prList.get(i);
                                    
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
                            <td>
                                <a href="<%=contextPath%>/product/purchase/request/details.jsp?id=<%= id %>" class="btn btn-sm btn-info" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <a href="<%=contextPath%>/product/purchase/request/approve.jsp?id=<%= id %>" class="btn btn-sm btn-success" title="Approve/Reject">
                                    <i class="fas fa-check-circle"></i> Approve
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
