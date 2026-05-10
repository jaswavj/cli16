<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
    //String head1 = "Product";
    //String head2 = "Component";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Components - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .card { border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px; }
    </style>
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
        <h3>Product Components Configuration</h3>
        <p class="text-muted">Configure which products have sub-components (e.g., Mixie → Plug, Wire)</p>

        <div class="row">
            <!-- Add Component Form -->
            <div class="col-md-5">
                <div class="card mb-4">
                    <div class="card-header bg-white">
                        <h6 class="mb-0"><i class="fas fa-plus-circle me-2"></i>Add Component</h6>
                    </div>
                    <div class="card-body">
                        <form action="<%=contextPath%>/product/master/components/saveComponent.jsp" method="post">
                            <div class="mb-3">
                                <label class="form-label">Main Product</label>
                                <select name="productId" class="form-select" required>
                                    <option value="">Select Main Product</option>
                                    <%
                                        Vector products = prod.getProductName();
                                        if (products != null) {
                                            for (int i = 0; i < products.size(); i++) {
                                                Vector p = (Vector) products.get(i);
                                                if (p != null && p.size() >= 3) {
                                    %>
                                        <option value="<%=p.elementAt(1)%>"><%=p.elementAt(0)%> (<%=p.elementAt(2)%>)</option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Component Product</label>
                                <select name="componentProductId" class="form-select" required>
                                    <option value="">Select Component</option>
                                    <%
                                        if (products != null) {
                                            for (int i = 0; i < products.size(); i++) {
                                                Vector p = (Vector) products.get(i);
                                                if (p != null && p.size() >= 3) {
                                    %>
                                        <option value="<%=p.elementAt(1)%>"><%=p.elementAt(0)%> (<%=p.elementAt(2)%>)</option>
                                    <%      }
                                            }
                                        }
                                    %>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Quantity per Unit</label>
                                <input type="number" step="0.001" name="quantity" class="form-control" value="1" required>
                                <small class="text-muted">How many components needed per main product</small>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100">Add Component</button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Products with Components List -->
            <div class="col-md-7">
                <div class="card">
                    <div class="card-header bg-white">
                        <h6 class="mb-0"><i class="fas fa-list me-2"></i>Products with Components</h6>
                    </div>
                    <div class="card-body p-0" style="max-height: 600px; overflow-y: auto;">
                        <table class="table table-hover mb-0">
                            <thead class="table-light" style="position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th>#</th>
                                    <th>Product Name</th>
                                    <th>Code</th>
                                    <th>Components</th>
                                    <th class="text-center">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                try {
                                    Vector productList = prod.getProductsWithComponents();
                                    if (productList != null && productList.size() > 0) {
                                        for (int i = 0; i < productList.size(); i++) {
                                            Vector row = (Vector) productList.get(i);
                                            if (row != null && row.size() >= 4) {
                                                int productId = (Integer) row.elementAt(0);
                                                String productName = row.elementAt(1).toString();
                                                String productCode = row.elementAt(2).toString();
                                                int componentCount = (Integer) row.elementAt(3);
                                %>
                                <tr>
                                    <td><%=i+1%></td>
                                    <td><%=productName%></td>
                                    <td><%=productCode%></td>
                                    <td><span class="badge bg-info"><%=componentCount%> components</span></td>
                                    <td class="text-center">
                                        <a href="<%=contextPath%>/product/master/components/viewComponents.jsp?productId=<%=productId%>&productName=<%=productName%>" 
                                           class="btn btn-sm btn-primary">
                                            <i class="fas fa-eye me-1"></i>View
                                        </a>
                                    </td>
                                </tr>
                                <%
                                            }
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="5" class="text-center text-muted py-4">
                                        <i class="fas fa-inbox fa-2x mb-2 d-block" style="opacity: 0.3;"></i>
                                        No components configured yet. Add your first component above.
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
        </div>
    </div>
</body>
</html>
