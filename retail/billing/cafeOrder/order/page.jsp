<%@ page import="java.sql.*" %>
<%@ include file="../../assets/common/head.jsp" %>
<jsp:include page="/assets/navbar/navbar.jsp" />
<div class="container-fluid">
    <div class="row">
        <div class="col-md-12">
            <h2>Create Order</h2>
            
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h5><i class="fas fa-chair"></i> Select Table</h5>
                </div>
                <div class="card-body">
                    <div class="row" id="tableSelection">
                        <!-- Tables will be loaded here -->
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Order Modal -->
<div class="modal fade" id="orderModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-success text-white">
                <h5 class="modal-title"><i class="fas fa-utensils"></i> Order for: <span id="selectedTableName"></span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="selectedTableId">
                <input type="hidden" id="currentOrderId">
                <input type="hidden" id="isTableOccupied">
                <div class="row">
                    <div class="col-md-6">
                        <h6>Products</h6>
                        <div class="mb-3">
                            <label class="form-label">Filter by Category</label>
                            <div id="categoryList" class="d-flex flex-wrap gap-2 mb-3">
                                <!-- Categories will be loaded here -->
                            </div>
                        </div>
                        <input type="text" class="form-control mb-3" id="productSearch" placeholder="Search products...">
                        <div id="productList" style="max-height: 400px; overflow-y: auto;">
                            <!-- Products will be loaded here -->
                        </div>
                    </div>
                    <div class="col-md-6">
                        <h6>Order Items</h6>
                        <div class="table-responsive">
                            <table class="table table-bordered table-sm">
                                <thead class="table-dark">
                                    <tr>
                                        <th>PRODUCT</th>
                                        <th>PRICE</th>
                                        <th>QTY</th>
                                        <th>TOTAL</th>
                                        <th>ACTION</th>
                                    </tr>
                                </thead>
                                <tbody id="orderItems">
                                    <tr>
                                        <td colspan="5" class="text-center text-muted">No items added</td>
                                    </tr>
                                </tbody>
                                <tfoot>
                                    <tr class="table-success">
                                        <th colspan="3">Total Amount</th>
                                        <th colspan="2" id="totalAmount">0.00</th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        <div class="mt-3">
                            <button class="btn btn-success btn-lg w-100" onclick="saveOrder()">
                                <i class="fas fa-check"></i> Place Order
                            </button>
                            <button class="btn btn-danger btn-lg w-100 mt-2" id="cancelOrderBtn" style="display:none;" onclick="cancelOrder()">
                                <i class="fas fa-times"></i> Cancel Order
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
let orderItems = [];

$(document).ready(function() {
    loadAvailableTables();
});

function loadAvailableTables() {
    $.ajax({
        url: 'getAvailableTables.jsp',
        success: function(data) {
            $('#tableSelection').html(data);
        }
    });
}

let selectedCategoryId = null;

function selectTable(id, name) {
    console.log('Opening order for table:', id, name);
    $('#selectedTableId').val(id);
    $('#selectedTableName').text(name);
    $('#currentOrderId').val('');
    $('#isTableOccupied').val('0');
    $('#cancelOrderBtn').hide();
    orderItems = [];
    renderOrderItems();
    loadCategories();
    loadProducts();
    $('#orderModal').modal('show');
}

function viewOccupiedTableOrder(tableId, tableName) {
    console.log('Loading existing order for table:', tableId, tableName);
    $('#selectedTableId').val(tableId);
    $('#selectedTableName').text(tableName);
    $('#isTableOccupied').val('1');
    
    // Load existing order items
    $.ajax({
        url: 'getTableOrder.jsp',
        data: { tableId: tableId },
        dataType: 'json',
        success: function(data) {
            if(data.error) {
                alert('Error loading order: ' + data.error);
                return;
            }
            
            $('#currentOrderId').val(data.orderId || '');
            orderItems = data.items || [];
            
            // Show cancel button if order exists
            if(data.orderId) {
                $('#cancelOrderBtn').show();
            } else {
                $('#cancelOrderBtn').hide();
            }
            
            renderOrderItems();
            loadCategories();
            loadProducts();
            $('#orderModal').modal('show');
        },
        error: function() {
            alert('Error loading table order');
        }
    });
}

function loadCategories() {
    $.ajax({
        url: 'getCategories.jsp',
        success: function(data) {
            let html = '<button class="btn btn-sm btn-outline-primary category-btn' + (selectedCategoryId === null ? ' active' : '') + '" onclick="selectCategory(null)">All</button>';
            html += data;
            $('#categoryList').html(html);
        },
        error: function() {
            $('#categoryList').html('<span class="text-danger">Error loading categories</span>');
        }
    });
}

function selectCategory(categoryId) {
    selectedCategoryId = categoryId;
    // Update active state on buttons
    $('.category-btn').removeClass('active');
    event.target.classList.add('active');
    loadProducts(categoryId);
}

function loadProducts(categoryId) {
    let url = 'getProducts.jsp';
    if(categoryId !== null && categoryId !== undefined) {
        url += '?category_id=' + categoryId;
    }
    $.ajax({
        url: url,
        success: function(data) {
            $('#productList').html(data);
        },
        error: function() {
            $('#productList').html('<div class="alert alert-danger">Error loading products</div>');
        }
    });
}

$('#productSearch').on('keyup', function() {
    var value = $(this).val().toLowerCase();
    $('#productList .product-item').filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
    });
});

function addToOrder(prodId, prodName, price, code) {
    let existingItem = orderItems.find(item => item.prodId == prodId);
    
    if(existingItem) {
        existingItem.qty++;
        existingItem.total = existingItem.qty * existingItem.price;
    } else {
        orderItems.push({
            prodId: prodId,
            prodName: prodName,
            code: code || '',
            price: parseFloat(price),
            qty: 1,
            total: parseFloat(price)
        });
    }
    
    renderOrderItems();
}

function updateQty(prodId, change) {
    let item = orderItems.find(item => item.prodId == prodId);
    if(item) {
        item.qty += change;
        if(item.qty <= 0) {
            removeItem(prodId);
        } else {
            item.total = item.qty * item.price;
            renderOrderItems();
        }
    }
}

function removeItem(prodId) {
    orderItems = orderItems.filter(item => item.prodId != prodId);
    renderOrderItems();
}

function renderOrderItems() {
    let html = '';
    let total = 0;
    
    if(orderItems.length === 0) {
        html = '<tr><td colspan="5" class="text-center text-muted">No items added</td></tr>';
    } else {
        orderItems.forEach(item => {
            total += item.total;
            html += `
                <tr>
                    <td>${item.prodName}</td>
                    <td>${item.price.toFixed(2)}</td>
                    <td>
                        <div class="btn-group btn-group-sm">
                            <button class="btn btn-secondary" onclick="updateQty(${item.prodId}, -1)">-</button>
                            <span class="btn btn-light">${item.qty}</span>
                            <button class="btn btn-secondary" onclick="updateQty(${item.prodId}, 1)">+</button>
                        </div>
                    </td>
                    <td>${item.total.toFixed(2)}</td>
                    <td>
                        <button class="btn btn-sm btn-danger" onclick="removeItem(${item.prodId})">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
            `;
        });
    }
    
    $('#orderItems').html(html);
    $('#totalAmount').text(total.toFixed(2));
}

function saveOrder() {
    if(orderItems.length === 0) {
        alert('Please add items to the order');
        return;
    }
    
    let tableId = $('#selectedTableId').val();
    let orderData = {
        tableId: tableId,
        items: JSON.stringify(orderItems)
    };
    
    $.post('saveOrder.jsp', orderData, function(response) {
        if(response.trim() === 'success') {
            Swal.fire({
                icon: 'success',
                title: 'Order Placed!',
                text: 'Order has been placed successfully',
                confirmButtonText: 'OK'
            }).then(() => {
                $('#orderModal').modal('hide');
                orderItems = [];
                renderOrderItems();
                loadAvailableTables();
            });
        } else {
            alert('Error placing order: ' + response);
        }
    });
}

function cancelOrder() {
    let orderId = $('#currentOrderId').val();
    let tableId = $('#selectedTableId').val();
    
    if(!orderId) {
        alert('No order to cancel');
        return;
    }
    
    if(!confirm('Are you sure you want to cancel this order?')) {
        return;
    }
    
    $.post('cancelOrder.jsp', { orderId: orderId, tableId: tableId }, function(response) {
        if(response.trim() === 'success') {
            Swal.fire({
                icon: 'success',
                title: 'Order Cancelled!',
                text: 'Order has been cancelled successfully',
                confirmButtonText: 'OK'
            }).then(() => {
                $('#orderModal').modal('hide');
                orderItems = [];
                renderOrderItems();
                loadAvailableTables();
            });
        } else {
            alert('Error cancelling order: ' + response);
        }
    });
}
</script>

<style>
.product-item {
    padding: 10px;
    border: 1px solid #ddd;
    margin-bottom: 5px;
    cursor: pointer;
    border-radius: 5px;
    transition: all 0.2s;
}
.product-item:hover {
    background-color: #e8f5e9;
    border-color: #4caf50;
    transform: translateX(5px);
}
.category-btn {
    margin-right: 5px;
    margin-bottom: 5px;
}
.category-btn.active {
    background-color: #0d6efd !important;
    color: white !important;
}
</style>
