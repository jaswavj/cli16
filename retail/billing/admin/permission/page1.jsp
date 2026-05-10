<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<jsp:useBean id="users" class="user.userBean" />



<%
    String uidStr = request.getParameter("userId");
    int userId1 = 0;
    if (uidStr != null && !uidStr.isEmpty()) {
        userId1 = Integer.parseInt(uidStr);
    }

    Vector userList = users.getUserModules();
    

    Map<Integer, String> allModules = new LinkedHashMap<Integer, String>();
    for (int i = 0; i < userList.size(); i++) {
        Vector row = (Vector) userList.get(i);     // element is like [1, Billing]
        Integer id   = Integer.valueOf(row.get(0).toString());
        String name  = row.get(1).toString();
        allModules.put(id, name);
    }


    for (Map.Entry<Integer, String> e : allModules.entrySet()) {
    }

    Vector userModules = prod.getUserPermissions(userId1);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Select User</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
        .table td, .table th { vertical-align: middle; }
        .badge-add { background: #28a745; color: white; }
        .badge-remove { background: #dc3545; color: white; }
    </style>
</head>
<body class="bg-light">
    <!--%@ include file="../menu/adminMenu.jsp" %-->
        <%@ include file="/assets/navbar/navbar.jsp" %>
    <div class="container mt-4">
<h3>Manage Permissions for User ID: <%=userId1%></h3>

<form action="<%= request.getContextPath() %>/admin/permission/page2.jsp" method="post">
    <input type="hidden" name="userId1" value="<%=userId1%>">

    <%
    // Flatten userModules into a Set of Strings for easy lookup
    Set<String> userModuleIds = new HashSet<String>();
    for (Object obj : userModules) {
        if (obj instanceof Vector) {
            Vector row = (Vector) obj;
            if (!row.isEmpty()) {
                userModuleIds.add(String.valueOf(row.get(0)));  // first column
            }
        }
    }

    for (Map.Entry<Integer,String> entry : allModules.entrySet()) {
        int moduleId = entry.getKey();
        String moduleName = entry.getValue();

        boolean checked = userModuleIds.contains(String.valueOf(moduleId));
%>
        <div class="form-check">
            <input class="form-check-input" type="checkbox" 
                   name="modules" 
                   value="<%=moduleId%>"
                   <%=checked ? "checked" : "" %> >
            <label class="form-check-label"><%=moduleName%></label>
        </div>
    <%
        }
    %>

    <br>
    <button type="submit" class="btn btn-primary">Update Permissions</button>
</form>
</div>
</body>
</html>
