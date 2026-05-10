<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, javax.servlet.http.*" %>
<jsp:useBean id="prBean" class="product.purchaseRequestBean" />
<%
    // Check if creating from PR
    int prId = 0;
    String mode = "standalone";
    Vector prHeader = null;
    Vector prItems = null;
    
    String prIdParam = request.getParameter("prId");
    if (prIdParam != null && !prIdParam.isEmpty()) {
        try {
            prId = Integer.parseInt(prIdParam);
            mode = "from-pr";
            
            // Load PR details
            Vector result = prBean.getPurchaseRequestDetails(prId);
            if (result.size() > 0) {
                prHeader = (Vector) result.get(0);
                prItems = (Vector) result.get(1);
            } else {
                prId = 0;
                mode = "standalone";
            }
        } catch (Exception e) {
            prId = 0;
            mode = "standalone";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Purchase Order - Billing App</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<style>
    .table-wrapper {
        overflow-x: auto;
        overflow-y: auto;
    }
    
    .table-fixed-layout {
        min-width: 1400px;
        table-layout: fixed;
        width: 100%;
    }

    .table-fixed-layout th:nth-child(1), .table-fixed-layout td:nth-child(1) { width: 50px; }
    .table-fixed-layout th:nth-child(2), .table-fixed-layout td:nth-child(2) { width: 50px; }
    .table-fixed-layout th:nth-child(3), .table-fixed-layout td:nth-child(3) { width: 240px; }
    .table-fixed-layout th:nth-child(4), .table-fixed-layout td:nth-child(4) { width: 60px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .table-fixed-layout th:nth-child(5), .table-fixed-layout td:nth-child(5) { width: 60px; }
    .table-fixed-layout th:nth-child(6), .table-fixed-layout td:nth-child(6) { width: 60px; }
    .table-fixed-layout th:nth-child(7), .table-fixed-layout td:nth-child(7) { width: 60px; }
    .table-fixed-layout th:nth-child(8), .table-fixed-layout td:nth-child(8) { width: 60px; }
    .table-fixed-layout th:nth-child(9), .table-fixed-layout td:nth-child(9) { width: 80px; }
    .table-fixed-layout th:nth-child(10), .table-fixed-layout td:nth-child(10) { width: 80px; }
    .table-fixed-layout th:nth-child(11), .table-fixed-layout td:nth-child(11) { width: 60px; }
    .table-fixed-layout th:nth-child(12), .table-fixed-layout td:nth-child(12) { width: 60px; }
    .table-fixed-layout th:nth-child(13), .table-fixed-layout td:nth-child(13) { width: 90px; }
    .table-fixed-layout th:nth-child(14), .table-fixed-layout td:nth-child(14) { width: 90px; }
    .table-fixed-layout th:nth-child(15), .table-fixed-layout td:nth-child(15) { width: 90px; }
    .table-fixed-layout th:nth-child(16), .table-fixed-layout td:nth-child(16) { width: 100px; }
    .table-fixed-layout th:nth-child(17), .table-fixed-layout td:nth-child(17) { width: 90px; }
</style>
<body style="height: 100vh; overflow: hidden;" onload="Load();initializePO();">

    <div class="container-fluid h-100 d-flex flex-column">
        <%@ include file="/assets/navbar/navbar.jsp" %>
        
        <input type="hidden" id="_proAddRowCount" name="_proAddRowCount" value="0">
        <input type="hidden" id="_proDelRowCount" name="_proDelRowCount" value="0">
        <input type="hidden" id="prId" name="prId" value="<%= prId %>">
        <input type="hidden" id="mode" name="mode" value="<%= mode %>">

        <!-- PO Header -->
        <div class="card flex-shrink-0 my-1">
            <div class="card-body">
                <% if (mode.equals("from-pr")) { %>
                <div class="alert alert-info mb-2 py-1">
                    <i class="fas fa-info-circle me-2"></i>
                    <strong>Creating PO from Request:</strong> <%= prHeader.get(1).toString() %>
                </div>
                <% } %>
                <div class="row g-1">
                    <div class="col-md-3">
                        <div class="input-outline">
                            <select class="form-select" name="supplier" id="supplier" 
                                <%= mode.equals("from-pr") ? "disabled" : "" %> onchange="checkSupplierCheques();setPaymentTypeBasedOnGst();">
                                <option value="0">Select Supplier</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="input-outline">
                            <input type="date" class="form-control" id="expectedDate" name="expectedDate">
                            <label>Expected Delivery Date</label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="input-outline">
                            <textarea class="form-control" id="poNotes" name="poNotes" rows="1" 
                                placeholder="PO notes or special instructions"></textarea>
                            
                        </div>
                    </div>
                    <div class="col-md-1">
                        <button type="button" class="btn btn-info w-100" onclick="checkAvailableCheques()" title="View Available Cheques">
                            <i class="fas fa-money-check me-1"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product Table -->
        <div class="m-0 flex-grow-1 table-wrapper">
            <table class="table table-bordered table-sm mb-0 table-fixed-layout">
                <thead>
                    <tr>
                        <th>Add</th>
                        <th>Del</th>
                        <th>Item Name</th>
                        <th>History</th>
                        <th>Pack</th>
                        <th>Qty/Pk</th>
                        <th>Total</th>
                        <th>Free</th>
                        <th>Cost</th>
                        <th>MRP</th>
                        <th>Disc%</th>
                        <th>Tax%</th>
                        <th>Cost Tot</th>
                        <th>MRP Tot</th>
                        <th>Tax Tot</th>
                        <th>Net Tot</th>
                        <th>Unit Cost</th>
                    </tr>
                </thead>
                <tbody id="productTable">
                </tbody>
                <tfoot style="background-color: #f8f9fa;">
                    <tr>
                        <td colspan="12" class="text-end fw-bold pe-2">Summary Total:</td>
                        <td id="sumCostTotal" class="fw-bold">0.00</td>
                        <td id="sumMrpTotal" class="fw-bold">0.00</td>
                        <td id="sumTaxTotal" class="fw-bold">0.00</td>
                        <td id="sumNetTotal" class="fw-bold">0.00</td>
                        <td colspan="2"></td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <!-- Action Buttons -->
        <div class="card flex-shrink-0 my-1">
            <div class="card-body">
                <div class="row g-1">
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control bg-light" id="grandTotal" name="grandTotal" 
                                step="0.001" readonly value="0.00">
                            <label>Total Order Amount</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <select class="form-select" name="payType" id="payType">
                                <option value="0">Select Payment Type</option>
                            </select>
                            
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <select class="form-select" name="bank" id="bank" disabled>
                                <option value="0">Select Mode</option>
                            </select>
                            
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control" id="advanceAmount" name="advanceAmount" 
                                step="0.001" value="0.00">
                            <label>Advance Amount</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="input-outline">
                            <input type="number" class="form-control bg-light" id="balanceAmount" name="balanceAmount" 
                                step="0.001" readonly value="0.00">
                            <label>Balance</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-primary w-100" id="saveBtn" onclick="savePurchaseOrder()">
                            <i class="fas fa-save me-2"></i>Create PO
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Purchase History Modal -->
    <div class="modal fade" id="purchaseHistoryModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Last 3 Purchase History</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="historyContent">
                        <div class="text-center">
                            <div class="spinner-border" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Available Cheques Modal -->
    <div class="modal fade" id="availableChequesModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title"><i class="fas fa-money-check me-2"></i>Available Cheques</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="chequesContent">
                        <div class="text-center">
                            <div class="spinner-border text-info" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        var contextPath = '<%=contextPath%>';
    </script>
    <script src="<%=contextPath%>/product/purchase/purchase.js"></script>
    <script>
        // Enable/disable bank based on payType selection
        $('#payType').on('change', function() {
            var payTypeVal = $('#payType').val();
            if (payTypeVal !== '0' && payTypeVal !== '1') {
                $('#bank').prop('disabled', false);
            } else {
                $('#bank').val('0').prop('disabled', true);
            }
        });

        // Calculate balance when advance amount changes
        $('#advanceAmount').on('input', function() {
            var grandTotal = parseFloat($('#grandTotal').val()) || 0;
            var advanceAmount = parseFloat($('#advanceAmount').val()) || 0;
            var balance = grandTotal - advanceAmount;
            $('#balanceAmount').val(balance.toFixed(3));
        });

        var prData = <%= mode.equals("from-pr") && prItems != null ? "{" +
            "\"supplier\": " + prHeader.get(3) + "," +
            "\"items\": [" : "null" %><% 
            if (mode.equals("from-pr") && prItems != null) {
                for (int i = 0; i < prItems.size(); i++) {
                    Vector item = (Vector) prItems.get(i);
                    if (i > 0) out.print(",");
                    out.print("{");
                    out.print("\"productName\": \"" + item.get(2).toString().replace("\"", "\\\"") + "\",");
                    out.print("\"pack\": " + item.get(3) + ",");
                    out.print("\"qtypack\": " + item.get(4) + ",");
                    out.print("\"quantity\": " + item.get(5) + ",");
                    out.print("\"free\": " + item.get(6) + ",");
                    out.print("\"rate\": " + item.get(7) + ",");
                    out.print("\"mrp\": " + item.get(8) + ",");
                    out.print("\"tax\": " + item.get(10));
                    out.print("}");
                }
                out.print("]");
            }
        %><%= mode.equals("from-pr") && prItems != null ? "}" : "" %>;

        function Load() {
            var status = 0;
            var param = 'status=' + status;
            
            $.ajax({
                type: "POST",
                url: "../details.jsp",
                data: param,
                success: function (result) {
                    var res = result.trim().split('<@>');
                    if (parseFloat(res.length) > 1) {
                        for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                            var arr1 = res[i].split("<#>");
                            $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#supplier");
                        }
                    }
                    
                    // If from PR, set supplier
                    if (prData) {
                        $('#supplier').val(prData.supplier);
                    }
                },
            });
            
            // Load payment types
            $.ajax({
                type: "POST",
                url: "../details.jsp",
                data: 'status=2',
                success: function (result) {
                    var res = result.trim().split('<@>');
                    if (parseFloat(res.length) > 1) {
                        for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                            var arr1 = res[i].split("<#>");
                            $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#payType");
                        }
                    }
                    $('#payType').val('1'); // Auto-select Cash
                },
            });
            
            // Load banks (from prod_bill_payment_type, excluding id=0)
            $.ajax({
                type: "POST",
                url: "../details.jsp",
                data: 'status=6',
                success: function (result) {
                    var res = result.trim().split('<@>');
                    if (parseFloat(res.length) > 1) {
                        for (var i = 0; i < parseFloat(res.length) - 1; i++) {
                            var arr1 = res[i].split("<#>");
                            $("<option value='" + parseInt(arr1[0]) + "'>" + arr1[1] + "</option>").appendTo("#bank");
                        }
                    }
                },
            });
            
            // Set default expected date to 7 days from now
            var nextWeek = new Date();
            nextWeek.setDate(nextWeek.getDate() + 7);
            $('#expectedDate').val(nextWeek.toISOString().split('T')[0]);
        }
        
        // Override viewPurchaseHistory to use parent directory path
        function viewPurchaseHistory(rowIndex) {
            var supplier = $('#supplier').val();
            var productName = $('#_productName_' + rowIndex).val();
            
            if (!supplier || supplier == '0') {
                Swal.fire({
                    title: 'Supplier Required',
                    text: 'Please select a supplier first to view purchase history.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                });
                $('#supplier').focus();
                return;
            }
            
            if (!productName || productName.trim() == '') {
                Swal.fire({
                    title: 'Product Required',
                    text: 'Please select a product first.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                });
                $('#_productName_' + rowIndex).focus();
                return;
            }
            
            // Show modal
            var modal = new bootstrap.Modal(document.getElementById('purchaseHistoryModal'));
            modal.show();
            
            // Fetch history
            $.ajax({
                type: 'POST',
                url: '../details.jsp',
                data: {
                    status: 5,
                    productName: productName,
                    supplierId: supplier
                },
                success: function(response) {
                    $('#historyContent').html(response);
                },
                error: function() {
                    $('#historyContent').html('<div class="alert alert-danger">Error loading purchase history</div>');
                }
            });
        }
        
        // Set payment type based on supplier GST status
        function setPaymentTypeBasedOnGst() {
            var supplier = $('#supplier').val();
            
            if (!supplier || supplier == '0') {
                return;
            }
            
            // Fetch supplier GST status
            $.ajax({
                type: 'POST',
                url: '../details.jsp',
                data: { 
                    status: 7,
                    supplierId: supplier 
                },
                success: function(result) {
                    var isGst = parseInt(result.trim());
                    
                    if (isGst === 1) {
                        // GST registered - auto-select Bank (assuming Bank is id=2)
                        $('#payType').val('2');
                    } else {
                        // Not GST registered - auto-select Cash (id=1)
                        $('#payType').val('1');
                    }
                    
                    // Trigger change event to enable/disable bank dropdown
                    $('#payType').trigger('change');
                }
            });
        }
        
        function checkSupplierCheques() {
            var supplier = $('#supplier').val();
            
            if (!supplier || supplier == '0') {
                return;
            }
            
            // Check if supplier has available cheques
            $.ajax({
                type: 'POST',
                url: 'validateCheques.jsp',
                data: { supplierId: supplier },
                success: function(result) {
                    var hasCheques = result.trim() == '1';
                    
                    if (!hasCheques) {
                        // Check if user has special permission
                        $.ajax({
                            type: 'POST',
                            url: 'checkPurchasePermission.jsp',
                            dataType: 'json',
                            success: function(permissionResult) {
                                if (permissionResult.hasPermission) {
                                    Swal.fire({
                                        title: 'No Available Cheques',
                                        text: 'This supplier has no available cheques, but you have permission to proceed.',
                                        icon: 'warning',
                                        confirmButtonText: 'OK'
                                    });
                                } else {
                                    Swal.fire({
                                        title: 'No Available Cheques',
                                        text: 'This supplier has no available cheques. You cannot create a Purchase Order.',
                                        icon: 'error',
                                        confirmButtonText: 'OK'
                                    });
                                }
                            }
                        });
                    }
                }
            });
        }
        
        function checkAvailableCheques() {
            var supplier = $('#supplier').val();
            
            if (!supplier || supplier == '0') {
                Swal.fire({
                    title: 'Supplier Required',
                    text: 'Please select a supplier first to check available cheques.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                });
                $('#supplier').focus();
                return;
            }
            
            // Show modal
            var modal = new bootstrap.Modal(document.getElementById('availableChequesModal'));
            modal.show();
            
            // Fetch available cheques
            $.ajax({
                type: 'POST',
                url: 'checkAvailableCheques.jsp',
                data: {
                    supplierId: supplier
                },
                success: function(response) {
                    $('#chequesContent').html(response);
                },
                error: function() {
                    $('#chequesContent').html('<div class="alert alert-danger">Error loading available cheques</div>');
                }
            });
        }
        
        function initializePO() {
            if (prData && prData.items) {
                // Load PR items into table
                prData.items.forEach(function(item, index) {
                    addProductRow(null, 0);
                    var rowId = index + 1;
                    $('#_productName_' + rowId).val(item.productName);
                    $('#_pack_' + rowId).val(item.pack);
                    $('#_qtyperpack_' + rowId).val(item.qtypack);
                    $('#_totqty_' + rowId).val(item.quantity);
                    $('#_freeqty_' + rowId).val(item.free);
                    $('#_cost_' + rowId).val(item.rate);
                    $('#_mrp_' + rowId).val(item.mrp);
                    $('#_tax_' + rowId).val(item.tax);
                    $('#_disc_' + rowId).val(0);
                    calculateRow(rowId);
                });
            } else {
                addProductRow(null, 0);
            }
        }
        
        function autoComplete(event, str, str1) {
            var unicode = event.keyCode ? event.keyCode : event.charCode;
            if (unicode != 38 && unicode != 40) {
                if (str1 == 1) {
                    $("#_productName_" + str).autocomplete({
                        source: function (request, response) {
                            $.ajax({
                                url: "../auto_complete.jsp",
                                data: { typeId: str1, q: request.term },
                                dataType: "text",
                                success: function (data) {
                                    if (data) {
                                        var suggestions = data.split("\n").map(function (item) {
                                            return item.trim();
                                        }).filter(function (item) {
                                            return item.length > 0;
                                        });
                                        if (suggestions.length > 0) {
                                            response(suggestions);
                                        } else {
                                            response(['No Product Found']);
                                        }
                                    }
                                },
                                error: function (xhr, status, error) {
                                    response([]);
                                }
                            });
                        },
                        minLength: 1
                    });
                }
            }
            return false;
        }
        
        function getProductDetails(str, str1) {
            var productName = $('#_productName_' + str).val();
            var status = 1;
            var param = 'status=' + status + '&productName=' + encodeURIComponent(productName.trim());

            $.ajax({
                type: "POST",
                url: "../details.jsp",
                data: param,
                success: function (_result) {
                    var resArr = _result.trim().split("<#>");
                    if (resArr.length > 1) {
                        $('#_productName_' + str).val(resArr[0]);
                        $('#_cost_' + str).val(resArr[4]);
                    }
                }
            });
        }
        
        function savePurchaseOrder() {
            var btn = $('#saveBtn');
            var poArr = '';
            var prodArr = '';

            var supplier = $('#supplier').val() || '0';
            var expectedDate = $('#expectedDate').val();
            var poNotes = $('#poNotes').val();
            var prId = $('#prId').val();
            var grandTotal = parseFloat($('#grandTotal').val()) || 0;
            var payType = $('#payType').val() || '0';
            var bank = $('#bank').val() || '0';
            var advanceAmount = parseFloat($('#advanceAmount').val()) || 0;
            var balanceAmount = parseFloat($('#balanceAmount').val()) || 0;

            if (supplier == '0') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please select supplier.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#supplier').focus();
                return false;
            }
            
            // Check available cheques before proceeding
            btn.prop('disabled', true);
            $.ajax({
                type: 'POST',
                url: 'validateCheques.jsp',
                data: { supplierId: supplier },
                success: function(result) {
                    var hasCheques = result.trim() == '1';
                    
                    if (!hasCheques) {
                        // Check if user has special permission
                        $.ajax({
                            type: 'POST',
                            url: 'checkPurchasePermission.jsp',
                            dataType: 'json',
                            success: function(permissionResult) {
                                if (permissionResult.hasPermission) {
                                    // User has permission, show confirmation
                                    Swal.fire({
                                        title: 'No Available Cheques',
                                        text: 'This supplier has no available cheques. Do you want to proceed with creating the Purchase Order?',
                                        icon: 'warning',
                                        showCancelButton: true,
                                        confirmButtonText: 'Yes, Proceed',
                                        cancelButtonText: 'Cancel'
                                    }).then(function(confirmResult) {
                                        if (confirmResult.isConfirmed) {
                                            proceedWithSave();
                                        } else {
                                            btn.prop('disabled', false);
                                        }
                                    });
                                } else {
                                    // No permission, cannot proceed
                                    Swal.fire({
                                        title: 'No Available Cheques',
                                        text: 'No available cheques found for this supplier. Cannot create Purchase Order.',
                                        icon: 'error',
                                        confirmButtonText: 'OK'
                                    });
                                    btn.prop('disabled', false);
                                }
                            },
                            error: function() {
                                Swal.fire({
                                    title: 'Error',
                                    text: 'Unable to verify permissions. Cannot create Purchase Order.',
                                    icon: 'error',
                                    confirmButtonText: 'OK'
                                });
                                btn.prop('disabled', false);
                            }
                        });
                    } else {
                        // Has cheques, proceed with PO creation
                        proceedWithSave();
                    }
                },
                error: function() {
                    Swal.fire({
                        title: 'Error',
                        text: 'Unable to validate cheque availability. Please try again.',
                        icon: 'error',
                        confirmButtonText: 'OK'
                    });
                    btn.prop('disabled', false);
                }
            });
        }
        
        function proceedWithSave() {
            var btn = $('#saveBtn');
            var poArr = '';
            var prodArr = '';
            
            var supplier = $('#supplier').val() || '0';
            var expectedDate = $('#expectedDate').val();
            var poNotes = $('#poNotes').val();
            var prId = $('#prId').val();
            var grandTotal = parseFloat($('#grandTotal').val()) || 0;
            var payType = $('#payType').val() || '0';
            var bank = $('#bank').val() || '0';
            var advanceAmount = parseFloat($('#advanceAmount').val()) || 0;
            var balanceAmount = parseFloat($('#balanceAmount').val()) || 0;
            
            if (expectedDate.trim() == '') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please select expected delivery date.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#expectedDate').focus();
                btn.prop('disabled', false);
                return false;
            }
            
            if (grandTotal <= 0) {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please add at least one product to the order.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                btn.prop('disabled', false);
                return false;
            }
            
            if (advanceAmount > 0 && payType == '0') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please select payment mode for advance payment.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#payType').focus();
                btn.prop('disabled', false);
                return false;
            }
            
            if (advanceAmount > 0 && payType != '1' && bank == '0') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please select bank for advance payment.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#bank').focus();
                btn.prop('disabled', false);
                return false;
            }
            
            if (advanceAmount > grandTotal) {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Advance amount cannot be greater than total amount.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#advanceAmount').focus();
                btn.prop('disabled', false);
                return false;
            }

            var proRowCount = parseFloat($('#_proAddRowCount').val());
            if (proRowCount >= 1) {
                for (var i = 0; i <= proRowCount; i++) {
                    if ($('#_productTableRow_' + i).length) {
                        var _productName = $('#_productName_' + i).val().trim();
                        var _pack = parseFloat($('#_pack_' + i).val()) || 0;
                        var _qtyperpack = parseFloat($('#_qtyperpack_' + i).val()) || 0;
                        var _totqty = parseFloat($('#_totqty_' + i).val()) || 0;
                        var _freeqty = parseFloat($('#_freeqty_' + i).val()) || 0;
                        var _cost = parseFloat($('#_cost_' + i).val()) || 0;
                        var _mrp = parseFloat($('#_mrp_' + i).val()) || 0;
                        var _disc = parseFloat($('#_disc_' + i).val()) || 0;
                        var _tax = parseFloat($('#_tax_' + i).val()) || 0;

                        if (_totqty > 0 && _productName != '')
                            prodArr += _productName + '<#>' + _pack + '<#>' + _qtyperpack + '<#>' + _totqty + '<#>' + _freeqty + '<#>' + _cost + '<#>' + _mrp + '<#>' + _disc + '<#>' + _tax + '<@>';
                    }
                }
                
                poArr = supplier + '<#>' + expectedDate + '<#>' + poNotes + '<#>' + prId + '<#>' + payType + '<#>' + bank + '<#>' + advanceAmount + '<#>' + balanceAmount;
                var param = 'poArr=' + encodeURIComponent(poArr) + '&prodArr=' + encodeURIComponent(prodArr);

                $.ajax({
                    type: "POST",
                    url: "save.jsp",
                    data: param,
                    success: function (_result) {
                        var result = _result.trim();
                        if (result.indexOf('Error') >= 0 || result.indexOf('error') >= 0) {
                            Swal.fire({
                                title: 'Error',
                                text: result,
                                icon: 'error',
                                confirmButtonText: 'OK'
                            });
                            btn.prop('disabled', false);
                        } else {
                            Swal.fire({
                                title: 'PO Created!',
                                text: 'Purchase Order ' + result + ' has been created successfully.',
                                icon: 'success',
                                confirmButtonText: 'OK'
                            }).then(() => {
                                window.location.href = '<%=contextPath%>/product/purchase/order/list.jsp';
                            });
                        }
                    },
                    error: function () {
                        Swal.fire({
                            title: 'Error',
                            text: 'Failed to create purchase order. Please try again.',
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                        btn.prop('disabled', false);
                    }
                });
            } else {
                btn.prop('disabled', false);
            }
        }
    </script>
</body>
</html>
