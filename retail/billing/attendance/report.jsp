<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, java.sql.*"%>
<jsp:useBean id="user" class="user.userBean" />
<%
String contextPath = request.getContextPath();
Integer uid = (Integer) session.getAttribute("userId");

if (uid == null) {
    response.sendRedirect(contextPath + "/index.jsp");
    return;
}

// Load permissions from database and check for admin
Vector vecPer = user.getUserPermission(uid);
Set<Integer> permissions = new HashSet<Integer>();
for (int i = 0; i < vecPer.size(); i++) {
    Vector cat = (Vector) vecPer.get(i);
    int modId = Integer.parseInt(cat.elementAt(0).toString());
    permissions.add(modId);
}
boolean isAdmin = permissions.contains(8); // Admin permission

// Get filter params
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
String userFilter = request.getParameter("userId");

if (fromDate == null) fromDate = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
if (toDate == null) toDate = fromDate;

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
String today = sdf.format(new Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attendance Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        .attendance-report-wrap .card-header h5 {
            font-size: 1.35rem;
            font-weight: 700;
        }
        .attendance-report-wrap .form-label {
            font-size: 1.12rem;
            font-weight: 500;
        }
        .attendance-report-wrap .form-control,
        .attendance-report-wrap .form-select,
        .attendance-report-wrap .btn,
        .attendance-report-wrap table th,
        .attendance-report-wrap table td,
        .attendance-report-wrap .badge {
            font-size: 1.05rem;
        }
        @media (max-width: 768px) {
            .attendance-report-wrap .card-header h5 {
                font-size: 1.18rem;
            }
            .attendance-report-wrap .form-label,
            .attendance-report-wrap .form-control,
            .attendance-report-wrap .form-select,
            .attendance-report-wrap .btn,
            .attendance-report-wrap table th,
            .attendance-report-wrap table td,
            .attendance-report-wrap .badge {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/assets/navbar/navbar.jsp" />

<div class="container-fluid mt-4 attendance-report-wrap">
    <div class="row">
        <div class="col-12">
            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-chart-bar me-2"></i>Attendance Report</h5>
                </div>
                <div class="card-body">
                    <!-- Filters -->
                    <form id="filterForm" class="row g-3 mb-4">
                        <div class="col-md-2">
                            <label class="form-label">From Date:</label>
                            <input type="date" name="fromDate" class="form-control" value="<%=fromDate%>" required>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">To Date:</label>
                            <input type="date" name="toDate" class="form-control" value="<%=toDate%>" required>
                        </div>
                        <%if(isAdmin) {%>
                        <div class="col-md-3">
                            <label class="form-label">Filter by User:</label>
                            <select name="userId" class="form-select" id="userSelect">
                                <option value="">-- All Users --</option>
                            </select>
                        </div>
                        <%}%>
                        <div class="col-md-2 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="fas fa-search me-1"></i>Search
                            </button>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button type="button" class="btn btn-success w-100" onclick="exportToExcel()">
                                <i class="fas fa-download me-1"></i>Export
                            </button>
                        </div>
                    </form>

                    <!-- Report Table -->
                    <div class="table-responsive">
                        <table id="attendanceTable" class="table table-hover table-bordered">
                            <thead class="table-light">
                                <tr>
                                    <th>S.No</th>
                                    <%if(isAdmin) {%><th>User</th><%}%>
                                    <th>Date</th>
                                    <th>Check In</th>
                                    <th>Check Out</th>
                                    <th>Duration</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody id="reportTbody">
                                <tr><td colspan="7" class="text-center text-muted py-4">Loading...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const contextPath = '<%=contextPath%>';
const isAdmin = <%=isAdmin%>;
const currentUid = <%=uid%>;

function loadReport() {
    const form = document.getElementById('filterForm');
    const formData = new FormData(form);
    const params = new URLSearchParams(formData);
    
    fetch(contextPath + '/attendance/getAttendanceReport.jsp?' + params.toString())
        .then(r => r.json())
        .then(data => renderReport(data))
        .catch(err => {
            document.getElementById('reportTbody').innerHTML = 
                '<tr><td colspan="7" class="text-center text-danger py-4">Error loading report</td></tr>';
        });
}

function renderReport(data) {
    const tbody = document.getElementById('reportTbody');
    
    if (!data || data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">No records found</td></tr>';
        return;
    }

    tbody.innerHTML = data.map((row, i) => {
        let duration = '-';
        if (row.inTime && row.outTime) {
            const inParts = row.inTime.split(':');
            const outParts = row.outTime.split(':');
            const inMins = parseInt(inParts[0]) * 60 + parseInt(inParts[1]);
            const outMins = parseInt(outParts[0]) * 60 + parseInt(outParts[1]);
            const diffMins = outMins - inMins;
            const hours = Math.floor(diffMins / 60);
            const mins = diffMins % 60;
            duration = hours + 'h ' + mins + 'm';
        }

        let status = '<span class="badge bg-warning">Pending Out</span>';
        if (row.inTime && row.outTime) {
            status = '<span class="badge bg-success">Completed</span>';
        } else if (!row.inTime) {
            status = '<span class="badge bg-secondary">Not Marked</span>';
        }

        return `<tr>
            <td>${i + 1}</td>
            ${isAdmin ? `<td>${row.userName}</td>` : ''}
            <td>${row.date}</td>
            <td>${row.inTime || '-'}</td>
            <td>${row.outTime || '-'}</td>
            <td>${duration}</td>
            <td>${status}</td>
        </tr>`;
    }).join('');
}

function exportToExcel() {
    const table = document.getElementById('attendanceTable');
    const html = '<html><body>' + table.outerHTML + '</body></html>';
    const blob = new Blob([html], { type: 'application/vnd.ms-excel' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = 'attendance_report.xls';
    link.click();
}

if (isAdmin) {
    // Load users dropdown
    fetch(contextPath + '/getAllUsers.jsp')
        .then(r => {
            if (!r.ok) throw new Error('Failed to load users: ' + r.status);
            return r.json();
        })
        .then(users => {
            const select = document.getElementById('userSelect');
            if (users && users.length > 0) {
                users.forEach(u => {
                    const opt = document.createElement('option');
                    opt.value = u.id;
                    opt.text = u.name;
                    select.appendChild(opt);
                });
            }
        })
        .catch(err => {
            console.error('Error loading users:', err);
        });
}

document.getElementById('filterForm').addEventListener('submit', function(e) {
    e.preventDefault();
    loadReport();
});

// Initial load
loadReport();
</script>
</body>
</html>
