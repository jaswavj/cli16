<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Area - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body {
            background: #f5f7fa;
        }
    </style>
</head>
<body>

    <%@ include file="/assets/navbar/navbar.jsp" %>

<%
String id = request.getParameter("id");
String name = request.getParameter("name");
String isActive = request.getParameter("isActive");
%>

    <div class="container mt-4">
        <h3>Edit Area</h3>
        
        <div class="card">
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/area/update.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    
                    <div class="col-md-8 input-outline">
                        <input type="text" name="areaName" class="form-control" placeholder="" value="<%=name%>" required>
                        <label>Area Name</label>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update Area</button>
                        <a href="<%=contextPath%>/product/master/area/page.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

</body>
</html>
