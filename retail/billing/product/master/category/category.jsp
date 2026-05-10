<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page errorPage="" %>
<jsp:useBean id="prod" class="product.productBean" />
<%

// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head> 
    <meta charset="UTF-8">
    <title>Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- Bootstrap CSS -->
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body {
            background: #f5f7fa;
        }
        .navbar {
            background-color: #4e73df;
        }
        .navbar-brand {
            color: #fff !important;
        }
        .table td, .table th {
            vertical-align: middle;
        }
        .btn-edit, .btn-delete {
            margin: 0 2px;
        }
        

    </style>
    
</head>
<body>
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / danger / warning
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <%@ include file="/assets/navbar/navbar.jsp" %>
    <!-- Top Navbar -->


    <div class="container-fluid mt-2" style="max-width: 1400px;">
        <div class="row g-2">
            <!-- Left Column - Add Category Form -->
            <div class="col-md-7">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px; height: 100%;">
                    <div class="card-header" style="background: var(--page-header-card-bg); color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <h6 class="mb-0" style="font-weight: 600; font-size: 0.95rem;"><i class="fas fa-plus-circle me-2"></i>Add New <%=head1%></h6>
                    </div>
                    <div class="card-body" style="padding: 1rem;">
                        <form action="<%=contextPath%>/product/master/category/category1.jsp" method="post">
                            <div class="mb-3">
                                <div class="input-outline">
                                    <input type="text" name="catName" class="form-control" placeholder="" style="padding: 8px 10px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem;" required>
                                    <label style="background: white; padding: 0 6px; font-size: 0.85rem;"><%=head1%> Name</label>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-primary w-100" style="padding: 8px 10px; font-size: 0.9rem;">
                                <i class="fas fa-save me-1"></i>Add <%=head1%>
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Right Column - Category List Table -->
            <div class="col-md-5">
                <div class="card" style="border: none; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.07); border-radius: 8px;">
                    <div class="card-header" style="background: white; border-bottom: 1px solid #f7fafc; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                        <h6 class="mb-0" style="color: #2d3748; font-weight: 600; font-size: 0.95rem;"><i class="fas fa-list me-2"></i><%=head1%> List</h6>
                    </div>
                    <div class="card-body" style="padding: 0;">

                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;"><i class="fas fa-tag me-1"></i>Name</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; text-align: center; border: none; font-size: 0.85rem;"><i class="fas fa-cog me-1"></i>Actions</th>
                        </tr>
                    </thead>
                    <tbody>

                        <%
                        try {
                            Vector vec = prod.getCategoryName();
                            if (vec != null && vec.size() > 0) {
                                for (int i = 0; i < vec.size(); i++) {
                                    Vector vec1 = (Vector) vec.get(i); // inner vector (row)
                                    if (vec1 == null || vec1.elementAt(0) == null || vec1.elementAt(1) == null) {
                                        continue; // Skip null entries
                                    }
                                    String categoryName = vec1.elementAt(0).toString();
                                    int categoryId = Integer.parseInt(vec1.elementAt(1).toString());
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
                            <td style="padding: 0.4rem; color: #2d3748; font-weight: 500; border: none; font-size: 0.9rem;"><%=categoryName%></td>
                            <td style="padding: 0.4rem; text-align: center; border: none;">
                                <button onclick="openEditModal('<%=categoryName.replace("'", "\\'")%>', <%=categoryId%>)" class="btn btn-sm" style="background: var(--primary-gradient); color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                                    <i class="fas fa-edit me-1"></i>Edit
                                </button>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="3" class="text-center" style="padding: 2rem; color: #718096;">
                                <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                <p class="mb-0">No categories found. Add your first category above.</p>
                            </td>
                        </tr>
                        <%
                            }
                        } catch (Exception e) {
                            out.println("<tr><td colspan='3' class='text-center text-danger'>Error loading categories: " + e.getMessage() + "</td></tr>");
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
            </div>
        </div>
    </div>

    <!-- Edit Category Modal -->
    <div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content" style="border-radius: 8px; border: none; box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);">
                <div class="modal-header" style="background: var(--page-header-card-bg); color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                    <h6 class="modal-title mb-0" style="font-size: 0.95rem;"><i class="fas fa-edit me-2"></i>Edit <%=head1%></h6>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 1.25rem;">
                    <form id="editForm" action="<%=contextPath%>/product/master/category/editCategory1.jsp" method="post">
                        <input type="hidden" name="categoryId" id="editCategoryId">
                        
                        <div class="mb-2">
                            <label class="form-label" style="color: #4a5568; font-weight: 600; font-size: 0.85rem; margin-bottom: 0.3rem;">Current Name</label>
                            <input type="text" id="currentName" class="form-control" disabled style="background: #f7fafc; border: 2px solid #e2e8f0; border-radius: 6px; padding: 8px 10px; font-size: 0.9rem;">
                        </div>
                        
                        <div class="mb-2">
                            <div class="input-outline">
                                <input type="text" name="newCategory" id="editCategoryName" class="form-control" placeholder="" style="padding: 8px 10px; border: 2px solid #e2e8f0; border-radius: 6px; font-size: 0.9rem;" required>
                                <label style="background: white; padding: 0 6px; font-size: 0.85rem;">New <%=head1%> Name</label>
                            </div>
                        </div>
                        
                        <div class="mb-2">
                            <div class="form-check" style="padding: 8px; background: #fff5f5; border-radius: 6px; border-left: 3px solid #f56565;">
                                <input class="form-check-input" type="checkbox" name="block" value="block" id="editBlock">
                                <label class="form-check-label" for="editBlock" style="color: #c53030; font-weight: 500; font-size: 0.85rem;">
                                    <i class="fas fa-exclamation-triangle me-1"></i>Block this <%=head1.toLowerCase()%>
                                </label>
                            </div>
                            <small class="text-muted" style="display: block; margin-top: 4px; font-size: 0.75rem;">Blocking will make this category unavailable for selection</small>
                        </div>
                        
                        <div class="d-flex gap-2 justify-content-end">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="padding: 6px 16px; border-radius: 6px; font-size: 0.85rem;">
                                <i class="fas fa-times me-1"></i>Cancel
                            </button>
                            <button type="submit" class="btn btn-primary" style="padding: 6px 16px; border-radius: 6px; background: var(--primary-gradient); border: none; font-size: 0.85rem;">
                                <i class="fas fa-save me-1"></i>Update
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        function openEditModal(categoryName, categoryId) {
            document.getElementById('currentName').value = categoryName;
            document.getElementById('editCategoryName').value = categoryName;
            document.getElementById('editCategoryId').value = categoryId;
            document.getElementById('editBlock').checked = false;
            
            var editModal = new bootstrap.Modal(document.getElementById('editModal'));
            editModal.show();
            
            // Focus on new name input after modal opens
            setTimeout(() => {
                document.getElementById('editCategoryName').focus();
            }, 500);
        }
    </script>

</body>
</html>
