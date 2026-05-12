<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="user" class="user.userBean" />
<%
response.setContentType("application/json");

try {
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        out.print("[]");
        return;
    }

    // Get all users
    Vector allUsers = user.getAllUsersWithDiscount();
    
    out.print("[");
    boolean first = true;
    
    if (allUsers != null && allUsers.size() > 0) {
        for (int i = 0; i < allUsers.size(); i++) {
            Vector userRow = (Vector) allUsers.get(i);
            if (userRow.size() >= 2) {
                int userId = Integer.parseInt(userRow.elementAt(0).toString());
                String userName = userRow.elementAt(1).toString();
                
                if (!first) out.print(",");
                out.print("{\"id\":" + userId + ",\"name\":\"" + userName.replace("\"", "\\\"") + "\"}");
                first = false;
            }
        }
    }
    
    out.print("]");
} catch (Exception e) {
    out.print("[]");
}
%>
