<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
String contextPath = request.getContextPath();
Vector attenderList = prod.getActiveAttenders();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attender-Wise Sales Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="container mt-4">
        <h3 class="mb-4">Attender-Wise Sales Report</h3>

        <form action="<%=contextPath%>/reports/attenderSales/page0.jsp" method="post" class="row g-3">
            <!-- From Date -->
            <div class="col-md-3">
                <label for="fromDate" class="form-label">From Date:</label>
                <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
            </div>

            <!-- To Date -->
            <div class="col-md-3">
                <label for="toDate" class="form-label">To Date:</label>
                <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
            </div>

            <!-- Attender -->
            <div class="col-md-3">
                <label for="attenderId" class="form-label">Select Attender:</label>
                <select id="attenderId" name="attenderId" class="form-select" required>
                    <option value="0">-- All Attenders --</option>
                    <%
                    if (attenderList != null && attenderList.size() > 0) {
                        for (int i = 0; i < attenderList.size(); i++) {
                            Vector row = (Vector) attenderList.elementAt(i);
                            int id = (Integer) row.get(0);
                            String name = row.get(1).toString();
                            String code = row.get(2) != null ? row.get(2).toString() : "";
                    %>
                    <option value="<%=id%>"><%=name%><%=!code.isEmpty() ? " (" + code + ")" : ""%></option>
                    <%
                        }
                    }
                    %>
                </select>
            </div>

            <!-- Submit -->
            <div class="col-md-3 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100">Generate Report</button>
            </div>
        </form>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            attachDataUrlHandlers(document);
            attachAjaxForms(document);
        });
    </script>
</body>
</html>
