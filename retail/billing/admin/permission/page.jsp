<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*,java.sql.*,java.text.*"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
    
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
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-lg border-0 rounded-3">
                <div class="card-body p-4">
                    <h3 class="card-title mb-4 text-center">Select User</h3>
                    <form action="<%= request.getContextPath() %>/admin/permission/page1.jsp" method="get">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Choose a User</label>
                            <select name="userId" class="form-select" required>
                                <option value="">-- Select User --</option>
                                <%
                                Vector userList = prod.getAllUser(); 

                                for(int i=0; i<userList.size(); i++){
                                    Vector row = (Vector) userList.elementAt(i);
                                    String userId = row.get(0).toString();
                                    String  uname= row.get(1).toString();
                            %>
                                <option value="<%=userId%>"><%=uname%></option>
                            <%
                                }
                            %>
                            </select>
                        </div>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary btn-lg">Give Permissions</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
