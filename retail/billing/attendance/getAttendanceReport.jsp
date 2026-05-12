<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="bill" class="billing.billingBean" />
<jsp:useBean id="user" class="user.userBean" />
<%
Integer uid = (Integer) session.getAttribute("userId");

// Load permissions from database
Vector vecPer = user.getUserPermission(uid);
Set<Integer> permissions = new HashSet<Integer>();
for (int i = 0; i < vecPer.size(); i++) {
    Vector cat = (Vector) vecPer.get(i);
    int modId = Integer.parseInt(cat.elementAt(0).toString());
    permissions.add(modId);
}
boolean isAdmin = permissions.contains(8); // Admin permission

String fromDate = request.getParameter("fromDate");
String toDate = request.getParameter("toDate");
String userFilter = request.getParameter("userId");

if (fromDate == null) fromDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
if (toDate == null) toDate = fromDate;

if (uid == null) {
    out.print("[]");
    return;
}

try {
    Vector data = bill.getAttendanceReport(fromDate, toDate, uid, isAdmin, userFilter);
    
    org.json.JSONArray json = new org.json.JSONArray();
    for (int i = 0; i < data.size(); i++) {
        Vector row = (Vector) data.elementAt(i);
        org.json.JSONObject obj = new org.json.JSONObject();
        obj.put("date", row.elementAt(0));
        obj.put("inTime", row.elementAt(1) != null ? row.elementAt(1).toString() : null);
        obj.put("outTime", row.elementAt(2) != null ? row.elementAt(2).toString() : null);
        obj.put("userName", row.elementAt(3));
        json.put(obj);
    }
    out.print(json.toString());
} catch (Exception e) {
    out.print("[]");
}
%>
