<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="user" class="user.userBean" />
<%
String contextPath = request.getContextPath();
Integer uid = (Integer) session.getAttribute("userId");
String userName = (String) session.getAttribute("username");

if (uid == null) {
    response.sendRedirect(contextPath + "/index.jsp");
    return;
}

// Load permissions from database and check permission 10
Vector vecPer = user.getUserPermission(uid);
Set<Integer> permissions = new HashSet<Integer>();
for (int i = 0; i < vecPer.size(); i++) {
    Vector cat = (Vector) vecPer.get(i);
    int modId = Integer.parseInt(cat.elementAt(0).toString());
    permissions.add(modId);
}

if (!permissions.contains(10)) {
    out.print("<script>alert('Access Denied: Permission 10 required'); window.location='" + contextPath + "/';</script>");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attendance Entry</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        .attendance-entry-wrap .card-header h5 {
            font-size: 1.35rem;
            font-weight: 700;
        }
        .attendance-entry-wrap .card-body,
        .attendance-entry-wrap .card-body p,
        .attendance-entry-wrap .alert {
            font-size: 1.12rem;
        }
        .attendance-entry-wrap .btn {
            font-size: 1.12rem;
        }
        @media (max-width: 768px) {
            .attendance-entry-wrap .card-header h5 {
                font-size: 1.18rem;
            }
            .attendance-entry-wrap .card-body,
            .attendance-entry-wrap .card-body p,
            .attendance-entry-wrap .alert,
            .attendance-entry-wrap .btn {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
<jsp:include page="/assets/navbar/navbar.jsp" />

<div class="container mt-5 attendance-entry-wrap">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-clock me-2"></i>Attendance Entry</h5>
                </div>
                <div class="card-body text-center">
                    <p class="text-muted mb-2">Welcome, <strong><%=userName%></strong></p>
                    <p class="text-muted small mb-4">
                        <i class="fas fa-calendar-alt"></i> 
                        <span id="todayDate"></span>
                    </p>

                    <div id="attendanceStatus" class="alert alert-info">
                        Loading...
                    </div>

                    <div class="d-grid gap-2 mt-4">
                        <button id="inBtn" class="btn btn-success btn-lg" onclick="markIn()" disabled>
                            <i class="fas fa-sign-in-alt me-2"></i>In
                        </button>
                        <button id="outBtn" class="btn btn-danger btn-lg" onclick="markOut()" disabled>
                            <i class="fas fa-sign-out-alt me-2"></i>Out
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const contextPath = '<%=contextPath%>';

function formatDate(d) {
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    return d.toLocaleDateString('en-US', options);
}

function displayTime() {
    const now = new Date();
    document.getElementById('todayDate').textContent = formatDate(now);
}

function checkAttendance() {
    fetch(contextPath + '/attendance/checkAttendance.jsp')
        .then(r => r.json())
        .then(data => {
            const inBtn = document.getElementById('inBtn');
            const outBtn = document.getElementById('outBtn');
            const status = document.getElementById('attendanceStatus');

            if (data.hasEntry) {
                if (data.inTime && !data.outTime) {
                    // Checked in but not out
                    inBtn.disabled = true;
                    inBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>In (' + data.inTime + ')';
                    inBtn.classList.add('btn-success');
                    outBtn.disabled = false;
                    status.innerHTML = '<i class="fas fa-info-circle me-2"></i>You checked in at <strong>' + data.inTime + '</strong>. Ready to check out?';
                    status.className = 'alert alert-warning';
                } else if (data.inTime && data.outTime) {
                    // Both checked
                    inBtn.disabled = true;
                    inBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>In (' + data.inTime + ')';
                    outBtn.disabled = true;
                    outBtn.innerHTML = '<i class="fas fa-check-circle me-2"></i>Out (' + data.outTime + ')';
                    outBtn.classList.add('btn-danger');
                    status.innerHTML = '<i class="fas fa-check me-2"></i>Attendance completed today. In: <strong>' + data.inTime + '</strong> | Out: <strong>' + data.outTime + '</strong>';
                    status.className = 'alert alert-success';
                }
            } else {
                // No entry for today
                inBtn.disabled = false;
                outBtn.disabled = true;
                status.innerHTML = '<i class="fas fa-play-circle me-2"></i>Ready to mark attendance? Click <strong>In</strong> to start.';
                status.className = 'alert alert-info';
            }
        })
        .catch(err => {
            document.getElementById('attendanceStatus').innerHTML = 'Error loading attendance status.';
            document.getElementById('attendanceStatus').className = 'alert alert-danger';
        });
}

function markIn() {
    fetch(contextPath + '/attendance/markAttendance.jsp?action=in', { method: 'POST' })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                Swal.fire({ icon: 'success', title: 'Checked In', text: 'You have checked in at ' + data.time, timer: 1500, showConfirmButton: false });
                setTimeout(() => checkAttendance(), 500);
            } else {
                Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Failed to check in' });
            }
        })
        .catch(err => Swal.fire({ icon: 'error', title: 'Error', text: 'Request failed' }));
}

function markOut() {
    fetch(contextPath + '/attendance/markAttendance.jsp?action=out', { method: 'POST' })
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                Swal.fire({ icon: 'success', title: 'Checked Out', text: 'You have checked out at ' + data.time, timer: 1500, showConfirmButton: false });
                setTimeout(() => checkAttendance(), 500);
            } else {
                Swal.fire({ icon: 'error', title: 'Error', text: data.message || 'Failed to check out' });
            }
        })
        .catch(err => Swal.fire({ icon: 'error', title: 'Error', text: 'Request failed' }));
}

document.addEventListener('DOMContentLoaded', function() {
    displayTime();
    setInterval(displayTime, 60000);
    checkAttendance();
});
</script>
</body>
</html>
