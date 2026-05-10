<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*, java.sql.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
String currentMonth = new SimpleDateFormat("MMM yy").format(new Date());

// Fetch GSTIN details from gstin table
Vector gstinList = new Vector();
try {
    Connection con = prod.check();
    PreparedStatement pt = con.prepareStatement("SELECT id, gstin, shop_name FROM company_details ORDER BY id LIMIT 1");
    ResultSet rs = pt.executeQuery();
    while(rs.next()) {
        Vector vec = new Vector();
        vec.addElement(rs.getString("id"));
        vec.addElement(rs.getString("gstin"));
        vec.addElement(rs.getString("shop_name"));
        gstinList.addElement(vec);
    }
    rs.close();
    pt.close();
    con.close();
} catch(Exception e) {
    e.printStackTrace();
}

String defaultGSTIN = "";
String defaultShopName = "";
if(gstinList.size() > 0) {
    Vector firstGSTIN = (Vector)gstinList.elementAt(0);
    defaultGSTIN = (String)firstGSTIN.elementAt(1);
    defaultShopName = (String)firstGSTIN.elementAt(2);
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GSTR-1 Report - Filter</title>
<%@ include file="/assets/common/head.jsp" %>
<style>
    .filter-card {
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        border-radius: 10px;
        padding: 2rem;
        background: white;
    }
</style>
</head>
<body> 
    <%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-5">
    <h3 class="mb-4">GSTR-1 Return Report</h3>

    <div class="filter-card">
        <form action="<%=contextPath%>/reports/GST/gstr1/page1.jsp" method="get">
            <div class="row g-3">
                <div class="col-md-6">
                    <label for="startDate" class="form-label">Start Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" value="<%=today%>" id="startDate" name="startDate" required>
                </div>
                <div class="col-md-6">
                    <label for="endDate" class="form-label">End Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" value="<%=today%>" id="endDate" name="endDate" required>
                </div>
                <div class="col-md-6">
                    <label for="period" class="form-label">Period</label>
                    <input type="text" class="form-control" id="period" name="period" value="<%=currentMonth%>" placeholder="e.g., Jan 26">
                </div>
                <div class="col-md-6">
                    <label for="gstin" class="form-label">GSTIN <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="gstin" name="gstin" value="<%=defaultGSTIN%>" required readonly>
                </div>
                <div class="col-md-12">
                    <label for="shopName" class="form-label">Trade Name</label>
                    <input type="text" class="form-control" id="shopName" name="shopName" value="<%=defaultShopName%>" readonly>
                </div>
                <div class="col-md-12 text-center mt-4">
                    <button type="submit" class="btn btn-primary btn-lg px-5">
                        🔍 Generate GSTR-1 Report
                    </button>
                </div>
            </div>
        </form>
    </div>

    <div class="alert alert-info mt-4">
        <h5>📋 Report Sections:</h5>
        <ul class="mb-0">
            <li><strong>B2B:</strong> Sales to registered customers (with GSTIN)</li>
            <li><strong>B2CL:</strong> Sales to unregistered customers (invoice > ₹2.5 Lakhs)</li>
            <li><strong>B2CS:</strong> Sales to unregistered customers (invoice ≤ ₹2.5 Lakhs) - Consolidated</li>
            <li><strong>Credit/Debit Notes:</strong> Adjustments and amendments</li>
            <li><strong>Nil Rated/Exempt:</strong> Sales with 0% GST</li>
            <li><strong>HSN Summary:</strong> Product-wise summary by HSN code</li>
        </ul>
    </div>
</div>

</body>
</html>
