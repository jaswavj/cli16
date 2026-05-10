<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="javax.print.*"%>
<%@ page import="javax.print.attribute.*"%>
<%@ page import="javax.print.attribute.standard.*"%>
<%@ page import="java.io.*"%>
<!DOCTYPE html>
<html>
<head>
    <title>Printer Test</title>
    <style>
        body { font-family: monospace; padding: 20px; background: #f0f0f0; }
        .success { color: green; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        pre { background: #fff; padding: 10px; border: 1px solid #ddd; }
        .card { background: white; border: 1px solid #ccc; padding: 15px; margin: 10px 0; border-radius: 5px; }
        .highlight { background: #ffffcc; padding: 10px; border: 2px solid #ff9900; margin: 10px 0; }
        button { padding: 8px 16px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 3px; }
        button:hover { background: #0056b3; }
        table { border-collapse: collapse; }
        td, th { border: 1px solid #ddd; padding: 8px; }
    </style>
</head>
<body>
    <h2>Printer Diagnostic - Test ALL Methods</h2>
    
    <%
    try {
        PrintService[] services = PrintServiceLookup.lookupPrintServices(null, null);
        
        // Full ESC/POS test: INIT + bold center text + feed + FULL CUT
        byte[] testData = new byte[]{
            0x1B, 0x40,              // ESC @ - Initialize printer
            0x1B, 0x61, 0x01,        // ESC a 1 - Center align
            0x1B, 0x45, 0x01,        // ESC E 1 - Bold ON
            'T', 'E', 'S', 'T', ' ', 'P', 'R', 'I', 'N', 'T', '\n',
            0x1B, 0x45, 0x00,        // ESC E 0 - Bold OFF
            0x1B, 0x61, 0x00,        // Left align
            'P', 'r', 'i', 'n', 't', 'e', 'r', ' ', 'O', 'K', '\n',
            0x1B, 0x64, 0x04,        // Feed 4 lines before cut
            0x1D, 0x56, 0x41, 0x10   // GS V A 16 - Full cut
        };
        
        String testPrinter = request.getParameter("testPrinter");
        String method = request.getParameter("method");
        
        if (testPrinter != null && method != null) {
            out.println("<div class='card'>");
            out.println("<h3>Testing: " + testPrinter + " (" + method + ")</h3>");
            
            if ("java".equals(method)) {
                PrintService selectedService = null;
                for (PrintService svc : services) {
                    if (svc.getName().equals(testPrinter)) { selectedService = svc; break; }
                }
                if (selectedService != null) {
                    // Show raw/GDI driver diagnostic
                    DocFlavor[] supportedFlavors = selectedService.getSupportedDocFlavors();
                    boolean supportsRaw = false;
                    boolean supportsAutoSense = false;
                    StringBuilder flavorsHtml = new StringBuilder();
                    for (DocFlavor f : supportedFlavors) {
                        String fs = f.toString();
                        flavorsHtml.append("<li>").append(fs).append("</li>");
                        if (fs.contains("AUTOSENSE") || fs.contains("autosense")) supportsAutoSense = true;
                        if (fs.contains("octet-stream") || fs.contains("raw")) supportsRaw = true;
                    }
                    if (supportsAutoSense || supportsRaw) {
                        out.println("<p class='success'><b>Driver: RAW/AUTOSENSE supported</b> - ESC/POS bytes will reach printer directly</p>");
                    } else {
                        out.println("<p class='error'><b>Driver: GDI / no raw support</b> - ESC/POS bytes will be BLOCKED by driver. Please install Generic/Text Only driver!</p>");
                    }
                    out.println("<details><summary>Supported flavors (" + supportedFlavors.length + ")</summary><ul>" + flavorsHtml + "</ul></details>");

                    try {
                        DocFlavor flavor = DocFlavor.BYTE_ARRAY.AUTOSENSE;
                        Doc doc = new SimpleDoc(testData, flavor, null);
                        DocPrintJob job = selectedService.createPrintJob();
                        job.print(doc, null);
                        out.println("<p class='success'>Java Print: job accepted (no exception). <b>Did paper come out with CUT?</b></p>");
                    } catch (Exception e) {
                        out.println("<p class='error'>Java Print FAILED: " + e.getMessage() + "</p>");
                    }
                }
            } else if ("direct".equals(method)) {
                try {
                    String sharePath = "\\\\localhost\\" + testPrinter;
                    out.println("<p>Writing to: " + sharePath + "</p>");
                    FileOutputStream fos = new FileOutputStream(new File(sharePath));
                    fos.write(testData);
                    fos.flush();
                    fos.close();
                    out.println("<p class='success'>Direct write SUCCESS! <b>Did paper come out with CUT?</b></p>");
                } catch (Exception e) {
                    out.println("<p class='error'>Direct write FAILED: " + e.getMessage() + "</p>");
                }
            } else if ("wincopy".equals(method)) {
                try {
                    File tempFile = File.createTempFile("prntest", ".bin");
                    FileOutputStream fos = new FileOutputStream(tempFile);
                    fos.write(testData);
                    fos.close();
                    
                    String[] cmd = {"cmd", "/c", "copy", "/b", tempFile.getAbsolutePath(), "\\\\localhost\\" + testPrinter};
                    out.println("<p>Command: copy /b " + tempFile.getName() + " \\\\localhost\\" + testPrinter + "</p>");
                    
                    Process proc = Runtime.getRuntime().exec(cmd);
                    proc.waitFor();
                    
                    BufferedReader br = new BufferedReader(new InputStreamReader(proc.getInputStream()));
                    BufferedReader brErr = new BufferedReader(new InputStreamReader(proc.getErrorStream()));
                    String line;
                    StringBuilder output = new StringBuilder();
                    while ((line = br.readLine()) != null) output.append(line).append("\n");
                    while ((line = brErr.readLine()) != null) output.append("ERR: ").append(line).append("\n");
                    
                    tempFile.delete();
                    
                    if (proc.exitValue() == 0) {
                        out.println("<p class='success'>Windows COPY SUCCESS! Exit: 0. <b>Did paper come out with CUT?</b></p>");
                    } else {
                        out.println("<p class='error'>Windows COPY FAILED! Exit: " + proc.exitValue() + "</p>");
                    }
                    if (output.length() > 0) out.println("<pre>" + output.toString() + "</pre>");
                } catch (Exception e) {
                    out.println("<p class='error'>Windows COPY error: " + e.getMessage() + "</p>");
                }
            }
            
            out.println("<p><strong>Did paper come out? If yes, this method works!</strong></p>");
            out.println("<p><a href='testPrint.jsp'><button>Back to Test Page</button></a></p>");
            out.println("</div>");
            
        } else {
            // MAIN PAGE
            out.println("<div class='highlight'>");
            out.println("<h3>You have " + services.length + " printers. Try EACH one below!</h3>");
            out.println("<p><strong>THERMAL PRINTER</strong> and <strong>SNBC TVSE LP 46 NEO BPLE</strong> may be different drivers for same physical printer.</p>");
            out.println("<p>One of them should actually print. Try all buttons!</p>");
            out.println("<p style='color:red'><b>NOTE:</b> Test now sends ESC/POS commands <b>including FULL CUT</b>. If paper does NOT come out after a successful test, the driver is GDI (not raw) and blocks ESC/POS bytes. You must install <b>Generic / Text Only</b> driver for that printer in Windows.</p>");
            out.println("</div>");
            
            out.println("<table>");
            out.println("<tr><th>Printer</th><th>Java Print Service</th><th>Direct Write</th><th>Windows COPY</th></tr>");
            
            for (int i = 0; i < services.length; i++) {
                String name = services[i].getName();
                // Skip non-thermal printers
                if (name.contains("XPS") || name.contains("Fax")) continue;
                
                String bg = name.equals("THERMAL PRINTER") ? " style='background:#ccffcc'" : 
                            name.contains("SNBC") ? " style='background:#ffffcc'" : "";
                String label = name.equals("THERMAL PRINTER") ? name + " ← TRY FIRST!" : name;
                String enc = java.net.URLEncoder.encode(name, "UTF-8");
                
                out.println("<tr" + bg + ">");
                out.println("<td><strong>" + label + "</strong></td>");
                out.println("<td><a href='testPrint.jsp?testPrinter=" + enc + "&method=java'><button>Test Java</button></a></td>");
                out.println("<td><a href='testPrint.jsp?testPrinter=" + enc + "&method=direct'><button>Test Direct</button></a></td>");
                out.println("<td><a href='testPrint.jsp?testPrinter=" + enc + "&method=wincopy'><button>Test WinCopy</button></a></td>");
                out.println("</tr>");
            }
            out.println("</table>");
            
            out.println("<div class='card'>");
            out.println("<p><strong>Test each button one by one. Tell me which one prints paper!</strong></p>");
            out.println("</div>");
        }
        
    } catch (Exception e) {
        out.println("<p class='error'>ERROR: " + e.getMessage() + "</p>");
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    }
    %>
</body>
</html>
