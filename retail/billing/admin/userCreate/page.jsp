<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.util.*,java.text.*" %>
<jsp:useBean id="prod" class="user.userBean" />
<%
Vector userList = prod.getUserModules();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Create User</title>
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
        .table td, .table th { vertical-align: middle; }
        .badge-add { background: #28a745; color: white; }
        .badge-remove { background: #dc3545; color: white; }
    </style>
</head>
<body>
    <!--%@ include file="../menu/adminMenu.jsp" %-->
        <jsp:include page="/assets/navbar/navbar.jsp" />
    <div class="container mt-4">

    <form action="<%= request.getContextPath() %>/admin/userCreate/page1.jsp" method="post" class="container mt-4 p-4 border rounded shadow-sm bg-light" style="max-width: 600px;">
    <h4 class="mb-4 text-primary">Create New User</h4>

    <!-- Full Name -->
    <div class="mb-3">
        <label class="form-label">Full Name</label>
        <input type="text" name="fullName" class="form-control" required>
    </div>

    <!-- Username -->
    <div class="mb-3">
        <label class="form-label">Username</label>
        <input type="text" name="userName" class="form-control" required>
    </div>

    <!-- Password -->
    <div class="mb-3">
        <label class="form-label">Password</label>
        <input type="password" name="password" class="form-control" required>
    </div>

    <!-- Module Permissions -->
    <div class="mb-3">
        <label class="form-label">Module Permissions</label><br>
        <%
        
        for (int i = 0; i < userList.size(); i++) {
            Vector module = (Vector) userList.get(i);
            String moduleId = module.get(0).toString();
            String moduleName = module.get(1).toString();
        
        %>
        <div class="form-check">
            <input class="form-check-input" type="checkbox" name="modules" value="<%=moduleId%>" id="billing">
            <label class="form-check-label" for="billing"><%=moduleName%></label>
        </div>
        <%
    }   
        %>
        <!--div class="form-check">
            <input class="form-check-input" type="checkbox" name="modules" value="2" id="product">
            <label class="form-check-label" for="product">Product</label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="checkbox" name="modules" value="3" id="reports">
            <label class="form-check-label" for="reports">Reports</label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="checkbox" name="modules" value="4" id="admin">
            <label class="form-check-label" for="admin">Admin</label>
        </div>
        <div class="form-check">
            <input class="form-check-input" type="checkbox" name="modules" value="5" id="admin">
            <label class="form-check-label" for="admin">Inventory</label>
        </div-->
    </div>

    <!-- Submit -->
    <div class="d-grid">
        <button type="submit" class="btn btn-primary">Create User</button>
    </div>
</form>

    </div>
</body>
</html>
