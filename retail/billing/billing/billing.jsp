<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="java.util.*, javax.servlet.http.*" %>
        <jsp:useBean id="prod" class="product.productBean" />
        <jsp:useBean id="userBn" class="user.userBean" />
        <% 
        String contextPaths = request.getContextPath();
        Integer uid=(Integer) session.getAttribute("userId"); //out.print(uid);
        Vector attenderList = prod.getActiveAttenders();
        int userDiscPer = (uid != null) ? userBn.getUserDiscPer(uid) : 100;
        %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Billing - Billing App</title>
                <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
                <jsp:include page="/assets/common/head.jsp" />
                <style>
/* ====== Billing Page – Professional Mobile-Friendly Design ====== */
body { background: #f0edf7 !important; }
.billing-content { padding: 8px 10px; display: flex; flex-direction: column; gap: 10px; }

/* Cards */
.b-card {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 2px 14px rgba(87,10,87,0.09);
  padding: 14px 16px;
}
.b-card-header {
  font-size: 0.68rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1.8px;
  color: #570a57;
  margin-bottom: 12px;
  border-bottom: 2px solid #f3e8f8;
  padding-bottom: 7px;
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Floating label inputs */
.fl-input { position: relative; }
.fl-input input,
.fl-input input.form-control {
  height: 50px;
  border-radius: 10px;
  border: 1.5px solid #c9b4d6 !important;
  background: #faf8fc !important;
  padding: 18px 12px 6px !important;
  font-size: 0.88rem;
  width: 100%;
  color: #2d1445;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-shadow: none !important;
}
.fl-input input:focus,
.fl-input input.form-control:focus {
  border-color: #570a57 !important;
  box-shadow: 0 0 0 3px rgba(87,10,87,0.12) !important;
  outline: none;
}
.fl-input label {
  position: absolute;
  top: 50%;
  left: 13px;
  transform: translateY(-50%);
  font-size: 0.82rem;
  color: #999;
  pointer-events: none;
  transition: all 0.18s;
  background: transparent;
  padding: 0 2px;
  margin: 0;
}
.fl-input input:focus ~ label,
.fl-input input:not(:placeholder-shown) ~ label {
  top: 6px;
  transform: none;
  font-size: 0.6rem;
  color: #570a57;
  font-weight: 700;
  letter-spacing: 0.5px;
}

/* Bill Table */
.billing-table-wrap { border-radius: 14px; overflow: hidden; border: 1.5px solid #ede0f5; }
.bill-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.78rem;
  background: #fff;
  margin: 0;
}
.bill-table thead tr { background: linear-gradient(135deg, #3d1a52, #570a57); }
.bill-table thead th {
  color: #fff !important;
  font-weight: 600;
  font-size: 0.68rem;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  padding: 10px 8px;
  border: none !important;
  background: transparent !important;
}
.bill-table tbody tr { border-bottom: 1px solid #f0e8f5; }
.bill-table tbody tr:hover { background: #faf5ff; }
.bill-table tbody td {
  padding: 7px 8px;
  color: #2d1445;
  vertical-align: middle;
  border: none;
  border-bottom: 1px solid #f0e8f5;
}
.bill-table tbody .empty-row td { color: transparent; height: 34px; pointer-events: none; }

/* Totals grid */
.total-box {
  background: #faf5ff;
  border-radius: 10px;
  padding: 8px 10px;
  text-align: center;
  border: 1.5px solid #e8d5f0;
  height: 100%;
}
.total-label {
  font-size: 0.6rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  color: #999;
  margin-bottom: 3px;
}
.total-val {
  border: none;
  background: transparent;
  text-align: center;
  font-size: 1rem;
  font-weight: 700;
  color: #570a57;
  width: 100%;
  padding: 0;
  outline: none;
}
.payable-box { background: linear-gradient(135deg, #3d1a52, #570a57); border-color: #570a57; }
.payable-box .total-label { color: #ddc8ff; }
.payable-box .total-val { color: #fff; font-size: 1.2rem; }

/* Payment inputs/selects in payment section */
.pay-label {
  font-size: 0.6rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  color: #999;
  display: block;
  margin-bottom: 4px;
}
.pay-select.form-select,
.pay-select.form-control {
  height: 50px;
  border-radius: 10px;
  border: 1.5px solid #c9b4d6 !important;
  background: #faf8fc;
  font-size: 0.85rem;
  color: #2d1445;
  padding: 12px 10px;
}
.pay-select.form-select:focus,
.pay-select.form-control:focus {
  border-color: #570a57 !important;
  box-shadow: 0 0 0 3px rgba(87,10,87,0.12) !important;
}

/* Action buttons */
.btn-save  { background: linear-gradient(135deg, #1e7e34, #28a745) !important; color: #fff !important; font-weight: 700; font-size: 0.83rem; height: 50px; border-radius: 10px; border: none !important; letter-spacing: 0.4px; }
.btn-save:hover  { background: linear-gradient(135deg, #155724, #1e7e34) !important; transform: translateY(-1px); box-shadow: 0 5px 14px rgba(40,167,69,0.35) !important; }
.btn-print { background: linear-gradient(135deg, #0a58ca, #0d6efd) !important; color: #fff !important; font-weight: 700; font-size: 0.83rem; height: 50px; border-radius: 10px; border: none !important; }
.btn-print:hover { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(13,110,253,0.35) !important; color: #fff !important; }
.btn-new  { background: linear-gradient(135deg, #e06c0d, #fd7e14) !important; color: #fff !important; font-weight: 700; font-size: 0.83rem; height: 50px; border-radius: 10px; border: none !important; }
.btn-new:hover  { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(253,126,20,0.35) !important; color: #fff !important; }
.btn-dup  { background: linear-gradient(135deg, #495057, #6c757d) !important; color: #fff !important; font-weight: 700; font-size: 0.83rem; height: 50px; border-radius: 10px; border: none !important; }
.btn-dup:hover  { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(108,117,125,0.35) !important; color: #fff !important; }
.btn-add  { background: linear-gradient(135deg, #3d1a52, #570a57) !important; color: #fff !important; font-weight: 700; font-size: 0.83rem; height: 50px; border-radius: 10px; border: none !important; }
.btn-add:hover  { transform: translateY(-1px); box-shadow: 0 5px 14px rgba(87,10,87,0.4) !important; color: #fff !important; }

/* Bill number box */
.bill-no-box {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 50px;
  padding: 0 18px;
  background: #faf5ff;
  border-radius: 10px;
  border: 1.5px solid #e8d5f0;
  font-size: 1rem;
  font-weight: 700;
  color: #570a57;
  min-width: 100px;
}

/* Exchange point banner */
.ex-banner {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  background: #d4edda;
  border-radius: 10px;
  padding: 10px 14px;
  font-size: 0.82rem;
  color: #155724;
  margin-top: 10px;
}
.ex-banner .btn-ex { background: #28a745; color: #fff; padding: 5px 12px; border-radius: 7px; font-size: 0.75rem; border: none; cursor: pointer; font-weight: 600; }
.ex-banner .btn-ex-close { margin-left: auto; background: none; border: none; font-size: 1rem; cursor: pointer; color: #155724; line-height: 1; }

/* Divider label between totals & payment */
.section-divider {
  font-size: 0.62rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 1.5px;
  color: #bbb;
  margin: 10px 0 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}
.section-divider::before, .section-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: #eee;
}

/* Mobile tweaks */
@media (max-width: 575px) {
  .billing-content { padding: 6px; gap: 8px; }
  .b-card { padding: 12px 12px; border-radius: 12px; }
  .fl-input input, .fl-input input.form-control { height: 48px; font-size: 0.85rem; }
  .pay-select.form-select { height: 48px; }
  .btn-save, .btn-print, .btn-new, .btn-dup, .btn-add { height: 48px; font-size: 0.8rem; }
  .bill-table { font-size: 0.72rem; }
  .bill-table thead th { padding: 8px 5px; font-size: 0.62rem; }
  .bill-table tbody td { padding: 6px 5px; }
  .total-val { font-size: 0.9rem; }
  .payable-box .total-val { font-size: 1.05rem; }
}
                </style>
            </head>

<body class="billing-page-body">
    <!-- Navbar -->
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="billing-content">

        <!-- ① Customer Section -->
        <div class="b-card">
            <div class="b-card-header"><i class="fas fa-user-circle"></i> Customer Details</div>
            <div class="row g-3">
                <div class="col-12 col-sm-6">
                    <div class="fl-input">
                        <input type="text" id="customerName" class="form-control" placeholder=" " autocomplete="off">
                        <label>Customer Name</label>
                        <input type="hidden" id="customerId" value="0">
                        <input type="hidden" id="customerCreditLimit" value="0">
                        <input type="hidden" id="customerExchangePoint" value="0">
                        <input type="hidden" id="exchangePointUsed" value="0">
                    </div>
                </div>
                <div class="col-12 col-sm-6">
                    <div class="fl-input">
                        <input type="text" id="customerPhn" class="form-control" placeholder=" " autocomplete="off">
                        <label>Phone Number</label>
                    </div>
                </div>
            </div>
            <!-- Exchange Point Banner -->
            <div id="exchangePointBanner" class="ex-banner d-none">
                <i class="fas fa-coins"></i>
                <strong>Exchange Points: ₹<span id="exchangePointValue">0</span></strong>
                <button type="button" class="btn-ex" onclick="applyExchangePointDiscount()">
                    <i class="fas fa-tag me-1"></i>Use as Discount
                </button>
                <button type="button" class="btn-ex-close" onclick="dismissExchangePointBanner()">✕</button>
            </div>
        </div>

        <!-- ② Add Item Section -->
        <div class="b-card">
            <div class="b-card-header"><i class="fas fa-box-open"></i> Add Item</div>
            <!-- Hidden functional fields -->
            <div style="display:none;">
                <input type="text" id="productCode" class="form-control" placeholder="">
                <select id="productUnit" class="form-select" disabled>
                    <option value="">Unit</option>
                    <option value="gram">Gram</option>
                </select>
                <input type="hidden" id="productUnitId" value="">
                <input type="hidden" id="productUnitName" value="">
                <input type="hidden" id="productConvertionUnit" value="">
                <input type="text" id="productDiscount" class="form-control only-numbers" placeholder="" value="0" oninput="setDefaultValue(this);">
            </div>
            <div class="row g-2 align-items-end">
                <div class="col-12 col-sm-5 col-md-4">
                    <div class="fl-input">
                        <input type="text" id="productName" name="productName" class="form-control" placeholder=" ">
                        <label>Item Name</label>
                    </div>
                </div>
                <div class="col-4 col-sm-2">
                    <div class="fl-input">
                        <input type="number" id="productQty" class="form-control" placeholder=" " value="1" min="1">
                        <label id="qtyLabel">Qty</label>
                    </div>
                </div>
                <div class="col-4 col-sm-2">
                    <div class="fl-input">
                        <input type="number" id="productPrice" class="form-control" placeholder=" " min="0">
                        <label>Price</label>
                    </div>
                </div>
                <div class="col-4 col-sm-2">
                    <div class="fl-input">
                        <input type="text" id="productCourierFee" class="form-control only-numbers" placeholder=" " value="0" oninput="setDefaultValue(this);">
                        <label>Courier</label>
                    </div>
                </div>
                <div class="col-12 col-sm-1 col-md-2" style="display:none;">
                    <button class="btn btn-add w-100" onclick="addProduct()">
                        <i class="fas fa-plus me-1"></i>Add
                    </button>
                </div>
            </div>
        </div>

        <!-- ③ Bill Items Table (hidden in single-item mode) -->
        <div class="b-card p-0" style="display:none;">
            <div class="table-responsive billing-table-wrap">
                <table class="bill-table">
                    <thead>
                        <tr>
                            <th style="width:5%">#</th>
                            <th style="width:10%;display:none">Code</th>
                            <th>Item Name</th>
                            <th style="width:8%">Qty</th>
                            <th style="width:11%">Price</th>
                            <th style="width:10%;display:none">Discount</th>
                            <th style="width:11%">Courier</th>
                            <th style="width:11%">Total</th>
                            <th style="width:12%">Action</th>
                        </tr>
                    </thead>
                    <tbody id="billBody">
                        <tr class="empty-row"><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
                        <tr class="empty-row"><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
                        <tr class="empty-row"><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
                        <tr class="empty-row"><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
                        <tr class="empty-row"><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td style="display:none"></td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ④ Totals + Payment + Actions -->
        <div class="b-card">

            <!-- Totals Row -->
            <div class="row g-2 mb-1">
                <div class="col-6 col-sm-3 col-lg">
                    <div class="total-box">
                        <div class="total-label">Price Total</div>
                        <input type="text" class="total-val only-numbers" id="priceTotal" value="0" readonly>
                    </div>
                </div>
                <div style="display:none;">
                    <input type="text" class="only-numbers" id="discountTotal" value="0" readonly>
                </div>
                <div class="col-6 col-sm-3 col-lg">
                    <div class="total-box">
                        <div class="total-label">Courier Total</div>
                        <input type="text" class="total-val only-numbers" id="commissionTotal" value="0" readonly>
                    </div>
                </div>
                <div class="col-6 col-sm-3 col-lg">
                    <div class="total-box">
                        <div class="total-label">Grand Total</div>
                        <input type="text" class="total-val only-numbers" id="grandTotal" value="0" readonly>
                    </div>
                </div>
                <div style="display:none;">
                    <input type="text" class="only-numbers" id="finalDiscount" value="0" oninput="setDefaultValue(this); updatePayableAmount();">
                    <input type="text" class="only-numbers" id="courierFee" value="0" oninput="setDefaultValue(this); updatePayableAmount();">
                </div>
                <div class="col-6 col-sm-3 col-lg">
                    <div class="total-box payable-box">
                        <div class="total-label">Payable</div>
                        <input type="text" class="total-val only-numbers" id="payableAmount" value="0" readonly>
                    </div>
                </div>
            </div>

            <!-- Payment Section -->
            <div class="section-divider">Payment</div>
            <div class="row g-2 mb-2">
                <div class="col-6 col-md-4 col-lg">
                    <label class="pay-label">Payment Mode</label>
                    <select name="mode" id="mode" class="form-select pay-select">
                        <option value="1">Cash</option>
                        <option value="2" selected>Bank</option>
                        <option value="3">Mixed</option>
                    </select>
                </div>
                <div class="col-6 col-md-4 col-lg">
                    <label class="pay-label">Payment Type</label>
                    <select name="type" id="type" class="form-select pay-select">
                        <option value="1">UPI</option>
                        <option value="2">Debit Card</option>
                        <option value="3">Credit Card</option>
                        <option value="4">Net Banking</option>
                        <option value="5">Wallet</option>
                    </select>
                </div>
                <div class="col-6 col-md-4 col-lg">
                    <label class="pay-label">Cash Paid</label>
                    <input type="text" class="form-control pay-select only-numbers" id="paid" value="0">
                </div>
                <div class="col-6 col-md-4 col-lg">
                    <label class="pay-label">Bank Paid</label>
                    <input type="text" class="form-control pay-select only-numbers" id="bankPaid" value="0">
                </div>
                <div class="col-6 col-md-4 col-lg">
                    <label class="pay-label">Balance</label>
                    <input type="text" class="form-control pay-select only-numbers" id="balance" value="0">
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="section-divider">Actions</div>
            <div class="row g-2">
                <div class="col-6 col-md col-lg">
                    <button id="saveBillBtn" class="btn btn-save w-100" onclick="saveBill()">
                        <i class="fas fa-save me-1"></i>SAVE BILL
                    </button>
                </div>
                <div class="col-6 col-md col-lg">
                    <button class="btn btn-print w-100" onclick="printBill()" title="Direct print to thermal printer">
                        <i class="fas fa-print me-1"></i>PRINT
                    </button>
                </div>
                <div class="col-6 col-md col-lg" id="quotationBtnDiv" style="display:none;"></div>
                <div class="col-6 col-md col-lg" id="quotationPrintBtnDiv" style="display:none;"></div>
                <div class="col-6 col-md col-lg">
                    <button type="button" class="btn btn-new w-100" onclick="newBill()">
                        <i class="fas fa-redo me-1"></i>NEW BILL
                    </button>
                </div>
                <div class="col-6 col-md col-lg">
                    <button class="btn btn-dup w-100" data-bs-toggle="modal" data-bs-target="#duplicateBillModal">
                        <i class="fas fa-copy me-1"></i>DUPLICATE
                    </button>
                </div>
                <div class="col-12 col-md-auto ms-md-auto">
                    <div class="bill-no-box">
                        <span id="billNoSpan"></span>
                    </div>
                </div>
            </div>

        </div><!-- end totals card -->

    </div><!-- end billing-content -->

            
                            <!-- Modals -->
                            <%@ include file="duplicateBillModal.jsp" %>
                            <%@ include file="quotationList.jsp" %>
                            
                            <!-- Order List Modal -->
                            <div class="modal fade" id="orderListModal" tabindex="-1" aria-labelledby="orderListModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-fullscreen-sm-down">
                                    <div class="modal-content">
                                        <div class="modal-header bg-success text-white">
                                            <h5 class="modal-title" id="orderListModalLabel">
                                                <i class="fas fa-utensils me-2"></i>Pending Orders
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body p-2 p-md-3">
                                            <div id="orderListSpinner" class="text-center" style="display: none;">
                                                <div class="spinner-border text-success" role="status">
                                                    <span class="visually-hidden">Loading...</span>
                                                </div>
                                            </div>
                                            <div id="orderListContent">
                                                <!-- Desktop View -->
                                                <div class="d-none d-md-block">
                                                    <div class="table-responsive">
                                                        <table class="table table-bordered table-hover table-sm">
                                                            <thead class="table-light">
                                                                <tr>
                                                                    <th>Order No</th>
                                                                    <th>Table</th>
                                                                    <th>Date</th>
                                                                    <th>Time</th>
                                                                    <th>Status</th>
                                                                    <th>Actions</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody id="orderListTableBody">
                                                                <!-- Orders will be loaded here -->
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                                
                                                <!-- Mobile View (Cards) -->
                                                <div class="d-md-none" id="orderListCardsBody">
                                                    <!-- Orders will be loaded here as cards -->
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Available Cheques Modal -->
                            <div class="modal fade" id="availableChequesModal" tabindex="-1" aria-labelledby="availableChequesModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg">
                                    <div class="modal-content">
                                        <div class="modal-header bg-primary text-white">
                                            <h5 class="modal-title" id="availableChequesModalLabel">
                                                <i class="fas fa-money-check-alt me-2"></i>Available Cheques for <span id="chequeCustomerName"></span>
                                            </h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div id="chequeLoadingSpinner" class="text-center" style="display: none;">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Loading...</span>
                                                </div>
                                            </div>
                                            <div id="chequeContent">
                                                <div class="table-responsive">
                                                    <table class="table table-bordered table-hover table-sm">
                                                        <thead class="table-light">
                                                            <tr>
                                                                <th>#</th>
                                                                <th>Cheque Number</th>
                                                                <th>Cheque entry Date</th>
                                                                <th>Bank Name</th>
                                                                
                                                                <th>Status</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody id="chequeTableBody">
                                                            <tr>
                                                                <td colspan="6" class="text-center text-muted">No cheques available</td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Product History Modal -->
                            <div class="modal fade" id="productHistoryModal" tabindex="-1" aria-labelledby="productHistoryModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-fullscreen-sm-down">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="productHistoryModalLabel">Last 10 Bills for <span id="historyProductName"></span></h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div id="historyLoadingSpinner" class="text-center" style="display: none;">
                                                <div class="spinner-border text-primary" role="status">
                                                    <span class="visually-hidden">Loading...</span>
                                                </div>
                                            </div>
                                            <div id="historyContent" class="table-responsive">
                                                <table class="table table-bordered table-sm">
                                                    <thead>
                                                        <tr>
                                                            <th>Bill No</th>
                                                            <th>Date</th>
                                                            <th>Time</th>
                                                            <th>Customer</th>
                                                            <th>Qty</th>
                                                            <th>Price</th>
                                                            <th>Courier</th>
                                                            <th>Total</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody id="historyTableBody">
                                                        <tr>
                                                            <td colspan="8" class="text-center">No history available</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Bill Meta Modal -->
                            <div class="modal fade" id="billMetaModal" tabindex="-1" aria-labelledby="billMetaModalLabel" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content">
                                        <div class="modal-header bg-success text-white">
                                            <h5 class="modal-title" id="billMetaModalLabel">Saved Bill Details</h5>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-2"><strong>Description:</strong> <span id="savedDescriptionVal">-</span></div>
                                            <div class="mb-2"><strong>Delivery Date:</strong> <span id="savedDeliveryDateVal">-</span></div>
                                            <div class="mb-2"><strong>Downloaded:</strong> <span id="savedIsDownloadedVal">No</span></div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                                <!--modals-->
                                <script>
                                    var contextPath = '<%=contextPaths%>';
                                    var userMaxDiscPer = <%=userDiscPer%>;
                                </script>
                                <script src="bluetoothPrinter.js"></script>
                                <script src="billing.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Focus phone number on fresh page load and auto-close sidebar
            setTimeout(function() {
                closeSidebar();
                const cph = document.getElementById('customerPhn');
                if (cph) {
                    cph.focus();
                    return;
                }
                const pn = document.getElementById('productName');
                if (pn) pn.focus();
            }, 150);
            
            // Auto-close sidebar when clicking on input fields
            const productCodeInput = document.getElementById('productCode');
            const productNameInput = document.getElementById('productName');
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');
            const body = document.body;
            
            function isMobile() {
                return window.innerWidth <= 768;
            }
            
            function closeSidebar() {
                if (sidebar && sidebarOverlay) {
                    if (isMobile()) {
                        sidebar.classList.remove('show');
                        sidebarOverlay.classList.remove('show');
                        body.classList.remove('sidebar-open');
                    } else {
                        if (!sidebar.classList.contains('hidden')) {
                            sidebar.classList.add('hidden');
                            body.classList.add('sidebar-hidden');
                        }
                    }
                }
            }
            
            function enterFullscreen() {
                const elem = document.documentElement;
                if (!document.fullscreenElement && !document.webkitFullscreenElement && !document.msFullscreenElement) {
                    if (elem.requestFullscreen) {
                        elem.requestFullscreen().catch(err => {
                            console.log('Fullscreen request failed:', err);
                        });
                    } else if (elem.webkitRequestFullscreen) { // Safari
                        elem.webkitRequestFullscreen();
                    } else if (elem.msRequestFullscreen) { // IE11
                        elem.msRequestFullscreen();
                    }
                }
            }
            
            function closeSidebarAndFullscreen() {
                closeSidebar();
                enterFullscreen();
            }
            
            // Add focus event listeners to auto-close sidebar only
            if (productCodeInput) {
                productCodeInput.addEventListener('focus', closeSidebar);
            }
            if (productNameInput) {
                productNameInput.addEventListener('focus', closeSidebar);
            }
            
            // Press Escape to exit fullscreen (browser default)
            document.addEventListener('fullscreenchange', function() {
                if (!document.fullscreenElement) {
                    console.log('Exited fullscreen mode');
                }
            });
            
            // Ctrl+S keyboard shortcut to save bill
            document.addEventListener('keydown', function(event) {
                // Check for Ctrl+S (Windows/Linux) or Cmd+S (Mac)
                if ((event.ctrlKey || event.metaKey) && event.key === 's') {
                    event.preventDefault(); // Prevent browser's default save dialog
                    
                    // Trigger save bill function
                    const saveBillBtn = document.getElementById('saveBillBtn');
                    if (saveBillBtn && !saveBillBtn.disabled) {
                        saveBill();
                    }
                }
            });
        });
    </script>
</body>

            </html>