<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page language="java" import="java.util.*" %>
<jsp:useBean id="user" class="user.userBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");
Vector vecPer = user.getUserPermission(uid);

 java.util.Set<Integer> permissions = new java.util.HashSet<Integer>();
int modId = 0;
for (int i = 0; i < vecPer.size(); i++) {
    Vector cat = (Vector) vecPer.get(i);
    modId = Integer.parseInt(cat.elementAt(0).toString());
    permissions.add(modId);
}

            
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dashboard - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <!-- Top Navbar & Sidebar -->
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container-fluid p-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3>Welcome, <%= session.getAttribute("username") %>!</h3>
            <a href="${pageContext.request.contextPath}/admin/changePassword/changePassword.jsp" class="btn btn-outline-violet">
                <i class="fas fa-key"></i> Change Password
            </a>
        </div>

        <div class="row">
            <!-- Billing -->
        <% if (permissions.contains(1)) { %>
            <div class="col-md-4 mb-4">
                <div class="card h-100 text-center p-4">
                    <div class="card-body">
                        <i class="fas fa-file-invoice fa-3x text-primary mb-3"></i>
                        <h5 class="card-title">Billing</h5>
                        <p class="card-text text-muted">Create and manage invoices efficiently.</p>
                        <form action="<%= request.getContextPath() %>/billing/billing.jsp" method="post">
                            <input type="hidden" name="modId" value="1">
                            <button type="submit" class="btn btn-primary w-100">Go to Billing</button>
                        </form>
                    </div>
                </div>
            </div>
        <%}%>
            <!-- Products -->
        <% if (permissions.contains(2)) { %>
            <div class="col-md-4 mb-4">
                <div class="card h-100 text-center p-4">
                    <div class="card-body">
                        <i class="fas fa-box-open fa-3x text-success mb-3"></i>
                        <h5 class="card-title">Products</h5>
                        <p class="card-text text-muted">Add, edit, or delete products and stock.</p>
                        <form action="<%= request.getContextPath() %>/product/menu/f.jsp" method="post">
                            <input type="hidden" name="modId" value="2">
                            <button type="submit" class="btn btn-outline-violet w-100">Manage Products</button>
                        </form>
                    </div>
                </div>
            </div>
        <%}%>
            <!-- Reports -->
        <% if (permissions.contains(3)) { %>
            <div class="col-md-4 mb-4">
                <div class="card h-100 text-center p-4">
                    <div class="card-body">
                        <i class="fas fa-chart-bar fa-3x text-warning mb-3"></i>
                        <h5 class="card-title">Reports</h5>
                        <p class="card-text text-muted">View daily sales and performance reports.</p>
                        <form action="<%= request.getContextPath() %>/reports/menu/f.jsp" method="post">
                            <input type="hidden" name="modId" value="3">
                            <button type="submit" class="btn btn-outline-violet w-100">View Reports</button>
                        </form>
                    </div>
                </div>
            </div>
        <%}%>
        <% if (permissions.contains(4)) { %> 
            <div class="col-md-4 mb-4">
                <div class="card h-100 text-center p-4">
                    <div class="card-body">
                        <i class="fas fa-user-shield fa-3x text-secondary mb-3"></i>
                        <h5 class="card-title">Admin</h5>
                        <p class="card-text text-muted">Manage users, permissions and access.</p>
                        <form action="<%= request.getContextPath() %>/admin/menu/f.jsp" method="post">
                            <input type="hidden" name="modId" value="4">
                            <button type="submit" class="btn btn-outline-violet w-100">Admin Panel</button>
                        </form>
                    </div>
                </div>
            </div>
        <%}%>
        </div>
    </div>
</body>
</html>
