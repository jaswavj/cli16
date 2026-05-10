<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
String contextPath = request.getContextPath();
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

try {
    int productId = Integer.parseInt(request.getParameter("productId"));
    int componentProductId = Integer.parseInt(request.getParameter("componentProductId"));
    double quantity = Double.parseDouble(request.getParameter("quantity"));
    
    if (productId == componentProductId) {
        response.sendRedirect(request.getContextPath() + "/product/master/components/page.jsp?msg=Product+cannot+be+its+own+component&type=warning");
        return;
    }
    
    prod.addProductComponent(productId, componentProductId, quantity, userId);
    response.sendRedirect(request.getContextPath() + "/product/master/components/page.jsp?msg=Component+added+successfully&type=success");
    
} catch (com.mysql.cj.jdbc.exceptions.MysqlDataTruncation e) {
    response.sendRedirect(request.getContextPath() + "/product/master/components/page.jsp?msg=Component+already+exists+for+this+product&type=warning");
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/product/master/components/page.jsp?msg=Error:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>
