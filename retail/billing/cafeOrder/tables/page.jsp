<%@ page import="java.sql.*" %>
<%@ include file="../../assets/common/head.jsp" %>
<jsp:include page="/assets/navbar/navbar.jsp" />
<div class="container-fluid">
    <div class="row">
        <div class="col-md-12">
            <h2>Table Management</h2>
            <button class="btn btn-primary mb-3" onclick="showAddModal()">
                <i class="fas fa-plus"></i> Add New Table
            </button>
            
            <div class="row" id="tableList">
                <!-- Tables will be loaded here -->
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Table Modal -->
<div class="modal fade" id="tableModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Add Table</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="tableForm">
                <div class="modal-body">
                    <input type="hidden" id="tableId" name="id">
                    <div class="form-group">
                        <label>Table Name:</label>
                        <input type="text" class="form-control" id="tableName" name="name" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Order Modal -->
<div class="modal fade" id="orderModal" tabindex="-1">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Order for: <span id="orderTableName"></span></h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <input type="hidden" id="orderTableId">
                <div class="row">
                    <div class="col-md-6">
                        <h6>Products</h6>
                        <input type="text" class="form-control mb-2" id="productSearch" placeholder="Search products...">
                        <div id="productList" style="max-height: 400px; overflow-y: auto;">
                            <!-- Products will be loaded here -->
                        </div>
                    </div>
                    <div class="col-md-6">
                        <h6>Order Items</h6>
                        <table class="table table-bordered">
                            <thead class="thead-light">
                                <tr>
                                    <th>PRODUCT</th>
                                    <th>PRICE</th>
                                    <th>QTY</th>
                                    <th>TOTAL</th>
                                    <th>ACTION</th>
                                </tr>
                            </thead>
                            <tbody id="orderItems">
                                <!-- Order items will be added here -->
                            </tbody>
                            <tfoot>
                                <tr class="table-success">
                                    <th colspan="3">Total Amount</th>
                                    <th colspan="2" id="totalAmount">0.00</th>
                                </tr>
                            </tfoot>
                        </table>
                        <button class="btn btn-success btn-block btn-lg" onclick="saveOrder()">
                            <i class="fas fa-check"></i> Place Order
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
let orderItems = [];

$(document).ready(function() {
    loadTables();
});

function loadTables() {
    $.ajax({
        url: 'getTables.jsp',
        success: function(data) {
            $('#tableList').html(data);
        }
    });
}

function showAddModal() {
    $('#modalTitle').text('Add Table');
    $('#tableForm')[0].reset();
    $('#tableId').val('');
    
    // Bootstrap 5 compatible modal initialization
    const modalElement = document.getElementById('tableModal');
    const modal = new bootstrap.Modal(modalElement);
    modal.show();
}

function editTable(id, name) {
    $('#modalTitle').text('Edit Table');
    $('#tableId').val(id);
    $('#tableName').val(name);
    $('#tableModal').modal('show');
}

function deleteTable(id) {
    if(confirm('Are you sure you want to delete this table?')) {
        $.post('delete.jsp', {id: id}, function(response) {
            if(response.trim() === 'success') {
                alert('Table deleted successfully');
                loadTables();
            } else {
                alert('Error deleting table');
            }
        });
    }
}

function createOrder(tableId, tableName) {
    console.log('createOrder called with:', tableId, tableName);
    console.log('jQuery loaded:', typeof $ !== 'undefined');
    console.log('Modal element exists:', $('#orderModal').length > 0);
    
    $('#orderTableId').val(tableId);
    $('#orderTableName').text(tableName);
    orderItems = [];
    renderOrderItems();
    loadProducts();
    
    // Use jQuery method which works with Bootstrap 5
    try {
        $('#orderModal').modal({
            backdrop: 'static',
            keyboard: false
        });
        $('#orderModal').modal('show');
        console.log('Modal show called');
    } catch(error) {
        console.error('Modal error:', error);
        alert('Error opening modal: ' + error.message);
    }
}

function loadProducts() {
    $.ajax({
        url: '../order/getProducts.jsp',
        success: function(data) {
            $('#productList').html(data);
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
    
    $('#orderItems').html(html || '<tr><td colspan="5" class="text-center text-muted">No items added</td></tr>');
    $('#totalAmount').text(total.toFixed(2));
}

function saveOrder() {
    if(orderItems.length === 0) {
        alert('Please add items to the order');
        return;
    }
    
    let tableId = $('#orderTableId').val();
    let orderData = {
        tableId: tableId,
        items: JSON.stringify(orderItems)
    };
    
    $.post('../order/saveOrder.jsp', orderData, function(response) {
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
                loadTables();
            });
        } else {
            alert('Error placing order: ' + response);
        }
    });
}

$('#tableForm').submit(function(e) {
    e.preventDefault();
    $.post('save.jsp', $(this).serialize(), function(response) {
        if(response.trim() === 'success') {
            alert('Table saved successfully');
            $('#tableModal').modal('hide');
            loadTables();
        } else {
            alert('Error saving table');
        }
    });
});
</script>
