<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Home</title>
	<link rel="stylesheet" href="./../../styles/styles.css">
	
	<!-- Latest minified CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <!-- Bootstrap Packaged JS (Bundle) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
</head>
<body>
	<!-- Session Checkups -->
	<%
	// If there is not a user already loged in, then send him to login!
	if(session.getAttribute("username") == null){
		response.sendRedirect("./../Verification/login.jsp");
	}
	
	// check if the user is loging out
	if(request.getParameter("logout") != null){
		// If user logs out then stop the servers
		CommandLine.stopServers();
		session.removeAttribute("username");
		response.sendRedirect("./../Verification/login.jsp");
	}
	%>
	
	<!-- Get Servers Ready -->
	<%
	// If user logs in successfully then start servers
	if(session.getAttribute("username") != null 
				&& request.getParameter("logout") == null
				&& request.getParameter("startServers") != null){
		CommandLine.startServers();
	}
	%>

	<div class="sidenav">
        <img src="./../../images/LOGO_INVERTED_WHITE.png" alt="LOGO" class="center" style="width:90%;"> 
        <br>
        <div class="username border-bottom"><img src="./../../images/user.png" alt="user image" width="30" height="30" align="left">&nbsp;&nbsp;<%=session.getAttribute("username") %></div>
        <a href="./../Collect/index.jsp" class="border-bottom">Collection</a>
        <a href="./../PreProcess/index.jsp" class="border-bottom">Pre-processing</a>
        <a href="./../MapReduce/index.jsp" class="border-bottom">Processing</a>
        <a href="./../Analyze/index.jsp" class="border-bottom">Analytics</a>
        <a href="./../Visualize/index.jsp" class="border-bottom">Visualization</a>
        <a href="./../ManageData/index.jsp" class="border-bottom">Management</a>
        <a href="./../Verification/login.jsp" class="border-bottom" id="singout">Sign out</a>
    </div>
      
    <div class="main">
        <!-- Always on top -->
        <div class="jumbotron jumbotron-fluid" style="background-color: lightgray;">
            <div class="container">
              <h1 class="display-4">
                <strong>Welcome to EverAnalyzer</strong>
              </h1>
              <p class="lead">Use the side menu to collect, process and visualize your data.</p>
            </div>
        </div>
        <br>
        <img src="./../../images/LOGO.png" alt="LOGO" class="center" style="width:60%;"> 
    </div>
    
    <!-- Event Listener for logout -->
    <script>
    	document.getElementById("singout").addEventListener("click", function() {
    		this.href = "./home.jsp?logout=truee";
    	});
    </script>
</body>
</html>