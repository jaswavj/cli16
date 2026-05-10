<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
	String categoryName	   = request.getParameter("categoryName");
	int categoryId 		   = Integer.parseInt(request.getParameter("categoryId").toString());
%>
<html>

<head>
	<title>Billing</title>
    <%@ include file="/assets/common/head.jsp" %>

</head>
<script>
	function check() {
		if (document.form1.cont_name.value == "") {
			alert("Enter Country Name",()=>{
				document.form1.cont_name.focus();
			});
			return false
		}
	}
</script>
    <%@ include file="/assets/navbar/navbar.jsp" %>

<body class="bg-light">
    <%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / warning / danger
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container d-flex justify-content-center align-items-center min-vh-100">
        <div class="card" style="width: 500px; border: none; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); border-radius: 16px;">
            <div class="card-header text-center" style="background: var(--page-header-card-bg); color: white; border-radius: 8px 8px 0 0; padding: 0.75rem 1rem;">
                <i class="fas fa-edit" style="font-size: 2.5rem; margin-bottom: 0.5rem;"></i>
                <h4 class="mb-0" style="font-weight: 700;">Update <%=head1%></h4>
                <p class="mb-0 mt-2" style="font-size: 0.9rem; opacity: 0.9;">Modify existing category details</p>
            </div>
            <div class="card-body" style="padding: 2.5rem;">
                <form action="<%=contextPath%>/product/master/category/editCategory1.jsp" method="post">
					<input type="hidden" value="<%=categoryId%>" name="categoryId">
					
                    <div class="mb-4">
                        <label class="form-label" style="font-weight: 600; color: #4a5568; margin-bottom: 0.75rem;">
                            <i class="fas fa-tag me-2"></i>Current <%=head1%> Name
                        </label>
                        <input type="text" class="form-control" value="<%=categoryName%>" disabled style="background: #f7fafc; border: 2px solid #e2e8f0; border-radius: 8px; padding: 12px; color: #718096;">
                    </div>

                    <div class="mb-4">
                        <label class="form-label" style="font-weight: 600; color: #4a5568; margin-bottom: 0.75rem;">
                            <i class="fas fa-pen me-2"></i>New <%=head1%> Name
                        </label>
                        <input type="text" class="form-control" value="<%=categoryName%>" id="newCategory" name="newCategory" required style="border: 2px solid #e2e8f0; border-radius: 8px; padding: 12px; transition: all 0.3s;" onfocus="this.style.borderColor='#667eea'" onblur="this.style.borderColor='#e2e8f0'">
                    </div>

                    <div class="mb-4" style="background: #fef5e7; padding: 1rem; border-radius: 8px; border-left: 4px solid #f39c12;">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="block" name="block" style="width: 20px; height: 20px; cursor: pointer;">
                            <label class="form-check-label" for="block" style="margin-left: 0.5rem; font-weight: 500; color: #856404; cursor: pointer;">
                                <i class="fas fa-ban me-2"></i>Block this category
                            </label>
                        </div>
                    </div>

                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-primary" style="padding: 14px; font-weight: 600; font-size: 1rem;">
                            <i class="fas fa-check-circle me-2"></i>Update <%=head1%>
                        </button>
                        <a href="<%=contextPath%>/product/master/category/category.jsp" class="btn btn-outline-secondary" style="padding: 14px; font-weight: 600; border: 2px solid #cbd5e0; color: #4a5568;">
                            <i class="fas fa-arrow-left me-2"></i>Cancel
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>


</body>

</html>