<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />

<% 
Integer uids=(Integer) session.getAttribute("userId"); 
String modIdParam=request.getParameter("modId"); 
if(uids==null || modIdParam==null || modIdParam.isEmpty()) { 
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
    }
%>

            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Category - Billing App</title>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <!-- Bootstrap CSS -->
                <link href="../../../dist/css/bootstrap.min.css" rel="stylesheet">
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

                    .table td,
                    .table th {
                        vertical-align: middle;
                    }

                    .btn-edit,
                    .btn-delete {
                        margin: 0 2px;
                    }
                </style>

            </head>

            <body>
                <%@ include file="../menu/productMenu.jsp" %>


                    <!-- Bootstrap JS -->
                    <script src="../../dist/js/bootstrap.bundle.min.js"></script>
                    <script src="../../dist/js/chart.js"></script>
            </body>

            </html>