<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import= "java.util.*"%>
<%@ page language="java" import= "java.math.BigDecimal"%>
<jsp:useBean id="prod" class="product.productBean" />

<%
String idStr = request.getParameter("id");
String unitName = request.getParameter("unitName");
String convertionUnit = request.getParameter("convertionUnit");
String convertionCalculationStr = request.getParameter("convertionCalculation");

try {
    if (idStr != null && unitName != null && !unitName.trim().isEmpty()) {
        int id = Integer.parseInt(idStr);
        BigDecimal convertionCalculation = null;
        if (convertionCalculationStr != null && !convertionCalculationStr.trim().isEmpty()) {
            convertionCalculation = new BigDecimal(convertionCalculationStr.trim());
        }

        prod.updateUnit(id, unitName.trim(), convertionUnit, convertionCalculation);
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Unit updated successfully&type=success");
    } else {
        response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Invalid unit information&type=danger");
    }
} catch (Exception e) {
    e.printStackTrace();
    response.sendRedirect(request.getContextPath() + "/product/master/units/page.jsp?msg=Error: " + e.getMessage() + "&type=danger");
}
%>
