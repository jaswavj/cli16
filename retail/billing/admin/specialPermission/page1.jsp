<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="users" class="user.userBean" />

<%
    String uidStr = request.getParameter("userId");
    int userId = 0;
    if (uidStr != null && !uidStr.isEmpty()) {
        userId = Integer.parseInt(uidStr);
    }

    // Get all special permissions from special_permission table
    Vector allSpecialPermissions = users.getAllSpecialPermissions();
    
    // Get user's existing special permissions
    Vector userSpecialPermissions = users.getUserSpecialPermissions(userId);
    
    // Convert userSpecialPermissions to Set for easy lookup
    Set<Integer> userPermissionIds = new HashSet<Integer>();
    for (Object obj : userSpecialPermissions) {
        if (obj instanceof Vector) {
            Vector row = (Vector) obj;
            if (!row.isEmpty()) {
                userPermissionIds.add(Integer.parseInt(row.get(0).toString()));
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Special Permissions</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
        .permission-card {
            border-left: 4px solid #4e73df;
        }
        .form-check {
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            background: #f8f9fa;
            border-radius: 0.25rem;
        }
    </style>
</head>
<body class="bg-light">
    <%@ include file="/assets/navbar/navbar.jsp" %>
    
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card shadow-lg border-0 rounded-3 permission-card">
                    <div class="card-body p-4">
                        <h3 class="card-title mb-4">Manage Special Permissions for User ID: <%=userId%></h3>
                        
                        <form action="<%= request.getContextPath() %>/admin/specialPermission/page2.jsp" method="post">
                            <input type="hidden" name="userId" value="<%=userId%>">
                            
                            <div class="mb-4">
                                <h5 class="text-secondary mb-3">Select Special Permissions:</h5>
                                
                                <%
                                for (int i = 0; i < allSpecialPermissions.size(); i++) {
                                    Vector permission = (Vector) allSpecialPermissions.get(i);
                                    int contentId = Integer.parseInt(permission.get(0).toString());
                                    String content = permission.get(1).toString();
                                    boolean checked = userPermissionIds.contains(contentId);
                                %>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" 
                                           name="permissions" 
                                           value="<%=contentId%>"
                                           id="perm<%=contentId%>"
                                           <%=checked ? "checked" : ""%>>
                                    <label class="form-check-label" for="perm<%=contentId%>">
                                        <%=content%>
                                    </label>
                                </div>
                                <%
                                }
                                %>
                            </div>
                            
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-save me-2"></i>Update Permissions
                                </button>
                                <a href="<%=request.getContextPath()%>/admin/specialPermission/page.jsp" class="btn btn-secondary btn-lg">
                                    <i class="fas fa-arrow-left me-2"></i>Back
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
