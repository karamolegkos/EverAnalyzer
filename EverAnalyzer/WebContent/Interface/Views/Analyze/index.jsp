<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.Tools" %>
<%@ page import="ever.lib.Dataset" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Analytics</title>
	<link rel="stylesheet" href="./../../styles/styles.css">
	<link rel="stylesheet" href="./../../styles/metadata.css">
	
	<!-- Latest minified CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <!-- Bootstrap Packaged JS (Bundle) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

	<!-- jQuery -->
	<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
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
	
	<!-- Collection existance checkup -->
	<%
	boolean noPreprocesses = true;
	Dataset[] preprocesses = new Dataset[0];
	if(session.getAttribute("username") != null){
		String username = (String)session.getAttribute("username");
		
		// Check for existing Pre-proccesd Data of the user
		if(MongoClass.datasetExists(username, Tools.PREPROCESSED_DATASET)){
			noPreprocesses = false;
			preprocesses = MongoClass.getDatasets(username, Tools.PREPROCESSED_DATASET);
		}
	}
	%>
	
	<!-- Dataset Selection -->
	<%
	// check if the user selected a Dataset
	if(request.getParameter("datasetButton")!=null){
		// show the user his Dataset
		response.sendRedirect("./DatasetForm/dataset.jsp?dataset="+request.getParameter("selectedDataset")+
				"&size="+request.getParameter("selectedDatasetSize"));
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
              <strong>Analytics</strong>
            </h1>
            <p class="lead">
            	Do Analytic jobs using EverAnalyzer.
            </p>
          </div>
        </div>
        
        <!-- Pre-process choice Form -->
        <div class="container border border-dark">
        
        	<!-- No collections Warning -->
            <div class="container" style="font-size: medium;">
            	<div class="alert alert-warning" role="alert" id="noPreprocessesWarning" style = "display:none; margin-top: 12px;">
				  To make analytics, you need to pre-process data in the <u>"Pre-process"</u> tab.<br>
				  You need to have Pre-processed Data to Analyze them.
				</div>
            </div>
            
            <!-- Existing Pre-processings -->
            <div class="container datasets" id="existingContainers" style="display:none;">
            
            	<%for(int i=0; i<preprocesses.length; i++){ %>
            
            	<!-- Dataset Template -->
            	<div class="container rounded dataset">
            	
            		<!-- Dataset metadata (label, date) -->
            		<div class="container">
            			<div class="row border border-dark">
	            			<div class="col-lg-6">
	            				Label: <span class="rounded metadata"><%=preprocesses[i].getLabel()%></span>
	            			</div>
	            			<div class="col-lg-6">
	            				Date: <span class="rounded metadata"><%=preprocesses[i].getDate()%></span>
	            			</div>
	            		</div>
            		</div>
            		
            		<!-- Dataset metadata (amount, size) -->
            		<div class="container">
            			<div class="row border border-dark">
	            			<div class="col-lg-6">
	            				Pre-process Tweets amount: <span class="rounded metadata"><%=preprocesses[i].getAmount()%></span>
	            			</div>
	            			<div class="col-lg-6">
	            				Pre-process Size: <span class="rounded metadata"><%=preprocesses[i].getSize()%> bytes</span>
	            			</div>
	            		</div>
            		</div>
            		
            		<!-- Dataset metadata (fields) -->
            		<div class="container border border-dark">
            			Pre-processing Fields: 
            			
            			<% 
            			String[] fields = preprocesses[i].getFields();
            			for(int j=0; j<fields.length; j++){	
            			%>
            			<span class="rounded metadata"><%=fields[j]%></span>  
            			<%}%>
            			
            		</div>
            		
            		<!-- Dataset metadata (parentLabel, keywords) -->
            		<div class="container">
            			<div class="row border border-dark">
	            			<div class="col-lg-6">
	            				Collection Label: <span class="rounded metadata"><%=preprocesses[i].getParentLabel()%></span>
	            			</div>
	            			<div class="col-lg-6">
	            				Collection Words: 
		            			<% 
		            			String[] keywords = preprocesses[i].getKeywords();
		            			for(int j=0; j<keywords.length; j++){	
		            			%>
		            			<span class="rounded metadata"><%=keywords[j]%></span>  
		            			<%}%>
	            			</div>
	            		</div>
            		</div>
            		
            		<!-- Dataset Selector -->
            		<form class="form-group container">
            			<input class="btn btn-dark" type="submit" value="Select Dataset" name="datasetButton">
            			<input type="hidden" id="selectedDataset" name="selectedDataset" value="<%=preprocesses[i].getLabel()%>">
            			<input type="hidden" id="selectedDatasetSize" name="selectedDatasetSize" value="<%=preprocesses[i].getSize()%>">
            		</form>
            		
            	</div>
            	
            	<%
            	if(i != (preprocesses.length - 1)){
            		%><br><%
            	}
            	%>
            	<% } %>
            </div>
        </div>
    </div>
    
    <!-- Event Listener for logout -->
    <script>
    	document.getElementById("singout").addEventListener("click", function() {
    		this.href = "./index.jsp?logout=truee";
    	});
    </script>
    
    <!-- Check to find if there are Datasets -->
    <script>
	    let noPreprocesses = <%=noPreprocesses%>;
		if(noPreprocesses) $('#noPreprocessesWarning').css('display', 'block');
		else $('#existingContainers').css('display', 'block');
    </script>
</body>
</html>