<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Item Report with Barcodes</title>
    <%@ include file="/assets/common/head.jsp" %>

    <style>
        body { background-color: #f8f9fa; }
        .table th { background-color: #4e73df; color: white; }
        
        @media (max-width: 768px) {
            .row.mb-3 .col-md-6 {
                margin-bottom: 0.5rem;
            }
            .row.mb-3 .col-md-6.text-end {
                text-align: left !important;
            }
            .row.mb-3 .col-md-6.text-end button {
                width: 100%;
                margin-bottom: 0.5rem;
            }
        }
    </style>
</head>
<body>

<%@ include file="/assets/navbar/navbar.jsp" %>

<div class="container mt-5">
    <h3 class="text-center mb-4">Item Report</h3>
    
    <div class="row mb-3">
        <div class="col-md-6">
            <input type="text" class="form-control" id="searchBox" placeholder="🔍 Search by item name, code, or barcode..." onkeyup="filterTable()">
        </div>
        <div class="col-md-6 text-end">
            <button id="printQueueBtn" class="btn btn-success" onclick="printAllQueued()">
                <i class="fas fa-print"></i> Print All Queued (<span id="queueCount">0</span>)
            </button>
            <button class="btn btn-warning" onclick="clearQueue()">
                <i class="fas fa-trash"></i> Clear Queue
            </button>
        </div>
    </div>

    <div class="table-responsive">
    <table class="table table-hover mb-0" style="border-collapse: separate; border-spacing: 0; min-width: 700px;">
        <thead style="background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);">
            <tr>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">S.No</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Item Name</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Item Code</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Barcode</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Price (MRP)</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Size/Unit</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Quantity</th>
                <th style="padding: 0.4rem; font-weight: 600; color: #4a5568; border: none; font-size: 0.85rem;" class="text-center">Action</th>
            </tr>
        </thead>
        <tbody id="itemTable"></tbody>
    </table>
    </div>
</div>

<%@ page import="java.sql.*" %>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector itemList = new Vector();
    
    try {
        conn = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT p.name, p.id, p.code, " +
                     "COALESCE(MAX(b.mrp), 0) as mrp, " +
                     "COALESCE(u.name, 'N/A') as unit " +
                     "FROM prod_product p " +
                     "LEFT JOIN prod_batch b ON p.id = b.product_id " +
                     "LEFT JOIN prod_units u ON p.unit_id = u.id " +
                     "WHERE p.is_active = 1 " +
                     "GROUP BY p.id, p.name, p.code, u.name " +
                     "ORDER BY p.name";
        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();
        
        while(rs.next()) {
            Vector item = new Vector();
            item.add(rs.getString("name"));
            item.add(rs.getString("id"));
            item.add(rs.getString("code"));
            item.add(rs.getString("mrp"));
            item.add(rs.getString("unit"));
            itemList.add(item);
        }
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if(rs != null) try { rs.close(); } catch(Exception e) {}
        if(ps != null) try { ps.close(); } catch(Exception e) {}
        if(conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

<script>
const contextPath = '<%=contextPath%>';
const products = [
<% 
for(int i=0; i<itemList.size(); i++) {
    Vector item = (Vector) itemList.get(i);
    // Simple escaping for JavaScript string literals
    String name = item.elementAt(0).toString()
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", " ")
        .replace("\r", " ")
        .replace("\t", " ");
    String id = item.elementAt(1).toString();
    String code = item.elementAt(2).toString()
        .replace("\\", "\\\\")
        .replace("\"", "\\\"");
    String mrp = item.elementAt(3).toString();
    String unit = item.elementAt(4).toString()
        .replace("\\", "\\\\")
        .replace("\"", "\\\"")
        .replace("\n", " ")
        .replace("\r", " ")
        .replace("\t", " ");
%>
["<%= name %>", "<%= id %>", "<%= code %>", "<%= mrp %>", "<%= unit %>"]<%= (i < itemList.size()-1 ? "," : "") %>
<% } %>
];

const tableBody = document.getElementById("itemTable");
const printQueue = [];

// Load table rows with barcodes
products.forEach((p, index) => {
    const [name, id, code, mrp, unit] = p;
    const row = document.createElement("tr");

    row.innerHTML = `
      <td>${index + 1}</td>
      <td>${name}</td>
      <td>${code}</td>
      <td><svg id="barcode-${index}"></svg></td>
      <td>₹${parseFloat(mrp).toFixed(2)}</td>
      <td>${unit}</td>
      <td><input type="number" class="form-control form-control-sm" value="10" min="1"></td>
      <td><button class="btn btn-sm btn-primary" onclick="addToQueue(${index}, '${code}')">Add to Queue</button></td>
    `;

    tableBody.appendChild(row);

    JsBarcode(`#barcode-${index}`, code.toString(), {
        format: "CODE128",
        displayValue: false,
        height: 18,
        width: 0.5
    });
});

// Add to print queue
function addToQueue(index, code) {
    const row = document.getElementById("itemTable").rows[index];
    const qty = parseInt(row.cells[6].querySelector("input").value) || 1;
    
    printQueue.push({ index, code, qty, name: products[index][0], mrp: products[index][3], unit: products[index][4] });
    updateQueueCount();
    
    // Visual feedback
    const btn = row.cells[7].querySelector("button");
    const originalText = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-check"></i> Added!';
    btn.classList.add('btn-success');
    btn.classList.remove('btn-primary');
    
    setTimeout(() => {
        btn.innerHTML = originalText;
        btn.classList.remove('btn-success');
        btn.classList.add('btn-primary');
    }, 1000);
}

// Filter table based on search
function filterTable() {
    const input = document.getElementById("searchBox").value.toUpperCase();
    const table = document.getElementById("itemTable");
    const rows = table.getElementsByTagName("tr");
    
    for (let i = 0; i < rows.length; i++) {
        const nameCell = rows[i].cells[1];
        const codeCell = rows[i].cells[2];
        
        if (nameCell && codeCell) {
            const nameText = nameCell.textContent || nameCell.innerText;
            const codeText = codeCell.textContent || codeCell.innerText;
            
            if (nameText.toUpperCase().indexOf(input) > -1 || codeText.toUpperCase().indexOf(input) > -1) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    }
}

// Update queue count
function updateQueueCount() {
    const total = printQueue.reduce((sum, item) => sum + item.qty, 0);
    document.getElementById("queueCount").textContent = total;
}

// Clear queue
function clearQueue() {
    if(printQueue.length === 0) return;
    if(confirm('Clear all items from print queue?')) {
        printQueue.length = 0;
        updateQueueCount();
    }
}

// Print all queued labels directly to POS thermal printer
function printAllQueued() {
    if(printQueue.length === 0) {
        alert("No items in queue! Add items first.");
        return;
    }

    // Build label data for POS printer
    const labels = printQueue.map(item => ({
        name: item.name || '',
        code: item.code || '',
        barcode: item.code || '',
        mrp: String(parseFloat(item.mrp) || 0),
        unit: item.unit || '',
        qty: parseInt(item.qty) || 1
    }));

    const totalLabels = labels.reduce((sum, l) => sum + l.qty, 0);

    // Disable button and show sending status
    const printBtn = document.getElementById('printQueueBtn');
    const originalBtnText = printBtn.innerHTML;
    printBtn.disabled = true;
    printBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending to printer...';

    // Send to POS printer via printBarcode.jsp
    fetch(contextPath + '/product/master/barCode/printBarcode.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ labels: labels })
    })
    .then(resp => resp.json())
    .then(data => {
        printBtn.disabled = false;
        if(data.status === 'success') {
            printBtn.innerHTML = originalBtnText;
            
            if(confirm('Printed ' + totalLabels + ' labels successfully!\nClear the print queue?')) {
                printQueue.length = 0;
                updateQueueCount();
            }
        } else {
            alert('Print failed: ' + (data.message || 'Unknown error'));
            printBtn.innerHTML = originalBtnText;
        }
    })
    .catch(err => {
        printBtn.disabled = false;
        printBtn.innerHTML = originalBtnText;
        alert('Print error: ' + err.message);
    });
}

function escapeHtml(str) {
    if (!str) return '';
    return String(str).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function escapeJs(str) {
    if (!str) return '';
    return String(str).replace(/\\/g,'\\\\').replace(/"/g,'\\"').replace(/'/g,"\\'");
}

</script>

</body>
</html>
