<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@page language="java" import="java.util.*" %>
        <jsp:useBean id="bill" class="billing.billingBean" />

        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <title>Products - Billing App</title>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <!-- Bootstrap CSS -->
                <%@ include file="/assets/common/head.jsp" %>

        </head>

        <body>
            <!--%@ include file="../menu/reportMenu.jsp" %-->
    <%@ include file="/assets/navbar/navbar.jsp" %>
    

        <div class="container mt-4">
            <%
    Vector vec = bill.getSalesReportChart();  // Each element is a Vector or ArrayList
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
%>

            <h3 class=" mb-4 text-center">Collection Graph</h3>

                        <div class="card shadow p-4">
                            <canvas id="salesChart" width="600" height="200"></canvas>
                        </div>
                </div>
                <!-- Bootstrap JS -->
                
                <script src="../../dist/js/chart.js"></script>


                <script>
                    const labels = [<%= labels.toString() %>];
                    const salesData = [<%= salesData.toString() %>];

                    const ctx = document.getElementById('salesChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: labels,
                            datasets: [{
                                label: 'Daily Sales (₹)',
                                data: salesData,
                                fill: false,
                                tension: 0.3,
                                backgroundColor: 'rgba(54, 162, 235, 0.6)',
                                borderColor: 'rgba(54, 162, 235, 1)',
                                borderWidth: 2,
                                pointBackgroundColor: 'rgba(54, 162, 235, 1)'
                            }]
                        },
                        options: {
                            responsive: true,
                            plugins: {
                                legend: { display: true },
                                tooltip: { enabled: true }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true
                                }
                            }
                        }
                    });
                </script>




        </body>

        </html>