<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Unit - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <h3>Edit Unit</h3>
        
        <div class="card">
            <div class="card-body">
                <%
                    String idStr = request.getParameter("id");
                    
                    if (idStr != null) {
                        int id = Integer.parseInt(idStr);
                        Vector unit = prod.getUnitById(id);
                        if (unit != null && unit.size() > 0) {
                            String name = unit.elementAt(1) != null ? unit.elementAt(1).toString() : "";
                            String convertionUnit = unit.elementAt(2) != null ? unit.elementAt(2).toString() : "";
                            String convertionCalculation = unit.elementAt(3) != null ? unit.elementAt(3).toString() : "";
                %>
                
                <form action="<%=contextPath%>/product/master/units/update.jsp" method="post" class="row g-3">
                    <input type="hidden" name="id" value="<%=id%>">
                    
                    <div class="col-md-4 input-outline">
                        <input type="text" name="unitName" class="form-control" value="<%=name%>" placeholder="" required>
                        <label>Unit Name</label>
                    </div>
                    <div class="col-md-4 input-outline">
                        <input type="text" name="convertionUnit" id="convertionUnit" class="form-control" value="<%=convertionUnit%>" placeholder="">
                        <label>Convertion Unit Name</label>
                    </div>
                    <div class="col-md-4 input-outline">
                        <input type="number" step="0.01" min="0" name="convertionCalculation" class="form-control" value="<%=convertionCalculation%>" placeholder="">
                        <label>Convertion Calculation</label>
                        <small id="convertionNote" class="text-muted d-block mt-1">How many conversion units per base unit.</small>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Update Unit</button>
                        <a href="<%=contextPath%>/product/master/units/page.jsp" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>

                <% } else { %>
                    <div class="alert alert-danger">Unit not found.</div>
                <% } %>
                <% } else { %>
                    <div class="alert alert-danger">Invalid unit information provided.</div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
            document.addEventListener('DOMContentLoaded', function () {
                const unitName = document.querySelector('input[name="unitName"]');
                const convertionUnit = document.getElementById('convertionUnit');
                const convertionNote = document.getElementById('convertionNote');

                function updateConvertionNote() {
                    if (!convertionNote) return;
                    const baseUnit = unitName ? unitName.value.trim() : '';
                    const convUnit = convertionUnit ? convertionUnit.value.trim() : '';

                    if (baseUnit !== '' && convUnit !== '') {
                        convertionNote.textContent = 'How many ' + convUnit + ' per ' + baseUnit + '.';
                    } else {
                        convertionNote.textContent = 'How many conversion units per base unit.';
                    }
                }

                if (unitName && convertionUnit) {
                    unitName.addEventListener('input', function () {
                        const value = this.value.trim().toLowerCase();
                        if (value === 'length' && convertionUnit.value.trim() === '') {
                            convertionUnit.value = 'Feet';
                        }
                        updateConvertionNote();
                    });

                    convertionUnit.addEventListener('input', updateConvertionNote);
                }

                updateConvertionNote();
            });

      document.addEventListener('contextmenu', function (e) {
        e.preventDefault();
      });
    </script>
</body>
</html>
