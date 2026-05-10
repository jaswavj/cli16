<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String contextPathAtt = request.getContextPath();
Vector attenderList = prod.getAllAttenders();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attender Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body {
            background: #f5f7fa;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        .badge-active {
            background: #28a745;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85rem;
        }
        .badge-blocked {
            background: #dc3545;
            color: white;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <%@ include file="/assets/navbar/navbar.jsp" %>
    
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3>Attender Management</h3>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addAttenderModal">
                <i class="fa-solid fa-plus"></i> Add Attender
            </button>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>S.No</th>
                                <th>Name</th>
                                <th>Code</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            if (attenderList != null && attenderList.size() > 0) {
                                for (int i = 0; i < attenderList.size(); i++) {
                                    Vector row = (Vector) attenderList.elementAt(i);
                                    int id = Integer.parseInt(row.get(0).toString());
                                    String name = row.get(1).toString();
                                    String code = row.get(2) != null ? row.get(2).toString() : "";
                                    int isActive = Integer.parseInt(row.get(3).toString());
                            %>
                            <tr>
                                <td><%=i+1%></td>
                                <td><%=name%></td>
                                <td><%=code%></td>
                                <td>
                                    <span class="badge <%=isActive == 1 ? "badge-active" : "badge-blocked"%>">
                                        <%=isActive == 1 ? "Active" : "Blocked"%>
                                    </span>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-warning btn-edit-attender" 
                                        data-id="<%=id%>" 
                                        data-name="<%=name.replace("\"", "&quot;")%>" 
                                        data-code="<%=code.replace("\"", "&quot;")%>">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </button>
                                    <%if (isActive == 1) {%>
                                    <button class="btn btn-sm btn-danger btn-block-attender" data-id="<%=id%>">
                                        <i class="fa-solid fa-ban"></i> Block
                                    </button>
                                    <%} else {%>
                                    <button class="btn btn-sm btn-success btn-unblock-attender" data-id="<%=id%>">
                                        <i class="fa-solid fa-check"></i> Unblock
                                    </button>
                                    <%}%>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="5" class="text-center">No attenders found</td>
                            </tr>
                            <%
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Attender Modal -->
    <div class="modal fade" id="addAttenderModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add Attender</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="addAttenderForm">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-3">
                            <label class="form-label">Name<span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Code</label>
                            <input type="text" name="code" class="form-control">
                        </div>
                        <button type="submit" class="btn btn-primary">Add Attender</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Attender Modal -->
    <div class="modal fade" id="editAttenderModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Attender</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="editAttenderForm">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="id" id="editId">
                        <div class="mb-3">
                            <label class="form-label">Name<span class="text-danger">*</span></label>
                            <input type="text" name="name" id="editName" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Code</label>
                            <input type="text" name="code" id="editCode" class="form-control">
                        </div>
                        <button type="submit" class="btn btn-primary">Update Attender</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Add Attender
        document.getElementById('addAttenderForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            
            // Convert FormData to URL-encoded string
            const params = new URLSearchParams(formData).toString();
            
            // Debug logging
            console.log('Submitting form with params:', params);
            
            fetch('<%=contextPathAtt%>/admin/attender/save.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(response => response.text())
            .then(data => {
                console.log('Response:', data);
                if (data.trim() === 'SUCCESS') {
                    alert('Attender added successfully');
                    location.reload();
                } else {
                    alert('Error: ' + data);
                }
            })
            .catch(error => {
                console.error('Fetch error:', error);
                alert('Error submitting form: ' + error.message);
            });
        });

        // Edit Attender - Use event delegation
        document.addEventListener('click', function(e) {
            if (e.target.closest('.btn-edit-attender')) {
                const btn = e.target.closest('.btn-edit-attender');
                const id = btn.getAttribute('data-id');
                const name = btn.getAttribute('data-name');
                const code = btn.getAttribute('data-code');
                
                document.getElementById('editId').value = id;
                document.getElementById('editName').value = name;
                document.getElementById('editCode').value = code;
                new bootstrap.Modal(document.getElementById('editAttenderModal')).show();
            }
        });

        document.getElementById('editAttenderForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const formData = new FormData(this);
            const params = new URLSearchParams(formData).toString();
            
            fetch('<%=contextPathAtt%>/admin/attender/save.jsp', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(response => response.text())
            .then(data => {
                if (data.trim() === 'SUCCESS') {
                    alert('Attender updated successfully');
                    location.reload();
                } else {
                    alert('Error: ' + data);
                }
            });
        });

        // Block Attender - Use event delegation
        document.addEventListener('click', function(e) {
            if (e.target.closest('.btn-block-attender')) {
                const btn = e.target.closest('.btn-block-attender');
                const id = btn.getAttribute('data-id');
                
                if (confirm('Are you sure you want to block this attender?')) {
                    const params = new URLSearchParams({
                        action: 'block',
                        id: id
                    }).toString();
                    
                    fetch('<%=contextPathAtt%>/admin/attender/save.jsp', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params
                    })
                    .then(response => response.text())
                    .then(data => {
                        if (data.trim() === 'SUCCESS') {
                            alert('Attender blocked successfully');
                            location.reload();
                        } else {
                            alert('Error: ' + data);
                        }
                    });
                }
            }
        });

        // Unblock Attender - Use event delegation
        document.addEventListener('click', function(e) {
            if (e.target.closest('.btn-unblock-attender')) {
                const btn = e.target.closest('.btn-unblock-attender');
                const id = btn.getAttribute('data-id');
                
                if (confirm('Are you sure you want to unblock this attender?')) {
                    const params = new URLSearchParams({
                        action: 'unblock',
                        id: id
                    }).toString();
                    
                    fetch('<%=contextPathAtt%>/admin/attender/save.jsp', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params
                    })
                    .then(response => response.text())
                    .then(data => {
                        if (data.trim() === 'SUCCESS') {
                            alert('Attender unblocked successfully');
                            location.reload();
                        } else {
                            alert('Error: ' + data);
                        }
                    });
                }
            }
        });
    </script>
</body>
</html>
