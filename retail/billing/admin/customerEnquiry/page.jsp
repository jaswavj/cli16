<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Customer Enquiry Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .cust-search-wrap { position: relative; }
        .cust-ac-list {
            position: absolute;
            z-index: 9999;
            background: #fff;
            border: 1px solid #dee2e6;
            border-top: none;
            width: 100%;
            max-height: 260px;
            overflow-y: auto;
            list-style: none;
            padding: 0;
            margin: 0;
            box-shadow: 0 6px 16px rgba(0,0,0,.12);
            border-radius: 0 0 6px 6px;
        }
        .cust-ac-list li {
            padding: 9px 14px;
            cursor: pointer;
            font-size: .88rem;
            border-bottom: 1px solid #f0f0f0;
        }
        .cust-ac-list li .cust-name { font-weight: 600; }
        .cust-ac-list li .cust-phone { font-size: .78rem; color: #6c757d; }
        .cust-ac-list li:hover, .cust-ac-list li.active {
            background: #0d6efd;
            color: #fff;
        }
        .cust-ac-list li:hover .cust-phone, .cust-ac-list li.active .cust-phone { color: #cfe2ff; }
        .clickable-customer { cursor: pointer; }
        .clickable-customer:hover { opacity: .9; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid mt-4 px-4">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <div>
                <h4 class="mb-0 fw-bold"><i class="fas fa-user-clock me-2 text-primary"></i>Customer Enquiry Report</h4>
                <small class="text-muted">Select customer by name or phone to view bill-wise enquiry details</small>
            </div>
        </div>

        <div class="card shadow-sm mb-4">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-lg-4 col-md-6">
                        <label class="form-label fw-semibold">Customer <span class="text-danger">*</span></label>
                        <div class="cust-search-wrap">
                            <input type="text" id="custSearch" class="form-control" placeholder="Type name or phone number" autocomplete="off">
                            <ul class="cust-ac-list d-none" id="custAcList"></ul>
                        </div>
                        <input type="hidden" id="custId" value="">
                        <div id="selectedCustBadge" class="mt-1"></div>
                    </div>
                    <div class="col-lg-2 col-md-3">
                        <label class="form-label fw-semibold">From Date</label>
                        <input type="date" id="fromDate" class="form-control">
                    </div>
                    <div class="col-lg-2 col-md-3">
                        <label class="form-label fw-semibold">To Date</label>
                        <input type="date" id="toDate" class="form-control">
                    </div>
                    <div class="col-lg-4 col-md-12 d-flex gap-2 flex-wrap">
                        <button id="openEnquiryBtn" class="btn btn-primary flex-fill" onclick="openCustomerEnquiry()">
                            <i class="fas fa-search me-1"></i>Open Enquiry
                        </button>
                        <button class="btn btn-outline-secondary" onclick="resetFilter()" title="Reset">
                            <i class="fas fa-undo"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <div class="card shadow-sm mb-4" id="customerEnquirySection" style="display:none;">
            <div class="card-header bg-white">
                <h6 class="mb-0 fw-semibold"><i class="fas fa-table me-1 text-primary"></i>Customer Enquiry Details</h6>
            </div>
            <div class="card-body" id="customerEnquiryContent">
                <div class="text-muted">Select customer to view enquiry details.</div>
            </div>
        </div>
    </div>

    <script>
    const ctx = '<%=ctx%>';
    let acTimer = null;
    const custAcList = document.getElementById('custAcList');
    const custSearch = document.getElementById('custSearch');

    (function() {
        const now = new Date();
        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');
        document.getElementById('toDate').value = `${y}-${m}-${d}`;
        document.getElementById('fromDate').value = `${y}-${m}-01`;
    })();

    custSearch.addEventListener('input', function() {
        clearTimeout(acTimer);
        const q = this.value.trim();
        if (q.length < 2) { hideAcList(); return; }
        acTimer = setTimeout(() => fetchCustomers(q), 280);
    });

    custSearch.addEventListener('keydown', function(e) {
        const items = custAcList.querySelectorAll('li');
        let active = custAcList.querySelector('li.active');
        if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (!active) items[0] && items[0].classList.add('active');
            else { active.classList.remove('active'); const n = active.nextElementSibling; if (n) n.classList.add('active'); }
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (active) { active.classList.remove('active'); const p = active.previousElementSibling; if (p) p.classList.add('active'); }
        } else if (e.key === 'Enter') {
            if (active) { active.click(); e.preventDefault(); }
        } else if (e.key === 'Escape') {
            hideAcList();
        }
    });

    document.addEventListener('click', function(e) {
        if (!e.target.closest('.cust-search-wrap')) hideAcList();
    });

    function fetchCustomers(q) {
        const isPhone = /^\d+$/.test(q);
        const url = isPhone
            ? ctx + '/billing/customerAutocomplete.jsp?phone=' + encodeURIComponent(q)
            : ctx + '/billing/customerAutocomplete.jsp?query=' + encodeURIComponent(q);
        fetch(url).then(r => r.json()).then(data => {
            if (!data || data.length === 0) { hideAcList(); return; }
            custAcList.innerHTML = '';
            data.forEach(function(c) {
                const li = document.createElement('li');
                li.innerHTML = `<span class="cust-name">${escHtml(c.name)}</span><span class="cust-phone ms-2">${escHtml(c.phone || '')}</span>`;
                li.addEventListener('click', function() { selectCustomer(c); });
                custAcList.appendChild(li);
            });
            custAcList.classList.remove('d-none');
        }).catch(() => hideAcList());
    }

    function selectCustomer(c) {
        document.getElementById('custId').value = c.id;
        custSearch.value = c.name + (c.phone ? ' - ' + c.phone : '');
        hideAcList();
        const badge = document.getElementById('selectedCustBadge');
        badge.innerHTML = `<span class="badge bg-success" title="Selected customer"><i class="fas fa-user me-1"></i>${escHtml(c.name)}</span>` +
            (c.phone ? ` <span class="badge bg-secondary" title="Selected phone">${escHtml(c.phone)}</span>` : '');
    }

    function hideAcList() {
        custAcList.classList.add('d-none');
        custAcList.innerHTML = '';
    }

    function openCustomerEnquiry() {
        const customerId = document.getElementById('custId').value.trim();
        const fromDate = document.getElementById('fromDate').value;
        const toDate = document.getElementById('toDate').value;
        if (!customerId) {
            Swal.fire('Select Customer', 'Please select a customer first.', 'warning');
            return;
        }

        const enquirySection = document.getElementById('customerEnquirySection');
        enquirySection.style.display = '';
        document.getElementById('customerEnquiryContent').innerHTML =
            '<div class="text-center py-5"><div class="spinner-border text-primary" role="status"></div></div>';

        fetch(ctx + '/admin/customerEnquiry/getCustomerEnquiry.jsp?customerId=' + encodeURIComponent(customerId) +
            '&fromDate=' + encodeURIComponent(fromDate) + '&toDate=' + encodeURIComponent(toDate))
            .then(r => r.json())
            .then(data => {
                if (data.error) {
                    document.getElementById('customerEnquiryContent').innerHTML =
                        `<div class="alert alert-danger">${escHtml(data.error)}</div>`;
                    return;
                }

                const rows = data.rows || [];
                if (!rows.length) {
                    document.getElementById('customerEnquiryContent').innerHTML =
                        '<div class="alert alert-info mb-0">No bills found for this customer in the selected date range.</div>';
                    return;
                }

                let html = '<div class="table-responsive">';
                html += '<table class="table table-bordered table-sm align-middle mb-0">';
                html += '<thead class="table-light"><tr>' +
                    '<th>#</th><th>Bill</th><th>Order Date</th><th>Item Name</th><th class="text-end">Price</th>' +
                    '<th class="text-end">Courier</th><th class="text-end">Paid</th>' +
                    '<th>Download</th><th>Download Date</th><th class="text-end">Photo Count</th>' +
                    '<th>Delivery Date</th><th>Delivered Date</th><th>Order User</th><th>Payment Summary</th>' +
                    '</tr></thead><tbody>';

                rows.forEach((r, i) => {
                    html += '<tr>' +
                        `<td>${i + 1}</td>` +
                        `<td><span class="badge bg-primary">${escHtml(r.billNo || '-')}</span></td>` +
                        `<td>${escHtml((r.date || '-') + (r.time ? (' ' + r.time) : ''))}</td>` +
                        `<td>${escHtml(r.itemNames || '-')}</td>` +
                        `<td class="text-end">${fmt(r.priceTotal || 0)}</td>` +
                        `<td class="text-end">${fmt(r.courierTotal || 0)}</td>` +
                        `<td class="text-end fw-semibold">${fmt(r.totalPaid || 0)}</td>` +
                        `<td>${Number(r.isDownloaded || 0) === 1 ? '<span class="badge bg-success">Yes</span>' : '<span class="badge bg-secondary">No</span>'}</td>` +
                        `<td>${escHtml(r.downloadDate || '-')}</td>` +
                        `<td class="text-end">${fmt(r.photoCount || 0)}</td>` +
                        `<td>${escHtml(r.deliveryDate || '-')}</td>` +
                        `<td>${escHtml(r.deliveredDate || '-')}</td>` +
                        `<td>${escHtml(r.orderUser || '-')}</td>` +
                        `<td><button class="btn btn-sm btn-outline-primary pay-sum-btn" data-bill="${escHtml(r.billNo || '-')}">View</button></td>` +
                        '</tr>';
                });

                html += '</tbody></table></div>';
                document.getElementById('customerEnquiryContent').innerHTML = html;

                document.querySelectorAll('.pay-sum-btn').forEach((btn, idx) => {
                    const row = rows[idx];
                    btn.addEventListener('click', function() {
                        openPaymentSummary(btn.getAttribute('data-bill') || '-');
                    });
                });
            })
            .catch(() => {
                document.getElementById('customerEnquiryContent').innerHTML =
                    '<div class="alert alert-danger mb-0">Failed to load customer enquiry details.</div>';
            });
    }

    function openPaymentSummary(billNo) {
        const modal = new bootstrap.Modal(document.getElementById('paymentSummaryModal'));
        document.getElementById('paySummaryBody').innerHTML =
            '<div class="text-center py-3"><div class="spinner-border spinner-border-sm text-primary" role="status"></div></div>';
        modal.show();

        fetch(ctx + '/admin/customerEnquiry/getPaymentSummary.jsp?billNo=' + encodeURIComponent(billNo || ''))
            .then(r => r.json())
            .then(data => {
                if (data.error) {
                    document.getElementById('paySummaryBody').innerHTML = `<div class="alert alert-danger mb-0">${escHtml(data.error)}</div>`;
                    return;
                }

                const rows = data.rows || [];
                let html = `<div class="mb-2"><strong>Bill No:</strong> ${escHtml(data.billNo || billNo || '-')}</div>`;

                if (!rows.length) {
                    html += '<div class="alert alert-info mb-0">No payment summary available.</div>';
                    document.getElementById('paySummaryBody').innerHTML = html;
                    return;
                }

                html += '<div class="table-responsive"><table class="table table-bordered table-sm mb-2">';
                html += '<thead class="table-light"><tr><th>Date</th><th>Mode</th><th>Method</th><th class="text-end">Paid</th><th class="text-end">Balance</th></tr></thead><tbody>';
                rows.forEach((r) => {
                    html += '<tr>' +
                        `<td>${escHtml(r.date || '-')}</td>` +
                        `<td>${escHtml(r.mode || '-')}</td>` +
                        `<td>${escHtml(r.method || '-')}</td>` +
                        `<td class="text-end">${fmt(r.paid || 0)}</td>` +
                        `<td class="text-end">${fmt(r.balance || 0)}</td>` +
                        '</tr>';
                });
                html += '</tbody></table></div>';
                html += `<div class="text-end fw-semibold">Total Paid: ${fmt(data.totalPaid || 0)}</div>`;

                document.getElementById('paySummaryBody').innerHTML = html;
            })
            .catch(() => {
                document.getElementById('paySummaryBody').innerHTML = '<div class="alert alert-danger mb-0">Failed to load payment summary.</div>';
            });
    }

    function resetFilter() {
        document.getElementById('custId').value = '';
        custSearch.value = '';
        document.getElementById('selectedCustBadge').innerHTML = '';
        document.getElementById('customerEnquirySection').style.display = 'none';
        document.getElementById('customerEnquiryContent').innerHTML = '<div class="text-muted">Select customer to view enquiry details.</div>';
        const now = new Date();
        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');
        document.getElementById('toDate').value = `${y}-${m}-${d}`;
        document.getElementById('fromDate').value = `${y}-${m}-01`;
    }

    function fmt(n) {
        const v = parseFloat(n);
        if (isNaN(v)) return '0.00';
        return v.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function escHtml(s) {
        if (s == null) return '';
        return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
    </script>

    <div class="modal fade" id="paymentSummaryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-md modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Payment Summary</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="paySummaryBody"></div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
