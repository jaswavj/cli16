<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>


<!DOCTYPE html>
<html>
<head>
    <title>Change Password</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .card {
            max-width: 450px;
            margin: 50px auto;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / danger / warning / info
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>
   <!--%@ include file="../menu/adminMenu.jsp" %-->
        <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container">
        <div class="card p-4 rounded">
            <h3 class="text-center mb-4">Change Password</h3>

            <form action="<%= request.getContextPath() %>/admin/changePassword/updatePassword.jsp" method="post">
                <input type="hidden" name="username" value="<%=session.getAttribute("username")%>">

                <div class="mb-3">
                    <label for="oldPassword" class="form-label">existing password</label>
                    <input type="password" name="oldPassword" id="oldPassword" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label for="newPassword" class="form-label">New Password</label>
                    <input type="password" name="newPassword" id="newPassword" class="form-control" required>
                </div>

                <div class="mb-3">
                    <label for="confirmPassword" class="form-label">Confirm New Password</label>
                    <input type="password" name="confirmPassword" id="confirmPassword" class="form-control" required>
                </div>

                <div class="d-flex justify-content-between">
                    <button type="submit" class="btn btn-primary">Update Password</button>
                    <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-secondary">Home</a>
                    
                </div>
            </form>
        </div>
    </div>
</body>
</html>
