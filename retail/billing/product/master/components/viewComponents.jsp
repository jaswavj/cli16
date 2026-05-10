<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    int productId = Integer.parseInt(request.getParameter("productId"));
    String productName = request.getParameter("productName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Components - <%=productName%></title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
    
    <% 
    String msg = request.getParameter("msg");
    String type = request.getParameter("type");
    if (msg != null) { 
    %>
    <div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3 container" role="alert">
        <%= msg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    
    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3>Components for: <strong><%=productName%></strong></h3>
            <a href="<%=contextPath%>/product/master/components/page.jsp" class="btn btn-secondary">
                <i class="fas fa-arrow-left me-1"></i>Back
            </a>
        </div>

        <div class="card">
            <div class="card-body">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Component Name</th>
                            <th>Component Code</th>
                            <th>Quantity</th>
                            <th class="text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try {
                            Vector components = prod.getProductComponents(productId);
                            if (components != null && components.size() > 0) {
                                for (int i = 0; i < components.size(); i++) {
                                    Vector row = (Vector) components.get(i);
                                    int compId = (Integer) row.elementAt(0);
                                    String compName = row.elementAt(1).toString();
                                    String compCode = row.elementAt(2).toString();
                                    double qty = (Double) row.elementAt(3);
                        %>
                        <tr>
                            <td><%=i+1%></td>
                            <td><%=compName%></td>
                            <td><%=compCode%></td>
                            <td><%=qty%></td>
                            <td class="text-center">
                                <a href="<%=contextPath%>/product/master/components/deleteComponent.jsp?id=<%=compId%>&productId=<%=productId%>&productName=<%=productName%>" 
                                   class="btn btn-sm btn-danger"
                                   onclick="return confirm('Delete this component?')">
                                    <i class="fas fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="text-center text-muted py-4">
                                <i class="fas fa-inbox fa-2x mb-2 d-block" style="opacity: 0.3;"></i>
                                No components configured yet. Go back and add components.
                            </td>
                        </tr>
                        <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='5' class='text-center text-danger'>Error: " + e.getMessage() + "</td></tr>");
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
