<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
String contextPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delivered Report</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    <style>
        .container.mt-4 h3 {
            font-size: 1.35rem;
            font-weight: 700;
        }
        .container.mt-4 .form-label {
            font-size: 1.12rem;
            font-weight: 500;
        }
        .container.mt-4 .form-control,
        .container.mt-4 .form-select,
        .container.mt-4 .btn {
            font-size: 1.08rem;
        }
        @media (max-width: 768px) {
            .container.mt-4 h3 {
                font-size: 1.15rem;
            }
            .container.mt-4 .form-label,
            .container.mt-4 .form-control,
            .container.mt-4 .form-select,
            .container.mt-4 .btn {
                font-size: 1rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="container mt-4">
        <h3 class="mb-4">Delivered Report</h3>
        <p class="text-muted mb-4">Filter by delivery date (delivered bills only)</p>

        <form action="<%=contextPath%>/reports/delivered/page0.jsp" method="get" class="row g-3">
            <div class="col-md-2">
                <label for="fromDate" class="form-label">From Date:</label>
                <input type="date" id="fromDate" name="fromDate" value="<%=today%>" class="form-control" required>
            </div>
            <div class="col-md-2">
                <label for="toDate" class="form-label">To Date:</label>
                <input type="date" id="toDate" name="toDate" value="<%=today%>" class="form-control" required>
            </div>
            <div class="col-md-3 d-flex align-items-end">
                <button type="submit" class="btn btn-primary w-100">Generate Report</button>
            </div>
        </form>
    </div>
</body>
</html>
