<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%

	String brandsName	   = request.getParameter("brandsName");
	int brandsId 		   = Integer.parseInt(request.getParameter("brandsId").toString());
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
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type"); // success / warning / danger / info
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

<body class="bg-light">
    <div class="container d-flex justify-content-center align-items-center min-vh-100">
        <div class="card shadow-sm" style="width: 400px;">
            <div class="card-header text-center bg-secondary text-white">
                <h5 class="mb-0">Update <%=head2%></h5>
            </div>
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/brands/editBrands1.jsp" method="post">
					<input type=hidden value="<%=brandsId%>" name="brandsId">
					
                    <div class="mb-3 input-outline">

                        <input type="text" class="form-control" value="<%=brandsName%>" disabled id="prevCategory" name="prevCategory" value="Old Category Name" readonly><label><%=head2%> Name</label>
                    </div>

                    <div class="mb-3 input-outline">

                        <input type="text" class="form-control" value="<%=brandsName%>" id="newCategory" name="newBrands" placeholder="" required><label>New <%=head2%> Name</label>
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


</body>

</html>
