<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="op1" class="billing.billingBean" />
<%
///////////////////  Sales  /////////////////
double thisSale =op1.getThisMonthPhSale();
double lastSale =op1.getLastMonthPhSale();
double saleMargin =thisSale-lastSale;
double saleMarginPercent = 0;
if (lastSale != 0) {
    saleMarginPercent = (saleMargin / lastSale) * 100;
}
String saleColor = (saleMarginPercent >= 0) ? "green" : "red";
///////////////////  Today's Sales  /////////////////
double todaySales = op1.getTodaySales();
int todayBillCount = op1.getTodayBillCount();

///////////////////  Profit  /////////////////
double thisProfit = op1.getThisMonthProfit();
double lastProfit = op1.getLastMonthProfit();

double profitMargin = thisProfit - lastProfit;
double profitMarginPercent = 0;
if (lastProfit != 0) {
    profitMarginPercent = (profitMargin / lastProfit) * 100;
}
String profitColor = (profitMarginPercent >= 0) ? "green" : "red";

// Get today's date
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd-MMM-yyyy");
String todayDate = sdf.format(new java.util.Date());

/////////////////////  Sales Graph  //////////////////
Vector vec = op1.getSalesReportCharts();  // Each element is a Vector or ArrayList
    StringBuilder labels = new StringBuilder();
    StringBuilder salesData = new StringBuilder();

    for (int i = 0; i < vec.size(); i++) {
        Vector row = (Vector) vec.elementAt(i);
        String date = row.elementAt(0).toString();   // first column is date
        String total = row.elementAt(1).toString();  // second column is total sales

        labels.append("\"").append(date).append("\"");
        if (!total.isEmpty() && !total.equals("0")) {
            salesData.append(total);
        } else {
            salesData.append("0");
        }

        if (i < vec.size() - 1) {
            labels.append(", ");
            salesData.append(", ");
        }
    }

/////////////////////  Top Customers and Suppliers Data  //////////////////
Vector<Vector> topCustomers = op1.getTopCustomers();
Vector<Vector> outstandingCustomers = op1.getOutstandingCustomers();

%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Executive Dashboard</title>
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        /* Custom Dashboard Styles */
        body { background-color: #f8f9fa; }
        .dashboard-card {
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            transition: transform 0.2s;
            overflow: hidden;
            background: white;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.1);
        }
        .card-icon {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            font-size: 3rem;
            opacity: 0.15;
        }
        .trend-indicator {
            font-size: 0.9rem;
            font-weight: 600;
        }
        .trend-up { color: #198754; }
        .trend-down { color: #dc3545; }
        .chart-container {
            background: white;
            border-radius: 12px;
            padding: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            /* height: 100%; Removed to prevent infinite resizing loop */
        }
        .chart-wrapper {
            position: relative;
            height: 250px;
            width: 100%;
        }
        .chart-wrapper-sm {
            position: relative;
            height: 180px;
            width: 100%;
        }
        .welcome-banner {
            background: var(--primary-gradient);
            color: white;
            border-radius: 10px;
            padding: 15px 25px;
            margin-bottom: 20px;
            box-shadow: 0 4px 10px rgba(118, 75, 162, 0.2);
        }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>
    
    <div class="container-fluid py-4 px-4">
        <!-- Welcome Banner -->
        

        <!-- Summary Cards -->
        <div class="row g-4 mb-4">
            <!-- Today's Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-danger">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-1" style="font-size: 0.7rem;">Today's Sales</h6>
                        <p class="text-muted mb-2" style="font-size: 0.65rem; margin-top: -2px;">(<%= todayDate %>)</p>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", todaySales) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="text-muted" style="font-size: 0.7rem;"><i class="fas fa-receipt me-1"></i> <%= todayBillCount %> Bills</span>
                        </div>
                        <i class="fas fa-calendar-day card-icon text-danger" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
            </div>
            
            <!-- Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-primary">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Total Sales (This Month)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisSale) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="trend-indicator <%= saleMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= saleMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(saleMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fas fa-chart-line card-icon text-primary" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
            </div>

             <!-- Last Month Sales Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-warning">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Last Month Sales</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", lastSale) %></h4>
                        <div class="d-flex align-items-center">
                             <span class="text-muted" style="font-size: 0.65rem;">Previous Period</span>
                        </div>
                        <i class="fas fa-history card-icon text-warning" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
            </div>
            
            <!-- Profit Card -->
            <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6">
                <div class="card dashboard-card h-100 border-start border-4 border-success">
                    <div class="card-body position-relative" style="padding: 0.75rem;">
                        <h6 class="text-muted text-uppercase fw-bold mb-2" style="font-size: 0.7rem;">Gross Profit (This Month)</h6>
                        <h4 class="fw-bold text-dark mb-2" style="font-size: 1.1rem;">&#8377; <%= String.format("%,.2f", thisProfit) %></h4>
                        <div class="d-flex align-items-center">
                            <span class="trend-indicator <%= profitMarginPercent >= 0 ? "trend-up" : "trend-down" %> me-1" style="font-size: 0.7rem;">
                                <i class="fas <%= profitMarginPercent >= 0 ? "fa-arrow-up" : "fa-arrow-down" %>"></i> 
                                <%= String.format("%.1f", Math.abs(profitMarginPercent)) %>%
                            </span>
                            <span class="text-muted" style="font-size: 0.65rem;">vs last month</span>
                        </div>
                        <i class="fas fa-chart-pie card-icon text-success" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
            </div>
            
        </div>

        <!-- Charts Section -->
        <div class="row g-4">
            <!-- Sales Overview -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold mb-0">Sales Overview <small class="text-muted">(Last 16 Days)</small></h5>
                        <div class="btn-group btn-group-sm">
                             <button class="btn btn-outline-secondary active">Daily</button>
                        </div>
                    </div>
                    <div class="chart-wrapper">
                        <canvas id="combinedChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Sales Trend -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0">Sales Trend</h5>
                        <button id="downloadMargin" class="btn btn-sm btn-outline-primary"><i class="fas fa-download me-1"></i> Save</button>
                    </div>
                    <div class="chart-wrapper-sm">
                        <canvas id="marginChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Customer Dashboards -->
        <div class="row g-4 mt-1">
            <!-- Top Customers by Sales -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0"><i class="fas fa-users text-primary me-2"></i>Top Customers (This Month)</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Customer Name</th>
                                    <th class="text-end">Total Sales</th>
                                    <th class="text-center">Bills</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (topCustomers.size() == 0) { %>
                                    <tr><td colspan="4" class="text-center text-muted">No data available</td></tr>
                                <% } else {
                                    for (int i = 0; i < topCustomers.size(); i++) {
                                        Vector row = topCustomers.get(i);
                                        String name = (String) row.get(0);
                                        double sales = (Double) row.get(1);
                                        int billCount = (Integer) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        <td class="text-end text-primary fw-bold">&#8377; <%= String.format("%,.2f", sales) %></td>
                                        <td class="text-center"><span class="badge bg-info"><%= billCount %></span></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Outstanding Customer Balances -->
            <div class="col-lg-6">
                <div class="chart-container">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0"><i class="fas fa-money-bill-wave text-warning me-2"></i>Top Outstanding Customers</h5>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 5%;">#</th>
                                    <th>Customer Name</th>
                                    <th class="text-end">Outstanding Amount</th>
                                    
                                </tr>
                            </thead>
                            <tbody>
                                <% if (outstandingCustomers.size() == 0) { %>
                                    <tr><td colspan="3" class="text-center text-muted">No outstanding balances</td></tr>
                                <% } else {
                                    for (int i = 0; i < outstandingCustomers.size(); i++) {
                                        Vector row = outstandingCustomers.get(i);
                                        String name = (String) row.get(0);
                                        double outstanding = (Double) row.get(1);
                                        double pending = (Double) row.get(2);
                                %>
                                    <tr>
                                        <td><%= i + 1 %></td>
                                        <td><strong><%= name %></strong></td>
                                        
                                        <td class="text-end text-warning fw-bold">&#8377; <%= String.format("%,.2f", pending) %></td>
                                    </tr>
                                <% } } %>
                            </tbody>
                            <% if (outstandingCustomers.size() > 0) {
                                double totalOutstanding = 0;
                                for (Vector row : outstandingCustomers) {
                                    totalOutstanding += (Double) row.get(1);
                                }
                            %>
                            <tfoot class="table-light">
                                <tr>
                                    <th colspan="2" class="text-end">Total (Top 5):</th>
                                    <th class="text-end text-danger">&#8377; <%= String.format("%,.2f", totalOutstanding) %></th>
                                </tr>
                            </tfoot>
                            <% } %>
                        </table>
                    </div>
                </div>
            </div>
            
        </div>

    </div>

    <script>
        // Data from Server
        const labels = [<%= labels.toString() %>];
        const salesData = [<%= salesData.toString() %>];
        // Common Chart Options
        const commonOptions = {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'top' },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    backgroundColor: 'rgba(0,0,0,0.8)',
                    padding: 10,
                    cornerRadius: 8,
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { borderDash: [2, 4], color: '#e9ecef' },
                    ticks: { callback: function(value) { return '\u20B9' + value; } }
                },
                x: {
                    grid: { display: false }
                }
            },
            interaction: {
                mode: 'nearest',
                axis: 'x',
                intersect: false
            }
        };

        // 1. Sales Chart
        new Chart(document.getElementById('combinedChart'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Sales',
                        data: salesData,
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointRadius: 0,
                        pointHoverRadius: 6
                    }
                ]
            },
            options: commonOptions
        });

        // 2. Detailed Sales Chart
        const marginChart = new Chart(document.getElementById('marginChart'), {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Sales Collection',
                    data: salesData,
                    backgroundColor: '#667eea',
                    borderRadius: 4,
                    barPercentage: 0.6
                }]
            },
            options: commonOptions
        });

        // Download Handlers
        document.getElementById('downloadMargin').addEventListener('click', function() {
            const link = document.createElement('a');
            link.download = 'sales_chart.png';
            link.href = marginChart.toBase64Image();
            link.click();
        });
    </script>
</body>
</html>
