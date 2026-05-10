<%@ page import="java.sql.*" %>
<%@ include file="../../assets/common/head.jsp" %>
<jsp:include page="/assets/navbar/navbar.jsp" />

<div class="container-fluid">
    <div class="row">
        <div class="col-md-12">
            <h2>Pending Orders</h2>
            
            <div id="pendingOrders"></div>
        </div>
    </div>
</div>

<!-- Order Details Modal -->
<div class="modal fade" id="orderDetailsModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Order Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="orderDetailsContent">
                <!-- Order details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    loadOrders('pending');
    
    // Auto refresh every 30 seconds
    setInterval(function() {
        loadOrders('pending');
    }, 30000);
});

function loadOrders(type) {
    $.ajax({
        url: 'getOrders.jsp',
        data: {type: type},
        success: function(data) {
            $('#pendingOrders').html(data);
        }
    });
}

function viewOrderDetails(orderId) {
    $.ajax({
        url: 'getOrderDetails.jsp',
        data: {orderId: orderId},
        success: function(data) {
            $('#orderDetailsContent').html(data);
            var modal = new bootstrap.Modal(document.getElementById('orderDetailsModal'));
            modal.show();
        }
    });
}

function markOrderDelivered(orderId) {
    if(confirm('Mark all items in this order as delivered?')) {
        $.post('markOrderDelivered.jsp', {orderId: orderId}, function(response) {
            if(response.trim() === 'success') {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Order marked as delivered',
                    timer: 1500,
                    showConfirmButton: false
                });
                loadOrders('pending');
            } else {
                alert('Error updating order: ' + response);
            }
        });
    }
}
</script>
