<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="users" class="user.userBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

Vector vecPer = users.getUserPermission(uid);
Set<Integer> permissions = new HashSet<Integer>();
for (int i = 0; i < vecPer.size(); i++) {
    Vector cat = (Vector) vecPer.get(i);
    int modId = Integer.parseInt(cat.elementAt(0).toString());
    permissions.add(modId);
}

if (!permissions.contains(2)) {
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Pending List</title>
    <jsp:include page="/assets/common/head.jsp" />
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />
    <div class="container-fluid p-3">
        <div class="alert alert-danger">You do not have permission to access this page.</div>
    </div>
</body>
</html>
<%
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Order List - Pending</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        .pending-wrap { padding: 10px; }
        .pending-card { background: #fff; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
        .pending-title { font-size: 1.3rem; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; color: #444; }
        #pendingTable th { font-size: 1.08rem; font-weight: 700; white-space: nowrap; }
        #pendingTable td { font-size: 1.05rem; vertical-align: middle; }
        .pending-card .form-label { font-size: 1.12rem; font-weight: 500; }
        .pending-card .form-control,
        .pending-card .form-select { font-size: 1.08rem; }
        .pending-card .btn,
        .pending-card .btn-sm { font-size: 1rem; }
        .modal .modal-title { font-size: 1.35rem; font-weight: 700; }
        .modal .modal-body,
        .modal .modal-body .form-label,
        .modal .modal-body .form-check-label,
        .modal .modal-body .small,
        .modal .modal-body div,
        .modal .modal-body span { font-size: 1.12rem; }
        .modal .modal-body .form-control,
        .modal .modal-body .form-select,
        .modal .modal-body textarea { font-size: 1.1rem; }
        .modal .modal-footer .btn { font-size: 1.12rem; }
        .click-row { cursor: pointer; }
        .click-row:hover > td { background: #f7f7fb; }
        .delivery-alert-row > td { background: #fdeaea !important; }
        .delivery-alert-row:hover > td { background: #f9dede !important; }

        @media (max-width: 768px) {
            .pending-title { font-size: 1.15rem; }
            #pendingTable th { font-size: 0.98rem; }
            #pendingTable td { font-size: 0.96rem; }
            .pending-card .form-label { font-size: 1rem; }
            .pending-card .form-control,
            .pending-card .form-select { font-size: 1rem; }
            .modal .modal-title { font-size: 1.2rem; }
            .modal .modal-body,
            .modal .modal-body .form-label,
            .modal .modal-body .form-check-label,
            .modal .modal-body .small,
            .modal .modal-body div,
            .modal .modal-body span { font-size: 1rem; }
        }
    </style>
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="pending-wrap">
        <div class="pending-card p-3">
            <div class="d-flex justify-content-between align-items-center mb-2">
                <div class="pending-title">Pending List </div>
                <button class="btn btn-sm btn-primary" onclick="loadPendingBills()">
                    <i class="fas fa-rotate"></i> Refresh
                </button>
            </div>

            <div class="row g-2 mb-3">
                <div class="col-12 col-md-4">
                    <label class="form-label mb-1">Customer Name</label>
                    <input type="text" id="filterCustomerName" class="form-control form-control-sm" placeholder="Search by customer name">
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label mb-1">Phone Number</label>
                    <input type="text" id="filterPhone" class="form-control form-control-sm" placeholder="Search by phone number">
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label mb-1">Downloaded</label>
                    <select id="filterDownloaded" class="form-select form-select-sm">
                        <option value="">All</option>
                        <option value="1">Yes</option>
                        <option value="0">No</option>
                    </select>
                </div>
                <div class="col-12 col-md-1 d-flex align-items-end">
                    <button class="btn btn-outline-secondary btn-sm w-100" type="button" onclick="clearFilters()">Clear</button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-bordered table-hover mb-0" id="pendingTable">
                    <thead class="table-light">
                        <tr>
                            <th>Bill No</th>
                            <th>Delivery</th>
                            <th>Date</th>
                            <th>Time</th>
                            <th>Customer</th>
                            <th>Phone</th>
                            <th>Payable</th>
                            <th>Delivery Date</th>
                            <th>Downloaded</th>
                            <th>Photos</th>
                            <th>Download Date</th>
                        </tr>
                    </thead>
                    <tbody id="pendingBody">
                        <tr><td colspan="10" class="text-center text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="modal fade" id="pendingEditModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">Update Pending Bill</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="editBillId">
                    <div class="mb-2"><strong>Bill No:</strong> <span id="editBillNo">-</span></div>
                    <div class="mb-3">
                        <label class="form-label">Items</label>
                        <div id="pendingItemsWrap" class="border rounded p-2" style="max-height: 180px; overflow-y: auto; background:#fafafa;">
                            <div id="pendingItemsList" class="small text-muted">Loading items...</div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label for="editDeliveryDate" class="form-label">Delivery Date</label>
                        <input type="date" id="editDeliveryDate" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label for="editDescription" class="form-label">Description</label>
                        <textarea id="editDescription" class="form-control" rows="3" readonly placeholder="No description"></textarea>
                    </div>
                    <div class="form-check mb-2">
                        <input class="form-check-input" type="checkbox" id="editDownloaded" onchange="togglePhotoCount(this)">
                        <label class="form-check-label" for="editDownloaded">Downloaded</label>
                    </div>
                    <div class="small text-muted">When checked, download date will be saved as today.</div>
                    <div class="mb-3 mt-2">
                        <label for="editPhotoCount" class="form-label">Photos Count</label>
                        <input type="number" id="editPhotoCount" class="form-control" min="0" placeholder="Enter photos count" disabled>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-success" onclick="updatePendingBill()">Update</button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="deliveryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title">Mark Delivery</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="deliveryBillId">
                    <div class="mb-2"><strong>Bill No:</strong> <span id="deliveryBillNo">-</span></div>
                    <div class="mb-3">
                        <label for="deliveryPlace" class="form-label">Delivery Place</label>
                        <input type="text" id="deliveryPlace" class="form-control" placeholder="Enter delivery place">
                    </div>
                    <div class="mb-3">
                        <label for="deliveryDateInput" class="form-label">Delivered Date</label>
                        <input type="date" id="deliveryDateInput" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label for="deliveryPerson" class="form-label">Delivery Person</label>
                        <input type="text" id="deliveryPerson" class="form-control" placeholder="Enter delivery person">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-warning" onclick="saveDeliveryDetails()">Save Delivery</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let pendingModal;
        let deliveryModal;
        let allPendingBills = [];
        let hasShownDeliveryAlert = false;

        function escapeHtml(str) {
            return (str || '').replace(/[&<>'\"]/g, function (c) {
                return {'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;','\'':'&#39;'}[c] || c;
            });
        }

        function getDaysUntilDelivery(dateStr) {
            if (!dateStr) {
                return null;
            }

            const today = new Date();
            today.setHours(0, 0, 0, 0);

            const cleanDate = String(dateStr).trim().split(' ')[0];
            const parts = cleanDate.split('-');
            if (parts.length !== 3) {
                return null;
            }

            const year = parseInt(parts[0], 10);
            const month = parseInt(parts[1], 10) - 1;
            const day = parseInt(parts[2], 10);
            const delivery = new Date(year, month, day);
            if (isNaN(delivery.getTime())) {
                return null;
            }

            const msPerDay = 24 * 60 * 60 * 1000;
            return Math.ceil((delivery.getTime() - today.getTime()) / msPerDay);
        }

        function getUrgentBills(items) {
            return (items || []).filter(function(b) {
                const daysUntilDelivery = getDaysUntilDelivery(b.deliveryDate);
                return daysUntilDelivery !== null && daysUntilDelivery < 3;
            });
        }

        function showDeliveryAlert(items) {
            if (hasShownDeliveryAlert) {
                return;
            }

            const urgentBills = getUrgentBills(items);
            if (!urgentBills.length) {
                return;
            }

            hasShownDeliveryAlert = true;

            let html = '<div style="text-align:left">';
            urgentBills.forEach(function(b) {
                html += '<div style="padding:6px 0;border-bottom:1px solid #eee;">' +
                        '<div><strong>' + escapeHtml(b.customerName || '-') + '</strong></div>' +
                        '<div>Phone: ' + escapeHtml(b.customerPhone || '-') + '</div>' +
                        '<div>Delivery Date: ' + escapeHtml(b.deliveryDate || '-') + '</div>' +
                        '</div>';
            });
            html += '</div>';

            Swal.fire({
                icon: 'warning',
                title: 'Delivery Due Alert',
                html: html,
                confirmButtonText: 'OK'
            });
        }

        function loadPendingBills(showAlert) {
            fetch('../getPendingDeliveryBills.jsp')
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    allPendingBills = Array.isArray(data) ? data : [];
                    renderPendingBills(allPendingBills);
                    if (showAlert === true) {
                        showDeliveryAlert(allPendingBills);
                    }
                })
                .catch(function() {
                    document.getElementById('pendingBody').innerHTML = '<tr><td colspan="11" class="text-center text-danger">Failed to load data.</td></tr>';
                });
        }

        function renderPendingBills(items) {
            const tbody = document.getElementById('pendingBody');
            tbody.innerHTML = '';

            if (!Array.isArray(items) || items.length === 0) {
                tbody.innerHTML = '<tr><td colspan="11" class="text-center text-muted">No pending bills found.</td></tr>';
                return;
            }

            items.forEach(function(b) {
                const tr = document.createElement('tr');
                tr.className = 'click-row';
                const daysUntilDelivery = getDaysUntilDelivery(b.deliveryDate);
                if (daysUntilDelivery !== null && daysUntilDelivery < 3) {
                    tr.classList.add('delivery-alert-row');
                }
                tr.innerHTML =
                    '<td>' + escapeHtml(b.billNo) + '</td>' +
                    '<td><button type="button" class="btn btn-sm btn-warning delivery-btn"><i class="fas fa-truck"></i> Delivery</button></td>' +
                    '<td>' + escapeHtml(b.date) + '</td>' +
                    '<td>' + escapeHtml(b.time) + '</td>' +
                    '<td>' + escapeHtml(b.customerName) + '</td>' +
                    '<td>' + (function(p) { var d = (p || '').replace(/\D/g,''); return d ? '<a href="https://wa.me/91' + d + '" target="_blank" title="Chat on WhatsApp" style="color:#25D366;text-decoration:none;"><i class="fab fa-whatsapp me-1"></i>' + escapeHtml(p) + '</a>' : escapeHtml(p || '-'); })(b.customerPhone) + '</td>' +
                    '<td>₹' + Number(b.payable || 0).toFixed(3) + '</td>' +
                    '<td>' + (b.deliveryDate ? escapeHtml(b.deliveryDate) : '-') + '</td>' +
                    '<td>' + (Number(b.isDownloaded) === 1 ? '<span class="badge bg-success">Yes</span>' : '<span class="badge bg-secondary">No</span>') + '</td>' +
                    '<td>' + (Number(b.isDownloaded) === 1 && b.photoCount ? escapeHtml(String(b.photoCount)) : '-') + '</td>' +
                    '<td>' + (b.downloadDate ? escapeHtml(b.downloadDate) : '-') + '</td>';

                tr.addEventListener('click', function() {
                    openPendingModal(b);
                });
                const deliveryBtn = tr.querySelector('.delivery-btn');
                if (deliveryBtn) {
                    deliveryBtn.addEventListener('click', function(event) {
                        event.stopPropagation();
                        openDeliveryModal(b);
                    });
                }
                tbody.appendChild(tr);
            });
        }

        function applyFilters() {
            const nameFilter = (document.getElementById('filterCustomerName').value || '').trim().toLowerCase();
            const phoneFilter = (document.getElementById('filterPhone').value || '').trim().toLowerCase();
            const downloadedFilter = document.getElementById('filterDownloaded').value;

            const filtered = allPendingBills.filter(function(b) {
                const customerName = (b.customerName || '').toLowerCase();
                const customerPhone = (b.customerPhone || '').toLowerCase();
                const isDownloaded = String(Number(b.isDownloaded) === 1 ? 1 : 0);

                const nameOk = !nameFilter || customerName.indexOf(nameFilter) !== -1;
                const phoneOk = !phoneFilter || customerPhone.indexOf(phoneFilter) !== -1;
                const downloadedOk = !downloadedFilter || isDownloaded === downloadedFilter;

                return nameOk && phoneOk && downloadedOk;
            });

            renderPendingBills(filtered);
        }

        function clearFilters() {
            document.getElementById('filterCustomerName').value = '';
            document.getElementById('filterPhone').value = '';
            document.getElementById('filterDownloaded').value = '';
            renderPendingBills(allPendingBills);
        }

        function openDeliveryModal(bill) {
            document.getElementById('deliveryBillId').value = bill.id;
            document.getElementById('deliveryBillNo').textContent = bill.billNo || '-';
            document.getElementById('deliveryPlace').value = bill.deliveryPlace || '';
            const today = new Date();
            const yyyy = today.getFullYear();
            const mm = String(today.getMonth() + 1).padStart(2, '0');
            const dd = String(today.getDate()).padStart(2, '0');
            document.getElementById('deliveryDateInput').value = bill.deliveredDate || (yyyy + '-' + mm + '-' + dd);
            document.getElementById('deliveryPerson').value = bill.deliveryPerson || '';
            deliveryModal.show();
        }

        function togglePhotoCount(chk) {
            const el = document.getElementById('editPhotoCount');
            el.disabled = !chk.checked;
            if (!chk.checked) el.value = '';
        }

        function openPendingModal(bill) {
            document.getElementById('editBillId').value = bill.id;
            document.getElementById('editBillNo').textContent = bill.billNo || '-';
            document.getElementById('editDeliveryDate').value = bill.deliveryDate || '';
            document.getElementById('editDescription').value = bill.description || bill.discription || '';
            const downloaded = Number(bill.isDownloaded) === 1;
            document.getElementById('editDownloaded').checked = downloaded;
            const photoEl = document.getElementById('editPhotoCount');
            photoEl.disabled = !downloaded;
            photoEl.value = (bill.photoCount != null && bill.photoCount !== '') ? bill.photoCount : '';
            document.getElementById('pendingItemsList').innerHTML = 'Loading items...';
            loadPendingBillItems(bill.id);
            pendingModal.show();
        }

        function loadPendingBillItems(billId) {
            fetch('../getPendingBillItems.jsp?billId=' + encodeURIComponent(billId))
                .then(function(r) { return r.json(); })
                .then(function(items) {
                    const el = document.getElementById('pendingItemsList');
                    if (!Array.isArray(items) || items.length === 0) {
                        el.innerHTML = '<span class="text-muted">No items found.</span>';
                        return;
                    }

                    let html = '<ol class="mb-0 ps-3">';
                    items.forEach(function(it) {
                        const name = escapeHtml(it.itemName || '-');
                        html += '<li><span class="fw-semibold">' + name + '</span></li>';
                    });
                    html += '</ol>';
                    el.innerHTML = html;
                })
                .catch(function() {
                    document.getElementById('pendingItemsList').innerHTML = '<span class="text-danger">Failed to load items.</span>';
                });
        }

        function updatePendingBill() {
            const billId = document.getElementById('editBillId').value;
            const deliveryDate = document.getElementById('editDeliveryDate').value;
            const isDownloaded = document.getElementById('editDownloaded').checked ? 1 : 0;
            const photoCountVal = document.getElementById('editPhotoCount').value.trim();
            const photoCount = (isDownloaded && photoCountVal !== '') ? parseInt(photoCountVal, 10) : 0;

            const body = new URLSearchParams();
            body.append('billId', billId);
            body.append('deliveryDate', deliveryDate);
            body.append('isDownloaded', isDownloaded);
            body.append('photoCount', photoCount);

            fetch('updatePendingDelivery.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body.toString()
            })
            .then(function(r) { return r.json(); })
            .then(function(res) {
                if (res.success) {
                    pendingModal.hide();
                    loadPendingBills(false);
                    Swal.fire({ icon: 'success', title: 'Updated', text: 'Pending bill updated successfully.' });
                } else {
                    Swal.fire({ icon: 'error', title: 'Update Failed', text: res.message || 'Failed to update.' });
                }
            })
            .catch(function() {
                Swal.fire({ icon: 'error', title: 'Error', text: 'Server error while updating.' });
            });
        }

        function saveDeliveryDetails() {
            const billId = document.getElementById('deliveryBillId').value;
            const deliveryPlace = document.getElementById('deliveryPlace').value.trim();
            const deliveredDate = document.getElementById('deliveryDateInput').value;
            const deliveryPerson = document.getElementById('deliveryPerson').value.trim();

            const body = new URLSearchParams();
            body.append('billId', billId);
            body.append('deliveryPlace', deliveryPlace);
            body.append('deliveredDate', deliveredDate);
            body.append('deliveryPerson', deliveryPerson);

            fetch('markDelivered.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body.toString()
            })
            .then(function(r) { return r.json(); })
            .then(function(res) {
                if (res.success) {
                    deliveryModal.hide();
                    loadPendingBills(false);
                    Swal.fire({ icon: 'success', title: 'Delivered', text: 'Delivery details saved successfully.' });
                } else {
                    Swal.fire({ icon: 'error', title: 'Update Failed', text: res.message || 'Failed to save delivery.' });
                }
            })
            .catch(function() {
                Swal.fire({ icon: 'error', title: 'Error', text: 'Server error while saving delivery.' });
            });
        }

        document.addEventListener('DOMContentLoaded', function() {
            pendingModal = new bootstrap.Modal(document.getElementById('pendingEditModal'));
            deliveryModal = new bootstrap.Modal(document.getElementById('deliveryModal'));
            document.getElementById('filterCustomerName').addEventListener('input', applyFilters);
            document.getElementById('filterPhone').addEventListener('input', applyFilters);
            document.getElementById('filterDownloaded').addEventListener('change', applyFilters);

            // Keep sidebar closed by default when this page loads.
            const sidebar = document.getElementById('sidebar');
            const sidebarOverlay = document.getElementById('sidebarOverlay');
            const mobile = window.innerWidth <= 768;
            if (sidebar) {
                sidebar.classList.remove('show');
                if (!mobile) {
                    sidebar.classList.add('hidden');
                }
            }
            if (sidebarOverlay) {
                sidebarOverlay.classList.remove('show');
            }
            document.body.classList.remove('sidebar-open');
            if (!mobile) {
                document.body.classList.add('sidebar-hidden');
            }

            loadPendingBills(true);
        });
    </script>
</body>
</html>
