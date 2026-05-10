<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
try {
    int id = Integer.parseInt(request.getParameter("id"));
    int productId = Integer.parseInt(request.getParameter("productId"));
    String productName = request.getParameter("productName");
    
    prod.deleteProductComponent(id);
    response.sendRedirect(request.getContextPath() + "/product/master/components/viewComponents.jsp?productId=" + productId + "&productName=" + java.net.URLEncoder.encode(productName, "UTF-8") + "&msg=Component+deleted&type=success");
    
} catch (Exception e) {
    response.sendRedirect(request.getContextPath() + "/product/master/components/page.jsp?msg=Error:+" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8") + "&type=danger");
}
%>
