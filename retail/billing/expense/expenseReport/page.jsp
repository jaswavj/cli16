<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<%@ page import="java.text.SimpleDateFormat, java.util.Date, java.text.DecimalFormat" %>
<jsp:useBean id="prod" class="product.productBean" />
<%
// Session check
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
String contextPath = request.getContextPath();

// Get filter parameters
String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
String expenseTypeFilter = request.getParameter("expenseType");

// Set defaults
if (fromDate == null || fromDate.isEmpty()) {
    fromDate = today;
}
if (toDate == null || toDate.isEmpty()) {
    toDate = today;
}
if (expenseTypeFilter == null) {
    expenseTypeFilter = "0";
}

// Fetch expense data
Vector expenseData = null;
double totalAmount = 0.0;
DecimalFormat df = new DecimalFormat("#,##0.00");
String selectedExpenseTypeName = "All Types";

try {
    int expenseTypeId = Integer.parseInt(expenseTypeFilter);
    expenseData = prod.getExpenseReport(fromDate, toDate, expenseTypeId);
    
    // Get expense type name
    if (expenseTypeId != 0) {
        Vector expTypes = prod.getExpenseTypeList();
        for (int i = 0; i < expTypes.size(); i++) {
            Vector expType = (Vector) expTypes.get(i);
            int typeId = Integer.parseInt(expType.elementAt(1).toString());
            if (typeId == expenseTypeId) {
                selectedExpenseTypeName = expType.elementAt(0).toString();
                break;
            }
        }
    }
    
    // Debug output
    System.out.println("Expense Report Query - From: " + fromDate + ", To: " + toDate + ", Type: " + expenseTypeId);
    System.out.println("Records found: " + (expenseData != null ? expenseData.size() : 0));
    
    // Calculate total
    if (expenseData != null) {
        for (int i = 0; i < expenseData.size(); i++) {
            Vector row = (Vector) expenseData.get(i);
            if (row.size() > 4) {
                totalAmount += Double.parseDouble(row.get(4).toString());
            }
        }
    }
} catch (Exception e) {
    System.err.println("Error loading expense data: " + e.getMessage());
    e.printStackTrace();
    out.println("<!-- Error loading expense data: " + e.getMessage() + " -->");
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Expense Report - Billing App</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <jsp:include page="/assets/common/head.jsp" />
    
    <style>
        .report-summary {
            background: white;
            color: #2d3748;
            padding: 0.75rem;
            border-radius: 8px;
            margin-bottom: 1rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);
        }
        
        .summary-card {
            background: #f7fafc;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 0.625rem 0.75rem;
            text-align: center;
        }
        
        .summary-value {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.125rem;
            color: #624b88;
        }
        
        .summary-label {
            font-size: 0.75rem;
            color: #718096;
            font-weight: 500;
        }
        
        .table-container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .table thead th {
            background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);
            font-weight: 600;
            color: #4a5568;
            border: none;
            padding: 1rem;
        }
        
        .table tbody td {
            padding: 0.875rem 1rem;
            vertical-align: middle;
            border-color: #f1f5f9;
        }
        
        .table tbody tr:hover {
            background-color: #f7fafc;
        }
        
        .expense-badge {
            padding: 0.375rem 0.75rem;
            border-radius: 6px;
            font-weight: 500;
            font-size: 0.875rem;
            display: inline-block;
        }
        
        .print-hide {
            /* Hide when printing */
        }
        
        @media print {
            .print-hide {
                display: none !important;
            }
            
            body {
                background: white;
            }
            
            .table-container {
                box-shadow: none;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/assets/navbar/navbar.jsp" />

    <div class="container-fluid mt-3" style="max-width: 1400px;">
        
        <!-- Filter Section -->
        <div class="card print-hide mb-3" style="border: none; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); border-radius: 12px;">
            
            <div class="card-body" style="padding: 1.5rem;">
                <form method="get" class="row g-3">
                    <div class="col-md-3">
                        <label for="fromDate" class="form-label" style="font-weight: 600; color: #4a5568;">From Date</label>
                        <input type="date" id="fromDate" name="fromDate" value="<%=fromDate%>" class="form-control" required style="padding: 0.625rem; border: 2px solid #e2e8f0; border-radius: 8px;">
                    </div>

                    <div class="col-md-3">
                        <label for="toDate" class="form-label" style="font-weight: 600; color: #4a5568;">To Date</label>
                        <input type="date" id="toDate" name="toDate" value="<%=toDate%>" class="form-control" required style="padding: 0.625rem; border: 2px solid #e2e8f0; border-radius: 8px;">
                    </div>

                    <div class="col-md-4">
                        <label for="expenseType" class="form-label" style="font-weight: 600; color: #4a5568;">Expense Type</label>
                        <select id="expenseType" name="expenseType" class="form-select" style="padding: 0.625rem; border: 2px solid #e2e8f0; border-radius: 8px;">
                            <option value="0" <%= expenseTypeFilter.equals("0") ? "selected" : "" %>>-- All Expense Types --</option>
                            <%
                            try {
                                Vector expTypes = prod.getExpenseTypeList();
                                for (int i = 0; i < expTypes.size(); i++) {
                                    Vector expType = (Vector) expTypes.get(i);
                                    String typeName = expType.elementAt(0).toString();
                                    String typeId = expType.elementAt(1).toString();
                                    String selected = expenseTypeFilter.equals(typeId) ? "selected" : "";
                            %>
                                <option value="<%=typeId%>" <%= selected %>><%=typeName%></option>
                            <%
                                }
                            } catch (Exception e) {
                                out.println("<option value='0'>Error loading expense types</option>");
                            }
                            %>
                        </select>
                    </div>

                    <div class="col-md-2 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary w-100" style="padding: 0.625rem; border-radius: 8px; background: #624b88; border: none;">
                            <i class="fas fa-search me-2"></i>Generate
                        </button>
                    </div>
                </form>
            </div>
        </div>

       
        

        <!-- Summary Section -->
        <div class="report-summary">
            <div class="row g-2">
                <div class="col-md-3">
                    <div class="summary-card">
                        <div class="summary-value"><%= expenseData != null ? expenseData.size() : 0 %></div>
                        <div class="summary-label">Total Entries</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="summary-card">
                        <div class="summary-value">₹ <%= df.format(totalAmount) %></div>
                        <div class="summary-label">Total Expense Amount</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="summary-card">
                        <div class="summary-value" style="font-size: 1rem;"><%= selectedExpenseTypeName %></div>
                        <div class="summary-label">Expense Type</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="summary-card">
                        <div class="summary-value"><%= new SimpleDateFormat("dd/MM/yy").format(new SimpleDateFormat("yyyy-MM-dd").parse(fromDate)) %> - <%= new SimpleDateFormat("dd/MM/yy").format(new SimpleDateFormat("yyyy-MM-dd").parse(toDate)) %></div>
                        <div class="summary-label">Report Period</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Data Table -->
        <div class="table-container">
            <div class="p-3 d-flex justify-content-between align-items-center border-bottom print-hide" style="background: #f7fafc;">
                <h5 class="mb-0" style="color: #2d3748; font-weight: 600;"><i class="fas fa-table me-2"></i>Expense Details</h5>
                <button onclick="window.print()" class="btn btn-sm" style="border-radius: 6px; background: #624b88; color: white; border: none;">
                    <i class="fas fa-print me-2"></i>Print Report
                </button>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th style="width: 5%;">#</th>
                            <th style="width: 12%;">Date</th>
                            <th style="width: 15%;">Expense Type</th>
                            <th style="width: 20%;">Content</th>
                            <th style="width: 30%;">Description</th>
                            <th style="width: 12%;" class="text-end">Amount</th>
                            <th style="width: 10%;">Entry By</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (expenseData != null && expenseData.size() > 0) {
                            for (int i = 0; i < expenseData.size(); i++) {
                                Vector row = (Vector) expenseData.get(i);
                                // Expected columns: exp_date_time, expense_type_name, content, description, amount, username
                                String expDateTime = row.get(0).toString();
                                String expenseTypeName = row.get(1).toString();
                                String content = row.get(2).toString();
                                String description = row.get(3) != null ? row.get(3).toString() : "";
                                double amount = Double.parseDouble(row.get(4).toString());
                                String username = row.get(5).toString();
                        %>
                        <tr>
                            <td style="color: #718096; font-weight: 500;"><%=i+1%></td>
                            <td style="color: #2d3748; font-weight: 500;">
                                <i class="far fa-calendar me-1" style="color: #624b88;"></i>
                                <%= new SimpleDateFormat("dd MMM yyyy HH:mm").format(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(expDateTime)) %>
                            </td>
                            <td>
                                <span class="expense-badge" style="background: #e6f7ff; color: #0066cc;">
                                    <%= expenseTypeName %>
                                </span>
                            </td>
                            <td style="color: #2d3748; font-weight: 500;"><%=content%></td>
                            <td style="color: #718096; font-size: 0.9rem;"><%=description.isEmpty() ? "-" : description%></td>
                            <td class="text-end" style="color: #e53e3e; font-weight: 600; font-size: 1rem;">
                                ₹ <%= df.format(amount) %>
                            </td>
                            <td style="color: #718096;">
                                <i class="fas fa-user-circle me-1"></i><%=username%>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="7" class="text-center py-5" style="color: #718096;">
                                <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                <p class="mb-0">No expense entries found for the selected period.</p>
                            </td>
                        </tr>
                        <%
                        }
                        %>
                    </tbody>
                    <% if (expenseData != null && expenseData.size() > 0) { %>
                    <tfoot style="background: #f7fafc; border-top: 2px solid #e2e8f0;">
                        <tr>
                            <th colspan="5" class="text-end" style="padding: 1rem; font-weight: 600; color: #2d3748;">Grand Total:</th>
                            <th class="text-end" style="padding: 1rem; color: #e53e3e; font-size: 1.1rem; font-weight: 700;">
                                ₹ <%= df.format(totalAmount) %>
                            </th>
                            <th></th>
                        </tr>
                    </tfoot>
                    <% } %>
                </table>
            </div>
        </div>
    </div>

</body>
</html>
