<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Purchase Request - Billing App</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<style>
    /* Table wrapper for horizontal scroll */
    .table-wrapper {
        overflow-x: auto;
        overflow-y: auto;
    }
    
    /* Fixed Table Layout */
    .table-fixed-layout {
        min-width: 1400px;
        table-layout: fixed;
        width: 100%;
    }

    /* Column Width Definitions */
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
<body style="height: 100vh; overflow: hidden;" onload="Load();addProductRow(event,0)">

    <div class="container-fluid h-100 d-flex flex-column">
        <!-- Navbar -->
        <%@ include file="/assets/navbar/navbar.jsp" %>
        
        <input type="hidden" id="_proAddRowCount" name="_proAddRowCount" value="0">
        <input type="hidden" id="_proDelRowCount" name="_proDelRowCount" value="0">

        <!-- Request Details (Top) -->
        <div class="card flex-shrink-0 my-1">
            <div class="card-body">
                <div class="row g-1">
                    <div class="col-md-3">
                        <div class="input-outline">
                            <select class="form-select" name="supplier" id="supplier">
                                <option value="0">Select Supplier (TBD)</option>
                                <!-- Populated by JS -->
                            </select>
                            
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="input-outline">
                            <input type="date" class="form-control" id="reqDate" name="reqDate">
                            <label>Request Date</label>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="input-outline">
                            <textarea class="form-control" id="notes" name="notes" rows="1" placeholder="Request notes or justification"></textarea>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Product Table (Middle - Flexible) -->
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
                        <th>Est. Cost</th>
                        <th>Est. MRP</th>
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
                    <!-- Rows added by JS -->
                </tbody>
                <tfoot style="background-color: #f8f9fa;">
                    <tr>
                        <td colspan="12" class="text-end fw-bold pe-2">Summary Total:</td>
                        <td id="sumCostTotal" class="fw-bold">0.00</td>
                        <td id="sumMrpTotal" class="fw-bold">0.00</td>
                        <td id="sumTaxTotal" class="fw-bold">0.00</td>
                        <td id="sumNetTotal" class="fw-bold">0.00</td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>

        <!-- Action Buttons (Bottom) -->
        <div class="card flex-shrink-0 my-1">
            <div class="card-body">
                <div class="row g-1">
                    <div class="col-md-10">
                        <div class="input-outline">
                            <input type="number" class="form-control bg-light" id="grandTotal" name="grandTotal" step="0.001" readonly value="0.00">
                            <label>Total Estimated Amount</label>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <button type="button" class="btn btn-primary w-100" id="saveBtn" onclick="savePurchaseRequest()">
                            <i class="fas fa-paper-plane me-2"></i>Submit Request
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

    <script>
        var contextPath = '<%=contextPath%>';
    </script>
    <script src="<%=contextPath%>/product/purchase/purchase.js"></script>
    <script>
        // Override Load function for PR-specific data
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
                },
            });
            
            // Set default request date to today
            var today = new Date().toISOString().split('T')[0];
            $('#reqDate').val(today);
        }
        
        // Override autoComplete to use parent directory path
        function autoComplete(event, str, str1) {
            var unicode = event.keyCode ? event.keyCode : event.charCode;

            if (unicode != 38 && unicode != 40) {
                if (str1 == 1) {
                    $("#_productName_" + str).autocomplete({
                        source: function (request, response) {
                            $.ajax({
                                url: "../auto_complete.jsp",
                                data: {
                                    typeId: str1,
                                    q: request.term
                                },
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
                                            $(".ui-menu-item:contains('No Product Found')")
                                                .css('color', 'red')
                                                .css('pointer-events', 'none')
                                                .addClass('no-select');
                                        }
                                    }
                                },
                                error: function (xhr, status, error) {
                                    console.error("Autocomplete error:", status, error);
                                    response([]);
                                }
                            });
                        },
                        minLength: 1,
                        select: function(event, ui) {
                            // When a valid item is selected, do nothing special
                        },
                        change: function(event, ui) {
                            if (!ui.item && $(this).val().trim() !== '') {
                                Swal.fire({
                                    title: 'Invalid Product',
                                    text: 'Please select a valid product from the list.',
                                    icon: 'warning',
                                    confirmButtonText: 'OK'
                                });
                                $(this).val('');
                            }
                        }
                    });
                }
            }

            return false;
        }
        
        // Override getProductDetails to use parent directory path
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
        
        // Save Purchase Request
        function savePurchaseRequest() {
            var btn = $('#saveBtn');
            var reqArr = '';
            var prodArr = '';

            var supplier = $('#supplier').val() || '0';
            var reqDate = $('#reqDate').val();
            var notes = $('#notes').val();
            var grandTotal = parseFloat($('#grandTotal').val()) || 0;

            if (supplier == '0') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please select a supplier.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#supplier').focus();
                return false;
            }

            if (reqDate.trim() == '') {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please select request date.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                $('#reqDate').focus();
                return false;
            }
            
            if (grandTotal <= 0) {
                Swal.fire({
                    title: 'Validation Error',
                    text: 'Please add at least one product to the request.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                return false;
            }
            
            btn.prop('disabled', true);

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
                
                reqArr = supplier + '<#>' + reqDate + '<#>' + notes;
                var param = 'reqArr=' + encodeURIComponent(reqArr) + '&prodArr=' + encodeURIComponent(prodArr);

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
                                title: 'Request Submitted!',
                                text: 'Purchase Request ' + result + ' has been created successfully.',
                                icon: 'success',
                                confirmButtonText: 'OK'
                            }).then(() => {
                                window.location.href = '<%=contextPath%>/product/purchase/request/list.jsp';
                            });
                        }
                    },
                    error: function () {
                        Swal.fire({
                            title: 'Error',
                            text: 'Failed to save purchase request. Please try again.',
                            icon: 'error',
                            confirmButtonText: 'OK'
                        });
                        btn.prop('disabled', false);
                    }
                });
            }
        }
    </script>
</body>
</html>
