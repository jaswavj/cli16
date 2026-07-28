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
/* ── POS Billing — fluid responsive ── */
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..40,600;0,9..40,700;1,9..40,400&display=swap');

:root {
    --pos-font: 'DM Sans', system-ui, -apple-system, sans-serif;
    --pos-bg: #e8edf4;
    --pos-surface: #ffffff;
    --pos-border: #dde3ec;
    --pos-border-strong: #c8d1de;
    --pos-text: #0f172a;
    --pos-text-secondary: #64748b;
    --pos-text-muted: #94a3b8;
    --pos-primary: #2563eb;
    --pos-primary-dark: #1d4ed8;
    --pos-primary-soft: #eff6ff;
    --pos-accent: #0ea5e9;
    --pos-success: #059669;
    --pos-success-soft: #ecfdf5;
    --pos-warning: #d97706;
    --pos-radius: clamp(10px, 1vw, 14px);
    --pos-radius-sm: clamp(6px, 0.7vw, 10px);
    --pos-shadow: 0 1px 3px rgba(15,23,42,.06), 0 4px 16px rgba(15,23,42,.04);
    --pos-gap: clamp(10px, 1.4vw, 20px);
    --pos-pad: clamp(12px, 1.8vw, 24px);
    --pos-pad-sm: clamp(10px, 1.2vw, 16px);
    --pos-input-h: clamp(42px, 4.2vw, 52px);
    --pos-content-max: min(1680px, 98vw);
    --pos-fs-base: clamp(0.875rem, 0.82rem + 0.2vw, 1.05rem);
    --pos-fs-sm: clamp(0.68rem, 0.64rem + 0.15vw, 0.78rem);
    --pos-fs-lg: clamp(1rem, 0.92rem + 0.35vw, 1.35rem);
    --pos-fs-xl: clamp(1.25rem, 1.1rem + 0.6vw, 1.85rem);
}

*, *::before, *::after { box-sizing: border-box; }

body.billing-page-body {
    font-family: var(--pos-font) !important;
    background: var(--pos-bg) !important;
    min-height: 100dvh;
    overflow-x: hidden;
    color: var(--pos-text);
    font-size: var(--pos-fs-base);
}

.billing-content {
    width: 100%;
    max-width: var(--pos-content-max);
    margin: 0 auto;
    padding: var(--pos-pad-sm);
    padding-bottom: calc(var(--pos-pad-sm) + env(safe-area-inset-bottom, 0px));
    display: flex;
    flex-direction: column;
    gap: var(--pos-gap);
    min-height: calc(100dvh - clamp(48px, 6vw, 64px));
}

/* ── Top bar ── */
.pos-topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--pos-gap);
    flex-wrap: wrap;
    background: var(--pos-surface);
    border: 1px solid var(--pos-border);
    border-radius: var(--pos-radius);
    padding: var(--pos-pad-sm) var(--pos-pad);
    box-shadow: var(--pos-shadow);
}

.pos-topbar-info h1 {
    font-size: clamp(1rem, 0.9rem + 0.4vw, 1.35rem);
    font-weight: 700;
    margin: 0;
    color: var(--pos-text);
    letter-spacing: -0.02em;
}

.pos-topbar-info p {
    margin: 2px 0 0;
    font-size: clamp(0.72rem, 0.68rem + 0.15vw, 0.88rem);
    color: var(--pos-text-secondary);
}

.bill-no-wrap { display: flex; align-items: center; flex: 0 1 auto; }

.bill-no-box {
    display: inline-flex;
    align-items: center;
    gap: clamp(6px, 0.8vw, 10px);
    background: var(--pos-primary-soft);
    border: 1px solid #bfdbfe;
    border-radius: var(--pos-radius-sm);
    padding: clamp(6px, 0.8vw, 10px) clamp(12px, 1.4vw, 18px);
    min-height: clamp(38px, 4vw, 48px);
    font-size: clamp(0.85rem, 0.8rem + 0.25vw, 1.05rem);
    font-weight: 700;
    color: var(--pos-primary-dark);
    white-space: nowrap;
}

.bill-no-box::before {
    content: 'Bill';
    font-size: var(--pos-fs-sm);
    font-weight: 600;
    color: var(--pos-text-muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
}

.bill-no-box #billNoSpan:empty::after {
    content: '—';
    margin-left: 4px;
    color: var(--pos-text-muted);
    font-weight: 500;
}

/* ── Single column: main on top, summary + buttons at bottom ── */
.pos-grid {
    display: flex;
    flex-direction: column;
    gap: var(--pos-gap);
    width: 100%;
}

.pos-main {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: var(--pos-gap);
    min-width: 0;
}

.pos-sidebar {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: var(--pos-gap);
    min-width: 0;
}

.pos-bottom-panel {
    width: 100%;
}

/* ── Panels ── */
.pos-panel {
    background: var(--pos-surface);
    border: 1px solid var(--pos-border);
    border-radius: var(--pos-radius);
    box-shadow: var(--pos-shadow);
    overflow: visible;
    width: 100%;
}

.pos-panel-body {
    padding: var(--pos-pad);
    overflow: visible;
}

.customer-fields-row {
    overflow: visible;
}

.pos-panel-head {
    display: flex;
    align-items: center;
    gap: clamp(8px, 1vw, 12px);
    padding: var(--pos-pad-sm) var(--pos-pad);
    border-bottom: 1px solid var(--pos-border);
    background: #fafbfc;
}

.pos-panel-head-icon {
    width: clamp(28px, 3vw, 36px);
    height: clamp(28px, 3vw, 36px);
    border-radius: var(--pos-radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: clamp(0.75rem, 0.7rem + 0.2vw, 0.9rem);
    flex-shrink: 0;
}

.pos-panel-head-icon.icon-customer { background: #dbeafe; color: #2563eb; }
.pos-panel-head-icon.icon-item     { background: #fef3c7; color: #d97706; }
.pos-panel-head-icon.icon-pay      { background: #d1fae5; color: #059669; }

.pos-panel-head h2 {
    font-size: var(--pos-fs-sm);
    font-weight: 700;
    margin: 0;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--pos-text);
}

.fl-input, .pay-field {
    display: flex;
    flex-direction: column;
    gap: clamp(4px, 0.5vw, 8px);
    min-width: 0;
    position: relative;
    overflow: visible;
}

/* Autocomplete dropdown — always below input */
.autocomplete-list {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    z-index: 1050;
    background: #fff;
    border: 1px solid var(--pos-border-strong);
    border-radius: var(--pos-radius-sm);
    list-style: none;
    padding: 0;
    margin: 4px 0 0 0;
    max-height: 200px;
    overflow-y: auto;
    width: 100%;
    box-shadow: 0 6px 20px rgba(15, 23, 42, 0.12);
}

.autocomplete-list li {
    padding: 10px 14px;
    cursor: pointer;
    border-bottom: 1px solid #f1f5f9;
    font-size: var(--pos-fs-base);
    color: var(--pos-text);
}

.autocomplete-list li:last-child {
    border-bottom: none;
}

.autocomplete-list li:hover,
.autocomplete-list li.autocomplete-active {
    background: var(--pos-primary-soft);
}

.field-label, .pay-label {
    font-size: var(--pos-fs-sm);
    font-weight: 600;
    color: var(--pos-text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.04em;
    margin: 0;
}

.fl-input input,
.fl-input input.form-control,
.pay-select.form-select,
.pay-select.form-control {
    height: var(--pos-input-h);
    width: 100%;
    border: 1px solid var(--pos-border-strong) !important;
    border-radius: var(--pos-radius-sm) !important;
    background: #fff !important;
    padding: 0 clamp(10px, 1.2vw, 16px) !important;
    font-family: var(--pos-font) !important;
    font-size: var(--pos-fs-base) !important;
    color: var(--pos-text) !important;
    box-shadow: none !important;
    transition: border-color .15s, box-shadow .15s;
    -webkit-appearance: none;
    appearance: none;
}

.fl-input input:focus,
.fl-input input.form-control:focus,
.pay-select.form-select:focus,
.pay-select.form-control:focus {
    border-color: var(--pos-primary) !important;
    box-shadow: 0 0 0 3px rgba(37,99,235,.12) !important;
    outline: none;
}

/* Fluid field grids */
.customer-fields-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(min(100%, 220px), 1fr));
    gap: var(--pos-gap);
}

.item-fields-row {
    display: grid;
    grid-template-columns: 1fr;
    gap: var(--pos-gap);
}

@media (min-width: 400px) {
    .item-fields-row {
        grid-template-columns: minmax(0, 2.2fr) repeat(3, minmax(0, 1fr));
        align-items: end;
    }
}

/* ── Exchange banner ── */
.ex-banner {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: var(--pos-gap);
    margin-top: var(--pos-gap);
    padding: var(--pos-pad-sm) var(--pos-pad);
    background: var(--pos-success-soft);
    border: 1px solid #a7f3d0;
    border-radius: var(--pos-radius-sm);
    font-size: var(--pos-fs-base);
    color: #065f46;
}

.ex-banner .btn-ex {
    background: var(--pos-success);
    color: #fff;
    border: none;
    border-radius: 6px;
    padding: clamp(5px, 0.6vw, 8px) clamp(10px, 1.2vw, 16px);
    font-size: var(--pos-fs-sm);
    font-weight: 600;
    cursor: pointer;
    font-family: var(--pos-font);
}

.ex-banner .btn-ex-close {
    margin-left: auto;
    background: none;
    border: none;
    font-size: clamp(1rem, 0.9rem + 0.3vw, 1.2rem);
    cursor: pointer;
    color: #065f46;
    padding: 4px 8px;
    line-height: 1;
}

/* ── Totals (compact bill summary bar) ── */
.pos-totals {
    padding: 0;
    overflow: hidden;
}

.pos-totals .pos-panel-head {
    padding: 8px 14px;
    min-height: 0;
}

.pos-totals .pos-panel-head-icon {
    width: 26px;
    height: 26px;
    font-size: 0.7rem;
}

.pos-totals .pos-panel-head h2 {
    font-size: 0.72rem;
}

.pos-totals-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1px;
    background: var(--pos-border);
    border-bottom: 1px solid var(--pos-border);
    width: 100%;
    overflow: hidden;
}

@media (min-width: 640px) {
    .pos-totals-grid {
        grid-template-columns: repeat(4, minmax(0, 1fr));
    }
}

.total-box {
    background: #fafbfc;
    padding: 6px 10px;
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(0, auto);
    align-items: center;
    gap: 6px;
    border: none;
    border-radius: 0;
    min-width: 0;
    min-height: 0;
    overflow: hidden;
}

.total-label {
    font-size: 0.62rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.03em;
    color: var(--pos-text-muted);
    margin: 0;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.total-val {
    border: none;
    background: transparent;
    text-align: right;
    font-size: clamp(0.82rem, 0.78rem + 0.15vw, 1rem);
    font-weight: 700;
    color: var(--pos-text);
    width: 100%;
    max-width: 100%;
    min-width: 0;
    padding: 0;
    outline: none;
    font-family: var(--pos-font);
    overflow: hidden;
    text-overflow: ellipsis;
}

.payable-box {
    background: linear-gradient(135deg, #1e40af 0%, #2563eb 50%, #0ea5e9 100%);
    padding: 8px 10px;
    min-width: 0;
    overflow: hidden;
}

@media (max-width: 639px) {
    .payable-box {
        grid-column: 1 / -1;
    }
}

.payable-box .total-label {
    color: rgba(255,255,255,.85);
    font-size: 0.62rem;
}

.payable-box .total-val {
    color: #fff;
    font-size: clamp(0.9rem, 0.85rem + 0.2vw, 1.15rem);
    text-align: right;
    letter-spacing: -0.02em;
}

/* Payment — horizontal row on wide screens */
.pos-payment-body {
    padding: var(--pos-pad-sm) var(--pos-pad) var(--pos-pad);
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(min(100%, 160px), 1fr));
    gap: clamp(8px, 1vw, 14px);
}

/* Action buttons — full width row at bottom */
.billing-actions {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: clamp(8px, 1vw, 12px);
    padding: var(--pos-pad-sm) var(--pos-pad) var(--pos-pad);
    border-top: 1px solid var(--pos-border);
    background: #fafbfc;
}

@media (min-width: 640px) {
    .billing-actions {
        grid-template-columns: repeat(4, 1fr);
    }
}

@media (min-width: 900px) {
    .billing-actions {
        grid-template-columns: repeat(5, 1fr);
    }
}

.btn-save, .btn-print, .btn-new, .btn-dup, .btn-add {
    height: var(--pos-input-h);
    width: 100%;
    border: none !important;
    border-radius: var(--pos-radius-sm) !important;
    font-family: var(--pos-font) !important;
    font-weight: 600 !important;
    font-size: clamp(0.75rem, 0.7rem + 0.2vw, 0.9rem) !important;
    letter-spacing: 0.02em;
    display: inline-flex !important;
    align-items: center;
    justify-content: center;
    gap: clamp(4px, 0.5vw, 8px);
    cursor: pointer;
    transition: filter .15s, transform .1s;
    -webkit-tap-highlight-color: transparent;
    touch-action: manipulation;
    white-space: nowrap;
}

.btn-save { background: var(--pos-success) !important; color: #fff !important; }
.btn-print { background: var(--pos-primary) !important; color: #fff !important; }
.btn-new {
    background: #fff !important;
    color: var(--pos-warning) !important;
    border: 1.5px solid #fcd34d !important;
}
.btn-dup {
    background: #fff !important;
    color: var(--pos-text-secondary) !important;
    border: 1.5px solid var(--pos-border-strong) !important;
}
.btn-add { background: var(--pos-primary) !important; color: #fff !important; }

.btn-save:active, .btn-print:active, .btn-new:active, .btn-dup:active, .btn-add:active {
    transform: scale(.97);
}

@media (hover: hover) {
    .btn-save:hover, .btn-print:hover { filter: brightness(1.08); }
    .btn-new:hover { background: #fffbeb !important; }
    .btn-dup:hover { background: #f8fafc !important; }
}

#quotationBtnDiv, #quotationPrintBtnDiv {
    grid-column: 1 / -1;
}

/* ── Bill table ── */
.billing-table-wrap {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
}

.bill-table {
    width: 100%;
    border-collapse: collapse;
    font-size: clamp(0.78rem, 0.74rem + 0.15vw, 0.92rem);
    min-width: min(600px, 100%);
}

.bill-table thead tr { background: #f1f5f9; }

.bill-table thead th {
    color: var(--pos-text-secondary) !important;
    font-weight: 600 !important;
    font-size: var(--pos-fs-sm) !important;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding: clamp(8px, 1vw, 12px) !important;
    border-bottom: 1px solid var(--pos-border) !important;
    background: transparent !important;
}

.bill-table tbody td {
    padding: clamp(8px, 1vw, 12px);
    color: var(--pos-text);
    border-bottom: 1px solid #f1f5f9;
    vertical-align: middle;
}

.bill-table tbody tr:hover { background: #f8fafc; }

.bill-table tbody .empty-row td {
    color: transparent;
    min-height: clamp(32px, 4vw, 40px);
    pointer-events: none;
}

/* Mobile — 16px inputs to prevent iOS zoom */
@media (max-width: 767px) {
    .fl-input input, .fl-input input.form-control,
    .pay-select.form-select, .pay-select.form-control {
        font-size: max(16px, var(--pos-fs-base)) !important;
    }
}

/* Very large screens — scale up comfortably */
@media (min-width: 1600px) {
    :root {
        --pos-content-max: min(1920px, 96vw);
    }
}

/* Landscape phones — compact */
@media (max-height: 500px) and (orientation: landscape) {
    :root {
        --pos-input-h: clamp(38px, 5vh, 44px);
        --pos-gap: clamp(6px, 1vh, 12px);
    }
    .pos-panel-body { padding: var(--pos-pad-sm); }
}

@keyframes slideIn {
    from { transform: translateX(100%); opacity: 0; }
    to   { transform: translateX(0); opacity: 1; }
}
@keyframes slideOut {
    from { transform: translateX(0); opacity: 1; }
    to   { transform: translateX(100%); opacity: 0; }
}
                                </style>
            </head>

<body class="billing-page-body">
    <!-- Navbar -->
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="billing-content">

        <!-- Top bar -->
        <header class="pos-topbar">
            <div class="pos-topbar-info">
                <h1>Point of Sale</h1>
                <p>Create &amp; manage customer bills</p>
            </div>
            <div class="bill-no-wrap">
                <div class="bill-no-box"><span id="billNoSpan"></span></div>
            </div>
        </header>

        <div class="pos-grid">

            <!-- LEFT: Customer + Item -->
            <div class="pos-main">

                <!-- Customer -->
                <section class="pos-panel">
                    <div class="pos-panel-head">
                        <div class="pos-panel-head-icon icon-customer"><i class="fas fa-user"></i></div>
                        <h2>Customer</h2>
                    </div>
                    <div class="pos-panel-body">
                        <div class="customer-fields-row">
                            <div class="fl-input">
                                <label class="field-label" for="customerName">Customer Name</label>
                                <input type="text" id="customerName" class="form-control" autocomplete="off" placeholder="Enter name">
                                <input type="hidden" id="customerId" value="0">
                                <input type="hidden" id="customerCreditLimit" value="0">
                                <input type="hidden" id="customerExchangePoint" value="0">
                                <input type="hidden" id="exchangePointUsed" value="0">
                            </div>
                            <div class="fl-input">
                                <label class="field-label" for="customerPhn">Phone Number</label>
                                <input type="text" id="customerPhn" class="form-control" autocomplete="off" placeholder="Enter phone">
                            </div>
                        </div>
                        <div id="exchangePointBanner" class="ex-banner d-none">
                            <i class="fas fa-coins"></i>
                            <strong>Exchange Points: ₹<span id="exchangePointValue">0</span></strong>
                            <button type="button" class="btn-ex" onclick="applyExchangePointDiscount()">
                                <i class="fas fa-tag me-1"></i>Use as Discount
                            </button>
                            <button type="button" class="btn-ex-close" onclick="dismissExchangePointBanner()">✕</button>
                        </div>
                    </div>
                </section>

                <!-- Item -->
                <section class="pos-panel">
                    <div class="pos-panel-head">
                        <div class="pos-panel-head-icon icon-item"><i class="fas fa-box"></i></div>
                        <h2>Item Details</h2>
                    </div>
                    <div class="pos-panel-body">
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
                        <div class="item-fields-row">
                            <div class="fl-input">
                                <label class="field-label" for="productName">Item Name</label>
                                <input type="text" id="productName" name="productName" class="form-control" placeholder="Search or enter item">
                            </div>
                            <div class="fl-input">
                                <label class="field-label" id="qtyLabel" for="productQty">Qty</label>
                                <input type="number" id="productQty" class="form-control" value="1" min="1">
                            </div>
                            <div class="fl-input">
                                <label class="field-label" for="productPrice">Price</label>
                                <input type="number" id="productPrice" class="form-control" min="0" placeholder="0">
                            </div>
                            <div class="fl-input">
                                <label class="field-label" for="productCourierFee">Courier</label>
                                <input type="text" id="productCourierFee" class="form-control only-numbers" value="0" oninput="setDefaultValue(this);">
                            </div>
                        </div>
                        <div style="display:none;">
                            <button class="btn btn-add w-100" onclick="addProduct()">
                                <i class="fas fa-plus me-1"></i>Add
                            </button>
                        </div>
                    </div>
                </section>

                <!-- Bill Items Table (hidden in single-item mode) -->
                <section class="pos-panel" style="display:none;">
                    <div class="billing-table-wrap">
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
                </section>

            </div><!-- /pos-main -->

            <!-- BOTTOM: Bill summary + payment + actions -->
            <div class="pos-sidebar">

                <section class="pos-panel pos-totals pos-bottom-panel">
                    <div class="pos-panel-head">
                        <div class="pos-panel-head-icon icon-pay"><i class="fas fa-receipt"></i></div>
                        <h2>Bill Summary</h2>
                    </div>

                    <div class="pos-totals-grid totals-row">
                        <div class="total-box">
                            <div class="total-label">Price Total</div>
                            <input type="text" class="total-val only-numbers" id="priceTotal" value="0" readonly>
                        </div>
                        <div class="total-box">
                            <div class="total-label">Courier Total</div>
                            <input type="text" class="total-val only-numbers" id="commissionTotal" value="0" readonly>
                        </div>
                        <div class="total-box">
                            <div class="total-label">Grand Total</div>
                            <input type="text" class="total-val only-numbers" id="grandTotal" value="0" readonly>
                        </div>
                        <div class="total-box payable-box">
                            <div class="total-label">Payable</div>
                            <input type="text" class="total-val only-numbers" id="payableAmount" value="0" readonly>
                        </div>
                    </div>
                    <div style="display:none;">
                        <input type="text" class="only-numbers" id="discountTotal" value="0" readonly>
                        <input type="text" class="only-numbers" id="finalDiscount" value="0" oninput="setDefaultValue(this); updatePayableAmount();">
                        <input type="text" class="only-numbers" id="courierFee" value="0" oninput="setDefaultValue(this); updatePayableAmount();">
                    </div>

                    <div class="pos-payment-body">
                        <div class="pay-field">
                            <label class="pay-label" for="mode">Payment Mode</label>
                            <select name="mode" id="mode" class="form-select pay-select">
                                <option value="1">Cash</option>
                                <option value="2" selected>Bank</option>
                                <option value="3">Mixed</option>
                            </select>
                        </div>
                        <div class="pay-field">
                            <label class="pay-label" for="type">Payment Type</label>
                            <select name="type" id="type" class="form-select pay-select">
                                <option value="1">UPI</option>
                                <option value="2">Debit Card</option>
                                <option value="3">Credit Card</option>
                                <option value="4">Net Banking</option>
                                <option value="5">Wallet</option>
                            </select>
                        </div>
                        <div class="pay-field">
                            <label class="pay-label" for="paid">Cash Paid</label>
                            <input type="text" class="form-control pay-select only-numbers" id="paid" value="0">
                        </div>
                        <div class="pay-field">
                            <label class="pay-label" for="bankPaid">Bank Paid</label>
                            <input type="text" class="form-control pay-select only-numbers" id="bankPaid" value="0">
                        </div>
                        <div class="pay-field">
                            <label class="pay-label" for="balance">Balance</label>
                            <input type="text" class="form-control pay-select only-numbers" id="balance" value="0">
                        </div>
                    </div>

                    <div class="billing-actions">
                        <button id="saveBillBtn" class="btn btn-save" onclick="saveBill()">
                            <i class="fas fa-check"></i> Save Bill
                        </button>
                        <button class="btn btn-print" onclick="printBill()" title="Direct print to thermal printer">
                            <i class="fas fa-print"></i> Print
                        </button>
                        <div id="quotationBtnDiv" style="display:none;"></div>
                        <div id="quotationPrintBtnDiv" style="display:none;"></div>
                        <button type="button" class="btn btn-new" onclick="newBill()">
                            <i class="fas fa-plus"></i> New Bill
                        </button>
                        <button class="btn btn-dup" data-bs-toggle="modal" data-bs-target="#duplicateBillModal">
                            <i class="fas fa-copy"></i> Duplicate
                        </button>
                    </div>
                </section>

            </div><!-- /pos-sidebar -->

        </div><!-- /pos-grid -->

    </div><!-- /billing-content -->

            
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