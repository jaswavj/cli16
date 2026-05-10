<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
	String productName	   = request.getParameter("productName");
	int productId 		   = Integer.parseInt(request.getParameter("productId").toString());
    String prodCode	   = request.getParameter("prodCode");
%>
<html>

<head>
	<title>Update Product</title>
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
    <%@ include file="/assets/navbar/navbar.jsp" %>

<body class="bg-light">
    <div class="container d-flex justify-content-center align-items-center min-vh-100">
        <div class="card shadow-sm" style="width: 400px;">
            <div class="card-header text-center bg-primary text-white">
                <h5 class="mb-0">Update Product</h5>
            </div>
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/product/editProduct1.jsp" method="post">
					<input type=hidden value="<%=productId%>" name="productId">
					
                    <div class="mb-3">
                        <label for="prevProduct" class="form-label">Product Name</label>
                        <input type="text" class="form-control" value="<%=productName%>" disabled id="prevProduct" name="prevProduct" value="Old Category Name" readonly>
                    </div>

                    <div class="mb-3">
                        <label for="newProduct" class="form-label">New Product Name</label>
                        <input type="text" name="newProduct" value="<%=productName%>" class="form-control" placeholder="Product Code" required>
                    </div>
                    <div class="mb-3">
                        <label for="newProduct" class="form-label">Product Code</label>
                        <input type="text" class="form-control" value="<%=prodCode%>" id="prodCode" name="prodCode" placeholder="Enter new category name" required>
                    </div>
                    <div class="mb-3">
                        <select name="categoryId" class="form-select" required>
                            <option value="">Select Category</option>
                            <%
                                Vector categories = prod.getCategoryName();
                                for (int i = 0; i < categories.size(); i++) {
                                    Vector cat = (Vector) categories.get(i);
                                    String categoryName = cat.elementAt(0).toString();
                                    String categoryId = cat.elementAt(1).toString();
                            %>
                                <option value="<%=categoryId%>"><%=categoryName%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="mb-3">
                        <select name="brandId" class="form-select" required>
                            <option value="">Select Brand</option>
                            <%
                                Vector brands = prod.getBrandsName();
                                for (int i = 0; i < brands.size(); i++) {
                                    Vector brand = (Vector) brands.get(i);
                                    String brandName = brand.elementAt(0).toString();
                                    String brandId = brand.elementAt(1).toString();
                            %>
                                <option value="<%=brandId%>"><%=brandName%></option>
                            <% } %>
                        </select>
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