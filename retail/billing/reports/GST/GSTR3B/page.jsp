<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*, java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
%>
<!DOCTYPE html>
<html>
<head>
    <title>GSTR-3B Report</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        .report-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .report-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            
        }
        .filter-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .filter-row {
            display: flex;
            gap: 15px;
            align-items: end;
            flex-wrap: wrap;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        .filter-group label {
            font-weight: 500;
            color: #495057;
        }
        .filter-group input,
        .filter-group select {
            padding: 8px 12px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            font-size: 14px;
        }
        .btn-primary {
            background: #007bff;
            color: white;
            padding: 8px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-primary:hover {
            background: #0056b3;
        }
        iframe {
            width: 100%;
            min-height: 800px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
    
    <div class="report-container">
        <div class="report-header">
            <h2>GSTR-3B Monthly Return</h2> 
            <p style="color: #6c757d; margin: 5px 0 0 0;">Monthly Summary of Outward Supplies and Input Tax Credit</p>
        </div>

        <div class="filter-section">
            <form id="reportForm" action="<%=contextPath%>/reports/GST/GSTR3B/page1.jsp" method="get">
                <div class="filter-row">
                    <div class="filter-group">
                        <label>Month:</label>
                        <select name="month" id="month">
                            <option value="01">January</option>
                            <option value="02">February</option>
                            <option value="03">March</option>
                            <option value="04">April</option>
                            <option value="05">May</option>
                            <option value="06">June</option>
                            <option value="07">July</option>
                            <option value="08">August</option>
                            <option value="09">September</option>
                            <option value="10">October</option>
                            <option value="11">November</option>
                            <option value="12">December</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label>Year:</label>
                        <select name="year" id="year">
                            <option value="2023">2023</option>
                            <option value="2024">2024</option>
                            <option value="2025">2025</option>
                            <option value="2026" selected>2026</option>
                            <option value="2027">2027</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <button type="submit" class="btn-primary">
                            <i class="fas fa-search"></i> Generate Report
                        </button>
                    </div>
                </div>
            </form>
        </div>

    </div>

    <script> 
        // Set current month
        const currentDate = new Date();
        const currentMonth = String(currentDate.getMonth() + 1).padStart(2, '0');
        document.getElementById('month').value = currentMonth;

        // Update iframe action
        document.getElementById('reportForm').action = 'page1.jsp';
    </script>
</body>
</html>
