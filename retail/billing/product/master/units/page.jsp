<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Units - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .navbar { background-color: #4e73df; }
        .navbar-brand { color: #fff !important; }
        .table td, .table th { vertical-align: middle; }
        .badge { padding: 0.35em 0.65em; }
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
        <h3>Units Management</h3>
        
        <!-- Add Unit Form -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="<%=contextPath%>/product/master/units/page1.jsp" method="post" class="row g-3">
                    <div class="col-md-4 input-outline">
                        <input type="text" name="unitName" class="form-control" placeholder="" required>
                        <label>Unit Name</label>
                    </div>
                    <div class="col-md-4 input-outline">
                        <input type="text" name="convertionUnit" id="convertionUnit" class="form-control" placeholder="">
                        <label>Convertion Unit Name</label>
                    </div>
                    <div class="col-md-4 input-outline">
                        <input type="number" step="0.01" min="0" name="convertionCalculation" id="convertionCalculation" class="form-control" placeholder="">
                        <label>Convertion Calculation</label>
                        <small id="convertionNote" class="text-muted d-block mt-1">How many conversion units per base unit.</small>
                    </div>
                    
                    <div class="col-md-12">
                        <button type="submit" class="btn btn-primary">Add Unit</button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Units List Table -->
        <div class="card">
            <div class="card-body">
                <h5>Units List</h5>

                <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0;">
                    <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
                        <tr>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">#</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Name</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Convertion Unit</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Convertion Calculation</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Status</th>
                            <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Vector vec = prod.getUnitsList();
                            for (int i = 0; i < vec.size(); i++) {
                                Vector vec1 = (Vector) vec.get(i);
                                int id = Integer.parseInt(vec1.elementAt(0).toString());
                                String name = vec1.elementAt(1).toString();
                                String convertionUnit = vec1.elementAt(2) != null ? vec1.elementAt(2).toString() : "-";
                                String convertionCalculation = vec1.elementAt(3) != null ? vec1.elementAt(3).toString() : "-";
                                int isActive = Integer.parseInt(vec1.elementAt(4).toString());
                        %>
                        <tr style="border-bottom: 1px solid #f1f5f9; transition: all 0.2s;">
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=i+1%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=name%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=convertionUnit%></td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;"><%=convertionCalculation%></td>
                            <td style="padding: 0.4rem; border: none; font-size: 0.9rem;">
                                <% if (isActive == 1) { %>
                                    <span class="badge bg-success">Active</span>
                                <% } else { %>
                                    <span class="badge bg-danger">Blocked</span>
                                <% } %>
                            </td>
                            <td style="padding: 0.4rem; color: #718096; border: none; font-size: 0.9rem;">
                                <a href="<%=contextPath%>/product/master/units/edit.jsp?id=<%=id%>" class="btn btn-warning btn-sm">Edit</a>
                                <% if (isActive == 1) { %>
                                    <a href="<%=contextPath%>/product/master/units/block.jsp?id=<%=id%>&action=block" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to block this unit?')">Block</a>
                                <% } else { %>
                                    <a href="<%=contextPath%>/product/master/units/block.jsp?id=<%=id%>&action=unblock" class="btn btn-success btn-sm" onclick="return confirm('Are you sure you want to unblock this unit?')">Unblock</a>
                                <% } %>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
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
