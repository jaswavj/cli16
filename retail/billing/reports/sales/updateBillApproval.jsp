<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<%
request.setCharacterEncoding("UTF-8");
String kind = request.getParameter("kind");
String billIdParam = request.getParameter("billId");
String dueCollectionIdParam = request.getParameter("dueCollectionId");

if (kind == null || kind.trim().isEmpty()) {
    kind = "bill";
}

try {
    boolean updated = false;

    if ("due".equalsIgnoreCase(kind)) {
        if (dueCollectionIdParam == null || dueCollectionIdParam.trim().isEmpty()) {
            out.print("ERROR: Missing dueCollectionId");
            return;
        }
        int dueCollectionId = Integer.parseInt(dueCollectionIdParam);
        updated = bill.markDueCollectionApproved(dueCollectionId);
    } else {
        if (billIdParam == null || billIdParam.trim().isEmpty()) {
            out.print("ERROR: Missing billId");
            return;
        }
        int billId = Integer.parseInt(billIdParam);
        updated = bill.markBillApproved(billId);
    }

    if (updated) {
        out.print("OK");
    } else {
        out.print("ERROR: Record not found");
    }
} catch (NumberFormatException e) {
    out.print("ERROR: Invalid id");
} catch (Exception e) {
    out.print("ERROR: " + e.getMessage());
}
%>
