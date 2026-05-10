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
    String reqNo = header.get(1).toString();
    int prStatus = (Integer) header.get(6);
    
    // Check if already processed
    if (prStatus != 1 && prStatus != 2) {
        response.sendRedirect(request.getContextPath() + "/product/purchase/request/details.jsp?id=" + prId);
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Approve/Reject Purchase Request - <%= reqNo %></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <div class="container-fluid h-100 d-flex flex-column">
        <!-- Navbar -->
        <%@ include file="/assets/navbar/navbar.jsp" %>

        <div class="container mt-4">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header" style="background: linear-gradient(135deg, #3d1a52, #570a57); color: white;">
                            <h5 class="mb-0">
                                <i class="fas fa-check-circle me-2"></i>Approve/Reject Purchase Request
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Request No:</strong> <%= reqNo %>
                            </div>

                            <form id="approvalForm">
                                <input type="hidden" name="prId" id="prId" value="<%= prId %>">
                                
                                <div class="mb-3">
                                    <label class="form-label"><strong>Action:</strong></label>
                                    <div class="btn-group w-100" role="group">
                                        <input type="radio" class="btn-check" name="action" id="approve" value="3" checked>
                                        <label class="btn btn-outline-success" for="approve">
                                            <i class="fas fa-check-circle me-2"></i>Approve
                                        </label>
                                        
                                        <input type="radio" class="btn-check" name="action" id="reject" value="4">
                                        <label class="btn btn-outline-danger" for="reject">
                                            <i class="fas fa-times-circle me-2"></i>Reject
                                        </label>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="notes" class="form-label"><strong>Comments:</strong></label>
                                    <textarea class="form-control" id="notes" name="notes" rows="4" 
                                              placeholder="Enter approval/rejection comments here..."></textarea>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <a href="<%=contextPath%>/product/purchase/request/details.jsp?id=<%= prId %>" class="btn btn-secondary">
                                        <i class="fas fa-arrow-left me-2"></i>Cancel
                                    </a>
                                    <button type="button" class="btn btn-primary" id="submitBtn" onclick="submitApproval()">
                                        <i class="fas fa-save me-2"></i>Submit
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function submitApproval() {
            var btn = $('#submitBtn');
            var prId = $('#prId').val();
            var action = $('input[name="action"]:checked').val();
            var notes = $('#notes').val().trim();
            
            if (notes === '') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please enter comments for your decision.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                });
                $('#notes').focus();
                return false;
            }
            
            btn.prop('disabled', true);
            
            var param = 'prId=' + prId + '&action=' + action + '&notes=' + encodeURIComponent(notes);
            
            $.ajax({
                type: "POST",
                url: "processApproval.jsp",
                data: param,
                success: function (_result) {
                    var result = _result.trim();
                    if (result === 'success') {
                        var actionText = action === '3' ? 'approved' : 'rejected';
                        Swal.fire({
                            title: 'Success!',
                            text: 'Purchase request has been ' + actionText + ' successfully.',
                            icon: 'success',
                            confirmButtonText: 'OK'
                        }).then(() => {
                            window.location.href = '<%=contextPath%>/product/purchase/request/list.jsp';
                        });
                    } else {
                        Swal.fire({
                            title: 'Error',
                            text: result,
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                        btn.prop('disabled', false);
                    }
                },
                error: function () {
                    Swal.fire({
                        title: 'Error',
                        text: 'Failed to process approval. Please try again.',
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    btn.prop('disabled', false);
                }
            });
        }
    </script>
</body>
</html>
