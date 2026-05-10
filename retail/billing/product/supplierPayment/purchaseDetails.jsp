<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String purchaseId = request.getParameter("id");
%>
<jsp:useBean id="prod" class="product.productBean" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Purchase Details</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .table-wrapper {
            overflow: auto;
        }
        thead th {
            position: sticky;
            top: 0;
            background-color: #f8f9fa;
            z-index: 1;
            box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.4);
        }
        .form-label-sm {
            font-size: 0.8rem;
            margin-bottom: 0;
            color: #6c757d;
        }
        .form-control-plaintext {
            padding-top: 0;
            padding-bottom: 0;
            font-weight: 500;
        }
    </style>
</head>
<body style="height: 100vh; overflow: hidden;">
    <div class="container-fluid h-100 d-flex flex-column p-0">
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <%
        if (purchaseId != null && !purchaseId.isEmpty()) {
            try {
                // Get purchase header information
                Vector purchaseHeader = prod.getPurchaseHeaderById(Integer.parseInt(purchaseId));
                if (purchaseHeader != null && !purchaseHeader.isEmpty()) {
                    Vector header = (Vector) purchaseHeader.get(0);
        %>

        <!-- Top Section: Purchase Info -->
        <div class="card m-2 flex-shrink-0">
            <div class="card-body p-2">
                <div class="row g-2">
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Invoice No</label>
                            <span class="fw-bold"><%= header.elementAt(1) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Invoice Date</label>
                            <span class="fw-bold"><%= header.elementAt(2) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Supplier</label>
                            <span class="fw-bold"><%= header.elementAt(9) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Entry Date</label>
                            <span class="fw-bold"><%= header.elementAt(6) %> <%= header.elementAt(7) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Entered By</label>
                            <span class="fw-bold"><%= header.elementAt(8) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Total Amount</label>
                            <span class="fw-bold text-primary">₹<%= header.elementAt(3) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Paid Amount</label>
                            <span class="fw-bold text-success">₹<%= header.elementAt(4) %></span>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="border rounded p-1 bg-light">
                            <label class="form-label-sm d-block">Balance</label>
                            <span class="fw-bold text-danger">₹<%= header.elementAt(5) %></span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Middle Section: Table -->
        <div class="flex-grow-1 overflow-auto px-2">
            <table class="table table-bordered table-sm table-hover mb-0">
                <thead class="table-light">
                    <tr>
                        <th style="width: 50px;">S.No</th>
                        <th>Product Name</th>
                        <th class="text-end" style="width: 80px;">Pack</th>
                        <th class="text-end" style="width: 80px;">Qty/Pk</th>
                        <th class="text-end" style="width: 80px;">Qty</th>
                        <th class="text-end" style="width: 80px;">Free</th>
                        <th class="text-end" style="width: 100px;">Rate</th>
                        <th class="text-end" style="width: 100px;">MRP</th>
                        <th class="text-end" style="width: 120px;">Total</th>
                        <th class="text-end" style="width: 80px;">GST%</th>
                        <th class="text-end" style="width: 100px;">CGST</th>
                        <th class="text-end" style="width: 100px;">SGST</th>
                        <th class="text-end" style="width: 100px;">IGST</th>
                        <th class="text-end" style="width: 120px;">Net Amt</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    // Get purchase details
                    Vector purchaseDetails = prod.getPurchaseDetailsById(Integer.parseInt(purchaseId));
                    double totalAmount = 0.0, totalCGST = 0.0, totalSGST = 0.0, totalIGST = 0.0, grandTotal = 0.0;
                    
                    if (purchaseDetails != null && !purchaseDetails.isEmpty()) {
                        for (int i = 0; i < purchaseDetails.size(); i++) {
                            Vector item = (Vector) purchaseDetails.get(i);
                            double itemTotal = Double.parseDouble((String) item.elementAt(9));
                            double cgst = Double.parseDouble((String) item.elementAt(13));
                            double sgst = Double.parseDouble((String) item.elementAt(14));
                            double igst = Double.parseDouble((String) item.elementAt(15));
                            double netAmt = Double.parseDouble((String) item.elementAt(16));

                            totalAmount += itemTotal;
                            totalCGST += cgst;
                            totalSGST += sgst;
                            totalIGST += igst;
                            grandTotal += netAmt;
                    %>
                    <tr>
                        <td><%= i+1 %></td>
                        <td><%= item.elementAt(1) %></td>
                        <td class="text-end"><%= item.elementAt(2) %></td>
                        <td class="text-end"><%= item.elementAt(3) %></td>
                        <td class="text-end"><%= item.elementAt(4) %></td>
                        <td class="text-end"><%= item.elementAt(5) %></td>
                        <td class="text-end"><%= item.elementAt(6) %></td>
                        <td class="text-end"><%= item.elementAt(7) %></td>
                        <td class="text-end"><%= String.format("%.3f", itemTotal) %></td>
                        <td class="text-end"><%= item.elementAt(10) %></td>
                        <td class="text-end"><%= String.format("%.3f", cgst) %></td>
                        <td class="text-end"><%= String.format("%.3f", sgst) %></td>
                        <td class="text-end"><%= String.format("%.3f", igst) %></td>
                        <td class="text-end fw-bold"><%= String.format("%.3f", netAmt) %></td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="14" class="text-center py-3">No items found for this purchase.</td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Bottom Section: Footer Totals -->
        <div class="card m-2 flex-shrink-0 bg-light">
            <div class="card-body p-2">
                <div class="row align-items-center">
                    <div class="col-auto">
                        <a href="page.jsp" class="btn btn-secondary btn-sm px-4">
                            <i class="fas fa-arrow-left me-1"></i> Back
                        </a>
                    </div>
                    <div class="col text-end">
                        <span class="me-3 text-muted">Sub Total: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalAmount) %></span></span>
                        <span class="me-3 text-muted">CGST: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalCGST) %></span></span>
                        <span class="me-3 text-muted">SGST: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalSGST) %></span></span>
                        <span class="me-3 text-muted">IGST: <span class="text-dark fw-bold">₹<%= String.format("%.3f", totalIGST) %></span></span>
                        <span class="ms-2 fs-5">Grand Total: <span class="text-primary fw-bold">₹<%= String.format("%.3f", grandTotal) %></span></span>
                    </div>
                </div>
            </div>
        </div>

        <%
                } else {
        %>
        <div class="container mt-5">
            <div class="alert alert-warning shadow-sm">
                <i class="fas fa-exclamation-triangle me-2"></i> Purchase not found.
                <a href="page.jsp" class="alert-link ms-2">Go Back</a>
            </div>
        </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <div class="container mt-5">
            <div class="alert alert-danger shadow-sm">
                <h5 class="alert-heading"><i class="fas fa-exclamation-circle me-2"></i>Error loading details</h5>
                <p class="mb-0"><%= e.getMessage() %></p>
                <hr>
                <p class="mb-0 small">Purchase ID: <%= purchaseId %></p>
                <a href="page.jsp" class="btn btn-outline-danger btn-sm mt-2">Go Back</a>
            </div>
        </div>
        <%
            }
        } else {
        %>
        <div class="container mt-5">
            <div class="alert alert-warning shadow-sm">
                <i class="fas fa-exclamation-triangle me-2"></i> Invalid purchase ID.
                <a href="page.jsp" class="alert-link ms-2">Go Back</a>
            </div>
        </div>
        <%
        }
        %>
    </div>
</body>
</html>