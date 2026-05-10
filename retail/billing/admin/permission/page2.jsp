<%@ page import="java.util.*, java.sql.*" %>
<jsp:useBean id="prod" class="product.productBean" />

<%
    String uidStr = request.getParameter("userId1");
    int userId2 = Integer.parseInt(uidStr);

    String[] selectedModules = request.getParameterValues("modules");


    prod.clearUserPermissions(userId2);


    if (selectedModules != null) {
        for (String moduleIdStr : selectedModules) {
            int moduleId = Integer.parseInt(moduleIdStr);
            prod.addUserPermission(userId2, moduleId);
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Permissions Updated</title>
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <!--%@ include file="../menu/adminMenu.jsp" %-->
        <%@ include file="/assets/navbar/navbar.jsp" %>
    <div class="container mt-4">
        <h3>Permissions updated successfully </h3>
        
        <a href="<%= request.getContextPath() %>/admin/permission/page.jsp?userId1=<%=userId2%>" class="btn btn-primary">Go Back</a>
    </div>
</body>
</html>
