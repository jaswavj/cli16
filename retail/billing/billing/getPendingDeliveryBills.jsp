<%@ page import="java.sql.*, org.json.*, java.util.*" %>
<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        out.print("{\"error\":\"Session expired\"}");
        return;
    }

    con = util.DBConnectionManager.getConnectionFromPool();
    String sql = "SELECT id, bill_display, date, time, IFNULL(cusName,'-') AS cusName, IFNULL(cusPhn,'-') AS cusPhn, " +
                 "IFNULL(payable,0) AS payable, delivery_date, delivered_date, IFNULL(is_downloaded,0) AS is_downloaded, download_date, " +
                 "IFNULL(delivery_place,'') AS delivery_place, IFNULL(delivery_person,'') AS delivery_person, IFNULL(photo_count,0) AS photo_count " +
                 "FROM prod_bill " +
                 "WHERE IFNULL(is_cancelled,0)=0 AND IFNULL(is_delivered,0)=0 " +
                 "ORDER BY date DESC, time DESC";

    ps = con.prepareStatement(sql);
    rs = ps.executeQuery();

    JSONArray arr = new JSONArray();
    while (rs.next()) {
        JSONObject obj = new JSONObject();
        obj.put("id", rs.getInt("id"));
        obj.put("billNo", rs.getString("bill_display"));
        obj.put("date", rs.getString("date"));
        obj.put("time", rs.getString("time"));
        obj.put("customerName", rs.getString("cusName"));
        obj.put("customerPhone", rs.getString("cusPhn"));
        obj.put("payable", rs.getDouble("payable"));
        obj.put("deliveryPlace", rs.getString("delivery_place"));
        obj.put("deliveryPerson", rs.getString("delivery_person"));

        java.sql.Date deliveryDate = rs.getDate("delivery_date");
        obj.put("deliveryDate", deliveryDate != null ? deliveryDate.toString() : "");
        java.sql.Date deliveredDate = rs.getDate("delivered_date");
        obj.put("deliveredDate", deliveredDate != null ? deliveredDate.toString() : "");
        obj.put("isDownloaded", rs.getInt("is_downloaded") == 1 ? 1 : 0);

        java.sql.Date downloadDate = rs.getDate("download_date");
        obj.put("downloadDate", downloadDate != null ? downloadDate.toString() : "");
        obj.put("photoCount", rs.getInt("photo_count"));
        arr.put(obj);
    }

    out.print(arr.toString());
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.print("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) { ; }
    if (ps != null) try { ps.close(); } catch (Exception e) { ; }
    if (con != null) try { con.close(); } catch (Exception e) { ; }
}
%>
