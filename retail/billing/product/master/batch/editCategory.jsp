<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
	String categoryName	   = request.getParameter("categoryName");
	int categoryId 		   = Integer.parseInt(request.getParameter("categoryId").toString());
%>
<html>

<head>
	<title>Update Category</title>
	    <link href="../../../dist/css/bootstrap.min.css" rel="stylesheet">

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

<body class="bg-light">
    <div class="container d-flex justify-content-center align-items-center min-vh-100">
        <div class="card shadow-sm" style="width: 400px;">
            <div class="card-header text-center bg-primary text-white">
                <h5 class="mb-0">Update Category</h5>
            </div>
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/batch/editCategory1.jsp" method="post">
					<input type=hidden value="<%=categoryId%>" name="categoryId">
					
                    <div class="mb-3">
                        <label for="prevCategory" class="form-label">Category Name</label>
                        <input type="text" class="form-control" value="<%=categoryName%>" disabled id="prevCategory" name="prevCategory" value="Old Category Name" readonly>
                    </div>

                    <div class="mb-3">
                        <label for="newCategory" class="form-label">New Category Name</label>
                        <input type="text" class="form-control" value="<%=categoryName%>" id="newCategory" name="newCategory" placeholder="Enter new category name" required>
                    </div>

                    <div class="form-check mb-3">
                        <input class="form-check-input" type="checkbox" id="block" name="block">
                        <label class="form-check-label" for="block">
                            Block
                        </label>
                    </div>

                    <div class="d-grid">
                        <button type="submit" class="btn btn-primary">Submit</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>