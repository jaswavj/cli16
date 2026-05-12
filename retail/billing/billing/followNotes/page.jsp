<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Follow Notes</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        .main-content {
            margin-left: 0;
            width: 100%;
            max-width: none;
            box-sizing: border-box;
            padding: 1.5rem;
        }
        @media (max-width: 768px) {
            .main-content {
                margin-left: 0;
                width: 100%;
                padding: 1rem;
                padding-top: 70px;
            }
        }

        .autocomplete-wrapper { position: relative; }
        .autocomplete-list {
            position: absolute; z-index: 1050;
            background: white; border: 1px solid #dee2e6;
            list-style: none; padding: 0; margin: 0;
            max-height: 200px; overflow-y: auto; width: 100%;
            border-radius: 0.375rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.12);
        }
        .autocomplete-list li {
            padding: 8px 14px; cursor: pointer;
            border-bottom: 1px solid #f0f0f0; font-size: 0.88rem;
        }
        .autocomplete-list li:hover { background: #e8f0fe; }

        .open-row td { background-color: #fff8e1 !important; }
        .badge-open  { background: #ff9800; color: #fff; padding: 3px 8px; border-radius: 10px; font-size: 0.78rem; }
        .badge-closed{ background: #4caf50; color: #fff; padding: 3px 8px; border-radius: 10px; font-size: 0.78rem; }

        .page-title { font-size: 1.4rem; font-weight: 700; color: #3d3d3d; }
        .card { border: none; border-radius: 12px; }
        .card-header { background: linear-gradient(135deg, #f7fafc, #edf2f7); border-radius: 12px 12px 0 0 !important; border-bottom: 1px solid #e2e8f0; padding: 0.85rem 1rem; }
        .table thead th { font-weight: 600; color: #4a5568; font-size: 0.83rem; }
    </style>
</head>
<body>
<div class="container-fluid p-0">
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="main-content">
        <div class="page-title mb-4">
            <i class="fas fa-notes-medical me-2 text-primary"></i>Follow Note Entry
        </div>

        <!-- Entry Form -->
        <div class="card shadow-sm mb-4">
            <div class="card-header">
                <i class="fas fa-plus-circle me-2 text-primary"></i>New Follow Note
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-5 col-lg-4">
                        <label class="form-label fw-semibold">Customer Name</label>
                        <div class="autocomplete-wrapper">
                            <input type="text" id="customerName" class="form-control"
                                   placeholder="Type customer name..." autocomplete="off">
                            <input type="hidden" id="customerId" value="0">
                        </div>
                    </div>
                    <div class="col-md-4 col-lg-3">
                        <label class="form-label fw-semibold">Phone Number</label>
                        <div class="autocomplete-wrapper">
                            <input type="text" id="customerPhn" class="form-control"
                                   placeholder="Phone number..." autocomplete="off">
                        </div>
                    </div>
                    <div class="col-12">
                        <label class="form-label fw-semibold">Description / Notes</label>
                        <textarea id="description" class="form-control" rows="3"
                                  placeholder="Enter follow-up notes..."></textarea>
                    </div>
                    <div class="col-12">
                        <button class="btn btn-primary px-4" id="saveBtn" onclick="saveNote()">
                            <i class="fas fa-save me-1"></i> Save Note
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Notes List -->
        <div class="card shadow-sm">
            <div class="card-header d-flex align-items-center justify-content-between flex-wrap gap-2">
                <span class="fw-semibold"><i class="fas fa-list me-2"></i>Follow Notes List</span>
                <div class="d-flex gap-2 flex-wrap">
                    <input type="text" id="filterName" class="form-control form-control-sm"
                           placeholder="Filter by name / phone..." onkeyup="filterNotes()" style="width:200px;">
                    <select id="filterStatus" class="form-select form-select-sm" onchange="filterNotes()" style="width:130px;">
                        <option value="">All</option>
                        <option value="open" selected>Open</option>
                        <option value="closed">Closed</option>
                    </select>
                    <button class="btn btn-sm btn-outline-secondary" onclick="loadNotes()">
                        <i class="fas fa-sync-alt"></i>
                    </button>
                </div>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="notesTable">
                        <thead class="table-light">
                            <tr>
                                <th style="width:45px;">S.No</th>
                                <th>Customer</th>
                                <th>Phone</th>
                                <th>Description</th>
                                <th>Date &amp; Time</th>
                                <th>Added By</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="notesTbody">
                            <tr><td colspan="8" class="text-center text-muted py-4">
                                <i class="fas fa-spinner fa-spin me-2"></i>Loading...
                            </td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const contextPath = '<%=contextPath%>';
let customerAutocompleteTimeout, phoneAutocompleteTimeout;
let allNotes = [];
let saveBtnBlocked = false;

// ---- Customer Name Autocomplete ----
document.getElementById('customerName').addEventListener('input', function () {
    const q = this.value.trim();
    clearTimeout(customerAutocompleteTimeout);
    removeDropdown('nameDropdown');
    document.getElementById('customerId').value = '0';
    saveBtnBlocked = false;
    document.getElementById('saveBtn').disabled = false;
    if (q.length < 2) return;
    customerAutocompleteTimeout = setTimeout(() => {
        fetch(contextPath + '/billing/customerAutocomplete.jsp?query=' + encodeURIComponent(q))
            .then(r => r.json())
            .then(data => showDropdown('nameDropdown', document.getElementById('customerName'), data, selectCustomer))
            .catch(() => {});
    }, 300);
});

// ---- Phone Autocomplete ----
document.getElementById('customerPhn').addEventListener('input', function () {
    const q = this.value.trim();
    clearTimeout(phoneAutocompleteTimeout);
    removeDropdown('phoneDropdown');
    document.getElementById('customerId').value = '0';
    saveBtnBlocked = false;
    document.getElementById('saveBtn').disabled = false;
    if (q.length < 3) return;
    phoneAutocompleteTimeout = setTimeout(() => {
        fetch(contextPath + '/billing/customerAutocomplete.jsp?phone=' + encodeURIComponent(q))
            .then(r => r.json())
            .then(data => showDropdown('phoneDropdown', document.getElementById('customerPhn'), data, selectCustomer))
            .catch(() => {});
    }, 300);
});

function showDropdown(dropId, inputEl, customers, onSelect) {
    removeDropdown(dropId);
    if (!customers || customers.length === 0) return;
    const list = document.createElement('ul');
    list.className = 'autocomplete-list';
    list.id = dropId;
    customers.forEach(c => {
        const li = document.createElement('li');
        li.textContent = c.name + (c.phone && c.phone !== '-' ? ' \u2014 ' + c.phone : '');
        li.addEventListener('mousedown', e => { e.preventDefault(); onSelect(c); removeDropdown(dropId); });
        list.appendChild(li);
    });
    inputEl.parentElement.appendChild(list);
}

function removeDropdown(dropId) {
    const old = document.getElementById(dropId);
    if (old) old.remove();
}

document.addEventListener('click', function (e) {
    if (!e.target.closest('.autocomplete-wrapper')) {
        removeDropdown('nameDropdown');
        removeDropdown('phoneDropdown');
    }
});

function selectCustomer(c) {
    document.getElementById('customerName').value = c.name;
    document.getElementById('customerPhn').value = (c.phone && c.phone !== '-') ? c.phone : '';
    document.getElementById('customerId').value = c.id;
    removeDropdown('nameDropdown');
    removeDropdown('phoneDropdown');
    checkOpenNote(c.id);
}

function checkOpenNote(customerId) {
    if (!customerId || customerId == '0') return;
    fetch('checkOpenNote.jsp?customerId=' + encodeURIComponent(customerId))
        .then(r => r.json())
        .then(data => {
            if (data.hasOpen) {
                saveBtnBlocked = true;
                document.getElementById('saveBtn').disabled = true;
                Swal.fire({
                    icon: 'warning',
                    title: 'Already Being Followed',
                    html: '<div class="text-start">' +
                          '<p class="mb-2"><b>' + escHtml(data.userName || 'A user') + '</b> is already following this customer.</p>' +
                          '<div class="p-2 bg-light rounded border"><i class="fas fa-sticky-note me-1 text-warning"></i><b>Note:</b><br>' +
                          escHtml(data.description || '') + '</div>' +
                          '<p class="mt-2 mb-0 text-muted small">Please close the existing note before adding a new one.</p>' +
                          '</div>',
                    confirmButtonText: 'OK'
                });
            } else {
                saveBtnBlocked = false;
                document.getElementById('saveBtn').disabled = false;
            }
        })
        .catch(() => {});
}

function escHtml(t) {
    return String(t)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

function saveNote() {
    if (saveBtnBlocked) return;
    const customerName = document.getElementById('customerName').value.trim();
    const customerPhn  = document.getElementById('customerPhn').value.trim();
    const customerId   = document.getElementById('customerId').value || '0';
    const description  = document.getElementById('description').value.trim();

    if (!customerName) {
        Swal.fire({ icon: 'warning', title: 'Required', text: 'Please enter customer name.' });
        return;
    }
    if (!customerPhn) {
        Swal.fire({ icon: 'warning', title: 'Required', text: 'Please enter phone number.' });
        return;
    }
    if (!description) {
        Swal.fire({ icon: 'warning', title: 'Required', text: 'Please enter a description / note.' });
        return;
    }

    const btn = document.getElementById('saveBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i> Saving...';

    fetch('saveFollowNote.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'customerName=' + encodeURIComponent(customerName) +
              '&customerPhn='  + encodeURIComponent(customerPhn)  +
              '&customerId='   + encodeURIComponent(customerId)   +
              '&description='  + encodeURIComponent(description)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            Swal.fire({ icon: 'success', title: 'Saved', text: 'Follow note saved successfully.',
                        timer: 1500, showConfirmButton: false });
            document.getElementById('customerName').value = '';
            document.getElementById('customerPhn').value  = '';
            document.getElementById('customerId').value   = '0';
            document.getElementById('description').value  = '';
            saveBtnBlocked = false;
            loadNotes();
        } else {
            Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Failed to save note.' });
        }
    })
    .catch(() => Swal.fire({ icon: 'error', title: 'Error', text: 'Request failed. Please try again.' }))
    .finally(() => {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save me-1"></i> Save Note';
    });
}

function loadNotes() {
    fetch('getFollowNotes.jsp')
        .then(r => r.json())
        .then(data => { allNotes = data; filterNotes(); })
        .catch(() => {
            document.getElementById('notesTbody').innerHTML =
                '<tr><td colspan="8" class="text-center text-danger py-4">Failed to load notes.</td></tr>';
        });
}

function filterNotes() {
    const nameFilter   = document.getElementById('filterName').value.toLowerCase();
    const statusFilter = document.getElementById('filterStatus').value;

    const filtered = allNotes.filter(n => {
        const nameMatch = !nameFilter ||
            (n.customerName && n.customerName.toLowerCase().includes(nameFilter)) ||
            (n.customerPhone && n.customerPhone.toLowerCase().includes(nameFilter));
        let statusMatch = true;
        if (statusFilter === 'open')   statusMatch = (n.isClosed == 0);
        if (statusFilter === 'closed') statusMatch = (n.isClosed == 1);
        return nameMatch && statusMatch;
    });
    renderNotes(filtered);
}

function renderNotes(notes) {
    const tbody = document.getElementById('notesTbody');
    if (!notes || notes.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted py-4">No notes found.</td></tr>';
        return;
    }
    tbody.innerHTML = notes.map((n, i) => {
        const isOpen = (n.isClosed == 0);
        const statusBadge = isOpen
            ? '<span class="badge-open">Open</span>'
            : '<span class="badge-closed">Closed</span>';
        const action = isOpen
            ? `<button class="btn btn-sm btn-danger" onclick="closeNote(${n.id})">
                   <i class="fas fa-times-circle me-1"></i>Close
               </button>`
            : `<span class="text-muted small">${escHtml(n.closedAt || '')}</span>`;
        const phone = (n.customerPhone || '').replace(/\D/g, '');
        const waLink = phone
            ? `<a href="https://wa.me/91${phone}" target="_blank" title="Chat on WhatsApp"
                  style="color:#25D366;text-decoration:none;">
                  <i class="fab fa-whatsapp me-1"></i>${escHtml(n.customerPhone)}
               </a>`
            : '-';
        return `<tr class="${isOpen ? 'open-row' : ''}">
            <td class="text-muted small">${i + 1}</td>
            <td><b>${escHtml(n.customerName)}</b></td>
            <td>${waLink}</td>
            <td style="max-width:320px; white-space:pre-wrap; color:#dc3545; font-weight:700;">${escHtml(n.description)}</td>
            <td class="text-nowrap small">${escHtml(n.dateTime || '')}</td>
            <td class="small">${escHtml(n.addedBy || '')}</td>
            <td>${statusBadge}</td>
            <td>${action}</td>
        </tr>`;
    }).join('');
}

function closeNote(id) {
    Swal.fire({
        title: 'Close this note?',
        text: 'This will mark the follow note as closed.',
        icon: 'question',
        showCancelButton: true,
        confirmButtonText: 'Yes, Close it',
        confirmButtonColor: '#dc3545'
    }).then(result => {
        if (!result.isConfirmed) return;
        fetch('closeFollowNote.jsp', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'noteId=' + encodeURIComponent(id)
        })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                Swal.fire({ icon: 'success', title: 'Closed', text: 'Note closed successfully.',
                            timer: 1200, showConfirmButton: false });
                loadNotes();
            } else {
                Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Failed to close note.' });
            }
        })
        .catch(() => Swal.fire({ icon: 'error', title: 'Error', text: 'Request failed.' }));
    });
}

// Initial load
loadNotes();
</script>
</body>
</html>
