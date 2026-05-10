<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*, java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<%
%>
<!DOCTYPE html>
<html>
<head>
    <title>GSTR-1 vs GSTR-3B Validation</title>
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        .validation-container {
            max-width: 800px;
            
            padding: 30px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .validation-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            
        }
        .validation-header h2 {
            color: #333;
            margin: 0 0 10px 0;
        }
        .validation-header p {
            color: #666;
            margin: 0;
        }
        .filter-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 5px;
        }
        .filter-group {
            margin-bottom: 20px;
        }
        .filter-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #495057;
        }
        .filter-group select {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ced4da;
            border-radius: 4px;
            font-size: 15px;
        }
        .btn-validate {
            width: 100%;
            background: #57006c;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
        }
        .btn-validate:hover {
            background: #0056b3;
        }
        .info-box {
            background: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin-top: 20px;
        }
        .info-box h5 {
            margin: 0 0 10px 0;
            color: #0277BD;
        }
        .info-box ul {
            margin: 0;
            padding-left: 20px;
        }
    </style>
</head>
<body>
        <%@ include file="/assets/navbar/navbar.jsp" %>
    
    <div class="validation-container">
        <div class="validation-header">
            <h2>🔍 GSTR-1 vs GSTR-3B Validation Report</h2>
            <p>Compare and validate your GSTR-1 and GSTR-3B returns for consistency</p>
        </div>

        <div class="filter-section">
            <form action="<%=contextPath%>/reports/GST/validation/page1.jsp" method="GET">
                <div class="filter-group">
                    <label>Select Month:</label>
                    <select name="month" id="month" required>
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
                    <label>Select Year:</label>
                    <select name="year" id="year" required>
                        <option value="2023">2023</option>
                        <option value="2024">2024</option>
                        <option value="2025">2025</option>
                        <option value="2026" selected>2026</option>
                        <option value="2027">2027</option>
                    </select>
                </div>
                
                <button type="submit" class="btn-validate">
                    ✅ Run Validation Report
                </button>
            </form>
        </div>

        <div class="info-box">
            <h5>📋 What this report validates:</h5>
            <ul>
                <li>Taxable Value consistency between GSTR-1 and GSTR-3B</li>
                <li>CGST, SGST, IGST totals comparison</li>
                <li>Nil rated, Exempt, and Non-GST supplies</li>
                <li>Input Tax Credit (ITC) verification</li>
                <li>Final tax payable amounts</li>
            </ul>
        </div>
    </div>

    <script>
        // Set current month
        const currentDate = new Date();
        const currentMonth = String(currentDate.getMonth() + 1).padStart(2, '0');
        document.getElementById('month').value = currentMonth;
    </script>
</body>
</html>
