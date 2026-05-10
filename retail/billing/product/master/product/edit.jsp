<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
	String productName	   = request.getParameter("productName");
	int productId 		   = Integer.parseInt(request.getParameter("productId").toString());
    String prodCode	   = request.getParameter("prodCode");
    String categ	   = request.getParameter("categ");
    String brandss	   = request.getParameter("brandss");
    double mrp 		   = Double.parseDouble(request.getParameter("mrp").toString());
    double cost 		   = Double.parseDouble(request.getParameter("cost").toString());
    double discount 		   = Double.parseDouble(request.getParameter("discount").toString());
	int discType 		   = Integer.parseInt(request.getParameter("discType").toString());
	int gst 			   = Integer.parseInt(request.getParameter("gst").toString());
	String unitId 		   = request.getParameter("unitId") != null ? request.getParameter("unitId") : "";
	String hsn 		   = request.getParameter("hsn") != null ? request.getParameter("hsn") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Item - Billing App</title>
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
    <%@ include file="/assets/navbar/navbar.jsp" %>
<%
String msg = request.getParameter("msg");
String type = request.getParameter("type");
%>

<% if (msg != null) { %>
<div class="alert alert-<%= (type != null ? type : "info") %> alert-dismissible fade show mt-3" role="alert">
  <%= msg %>
  <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
</div>
<% } %>

    <div class="container mt-4">
        <h3><%=head3%> Management</h3>

        <!-- Add Product Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/product/edit1.jsp" method="post" class="row g-3">
                <input type=hidden value="<%=productId%>" name="productId">
                    <div class="col-md-6 input-outline">
                        <input type="text" name="productName" class="form-control" value="<%=productName%>" placeholder="" required><label ><%=head3%> Name</label>
                        
                    </div>
                    <div class="col-md-3 input-outline">
                        <input type="text" name="prodCode" class="form-control" value="<%=prodCode%>" placeholder="" required><label ><%=head3%> Code</label>
                    </div>
                    <div class="col-md-3 input-outline">
                        <select name="categoryId" class="form-select" required>
                            <option value="">Select <%=head1%></option>
                            <%
                                Vector categories = prod.getCategoryName();
                                for (int i = 0; i < categories.size(); i++) {
                                    Vector cat = (Vector) categories.get(i);
                                    String categoryName = cat.elementAt(0).toString();
                                    String categoryId = cat.elementAt(1).toString();
                                    String selectedCat = "";
                                    if (categ != null && categ.equals(categoryName)) {
                                        selectedCat = "selected";
                                    }
                            %>
                                <option value="<%=categoryId%>" <%=selectedCat%>><%=categoryName%></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <select name="brandId" class="form-select" required>
                            <option value="">Select <%=head2%></option>
                            <%
                                Vector brands = prod.getBrandsName();
                                for (int i = 0; i < brands.size(); i++) {
                                    Vector brand = (Vector) brands.get(i);
                                    String brandName = brand.elementAt(0).toString();
                                    String brandId = brand.elementAt(1).toString();
                                    String selectedBrand = "";
                                    if (brandss != null && brandss.equals(brandName)) {
                                        selectedBrand = "selected";
                                    }
                            %>
                                <option value="<%=brandId%>" <%=selectedBrand%>><%=brandName%></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="col-md-3">
                        <select name="unitId" class="form-select" required>
                            <option value="">Select Unit</option>
                            <%
                                Vector units = prod.getUnits();
                                for (int i = 0; i < units.size(); i++) {
                                    Vector unit = (Vector) units.get(i);
                                    String unitName = unit.elementAt(0).toString();
                                    String unitIdOpt = unit.elementAt(1).toString();
                                    String selectedUnit = "";
                                    if (unitId != null && unitId.equals(unitIdOpt)) {
                                        selectedUnit = "selected";
                                    }
                            %>
                                <option value="<%=unitIdOpt%>" <%=selectedUnit%>><%=unitName%></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="col-md-3 input-outline">
                        <input type="text" name="hsn" value="<%=hsn%>" class="form-control" placeholder=""><label>HSN Code</label>
                    </div>
                    
                    <div class="col-md-3 input-outline">
                        <input type="number" step="0.001"  name="cost" value="<%=cost%>" class="form-control" placeholder="" required><label >Cost Price</label>
                    </div>
                    <div class="col-md-3 input-outline">
                        <input type="number" step="0.001"  name="mrp" value="<%=mrp%>" class="form-control" placeholder="" required><label >mrp Price</label>
                    </div>
                    <div class="col-md-3">
                        <select class="form-select" name="gst" required>
                            <option value="">GST %</option>
                            <option value="0" <%= (gst == 0 ? "selected" : "") %>>0%</option>
                            <option value="5" <%= (gst == 5 ? "selected" : "") %>>5%</option>
                            <option value="12" <%= (gst == 12 ? "selected" : "") %>>12%</option>
                            <option value="18" <%= (gst == 18 ? "selected" : "") %>>18%</option>
                            <option value="28" <%= (gst == 28 ? "selected" : "") %>>28%</option>
                        </select>
                    </div>
                    <div class="col-md-3 input-outline">
                    </div>
                    <div class="col-md-3 ">
                        <%
                        String discTypeParam = request.getParameter("discType");
                        int discTypes = 0;
                        if (discTypeParam != null && !discTypeParam.isEmpty()) {
                            try {
                                discTypes = Integer.parseInt(discTypeParam);
                            } catch (NumberFormatException e) {
                                discTypes = 0; // default
                            }
                        }
                        %>
                        <select class="form-control" id="discType" name="discType" onchange="handleDiscTypeChange(this)" required>
                            <option value="0" <%= (discTypes == 0 ? "selected" : "") %>>No Discount</option>
                            <option value="1" <%= (discTypes == 1 ? "selected" : "") %>>Rs</option>
                            <option value="2" <%= (discTypes == 2 ? "selected" : "") %>>Percentage</option>
                        </select>
                    </div>

                    <div class="col-md-3 input-outline">
                        <input type="text"  id="discValue"  name="discValue" value="<%=discount%>" class="form-control" value="0.00" required><label >Discount</label>
                    </div>
                    
                    <div class="col-md-12 input-outline">
                        <button type="submit" class="btn btn-primary">Update <%=head3%></button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Product List Table -->
        
    </div>

    <!-- Bootstrap JS -->
    
    <script>
    function handleDiscTypeChange(select) {
        const discValueInput = document.getElementById('discValue');
        if (select.value === "0") {
            discValueInput.value = "0.00";
            discValueInput.readOnly  = true;
        } else {
            discValueInput.readOnly  = false;
            discValueInput.value = "";
        }
    }
</script>
</body>
</html>
