<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.Dataset" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.Tools" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Manage Data</title>
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
	
	<!-- Dataset existance checkup -->
	<%
	// Collections
	boolean noCollections = true;
	Dataset[] collections = new Dataset[0];
	
	// Pre-processes
	boolean noPreprocesses = true;
	Dataset[] preprocesses = new Dataset[0];
	
	// Map-Reduces
	boolean noReduces = true;
	Dataset[] reduces = new Dataset[0];
	
	// Analytics
	boolean noAnalytics = true;
	Dataset[] analytics = new Dataset[0];
	
	if(session.getAttribute("username") != null){
		String username = (String)session.getAttribute("username");
		
		// Collections check
		if(MongoClass.datasetExists(username, Tools.COLLECTED_DATASET)){
			noCollections = false;
			collections = MongoClass.getDatasets(username, Tools.COLLECTED_DATASET);
		}
		
		// Pre-processes check
		if(MongoClass.datasetExists(username, Tools.PREPROCESSED_DATASET)){
			noPreprocesses = false;
			preprocesses = MongoClass.getDatasets(username, Tools.PREPROCESSED_DATASET);
		}
		
		// Map-Reduces check
		if(MongoClass.datasetExists(username, Tools.MAPREDUCED_DATASET)){
			noReduces = false;
			reduces = MongoClass.getDatasets(username, Tools.MAPREDUCED_DATASET);
		}
		
		// Analytics check
		if(MongoClass.datasetExists(username, Tools.ANALYZED_DATASET)){
			noAnalytics = false;
			analytics = MongoClass.getDatasets(username, Tools.ANALYZED_DATASET);
		}
	}
	%>
	
	<!-- Dataset Selection -->
	<%
	// check if the user selected a Dataset
	if(request.getParameter("datasetButton")!=null){
		// show the user his Dataset
		response.sendRedirect("./Management/dataset.jsp?label="+request.getParameter("selectedDataset")+
				"&datasetKind="+request.getParameter("datasetKind")+
				"&json=0");
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
                <strong>Management</strong>
              </h1>
              <p class="lead">Use EverAnalyzer to download and view the information of your Datasets and Results.</p>
            </div>
        </div>
        
        <!-- User Datasets in lists -->
        <div class="container border border-dark">
        
        	<br>
        
        	<!-- Below are all the lists into an accordion -->
        	<div class="accordion accordion-flush" id="accordionFlush">
        	
        	  <!-- COLLECTIONS -->
			  <div class="accordion-item">
			    <h2 class="accordion-header" id="flush-headingOne">
			      <button class="accordion-button collapsed border border-dark" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseOne" aria-expanded="false" aria-controls="flush-collapseOne" id="collectionButton">
			        <strong>Collected Datasets</strong>
			      </button>
			    </h2>
			    <div id="flush-collapseOne" class="accordion-collapse collapse" aria-labelledby="flush-headingOne" data-bs-parent="#accordionFlush">
			      <div class="accordion-body">
			      	
					<!-- No Collections Warning -->
		            <div class="container" style="font-size: medium;">
		            	<div class="alert alert-warning" role="alert" id="noCollectionsWarning" style = "display:none; margin-top: 12px;">
						  You do not have any Collected Datasets.
						</div>
		            </div>
		            
			        <!-- Existing Collections -->
		            <div class="container datasets" id="existingCollectionsContainers" style="display:none;">
		            
		            	<%for(int i=0; i<collections.length; i++){ %>
		            
		            	<!-- Dataset Template -->
		            	<div class="container rounded dataset">
		            	
		            		<!-- Dataset metadata (label, date) -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Label: <span class="rounded metadata"><%=collections[i].getLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Date: <span class="rounded metadata"><%=collections[i].getDate()%></span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset metadata (amount, size) -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Tweets amount: <span class="rounded metadata"><%=collections[i].getAmount()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Size: <span class="rounded metadata"><%=collections[i].getSize()%> bytes</span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset metadata (keywords) -->
		            		<div class="container border border-dark">
		            			Words: 
		            			
		            			<% 
		            			String[] keywords = collections[i].getKeywords();
		            			for(int j=0; j<keywords.length; j++){	
		            			%>
		            			<span class="rounded metadata"><%=keywords[j]%></span>  
		            			<%}%>
		            			
		            		</div>
		            		
		            		<!-- Dataset Selector -->
		            		<form class="form-group container">
		            			<input class="btn btn-dark" type="submit" value="View Dataset" name="datasetButton">
		            			<input type="hidden" id="selectedDataset" name="selectedDataset" value="<%=collections[i].getLabel()%>">
		            			<input type="hidden" id="datasetKind" name="datasetKind" value="<%=Tools.COLLECTED_DATASET%>">
		            		</form>
		            		
		            	</div>
		            	
		            	<%
		            	if(i != (collections.length - 1)){
		            		%><br><%
		            	}
		            	%>
		            	<% } %>
		            </div>
			       </div>
			    </div>
			  </div>
			  
			  <!-- PREPROCESSES -->
			  <div class="accordion-item">
			    <h2 class="accordion-header" id="flush-headingTwo">
			      <button class="accordion-button collapsed border border-dark" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseTwo" aria-expanded="false" aria-controls="flush-collapseTwo" id="preprocessButton">
			        <strong>Pre-processed Datasets</strong>
			      </button>
			    </h2>
			    <div id="flush-collapseTwo" class="accordion-collapse collapse" aria-labelledby="flush-headingTwo" data-bs-parent="#accordionFlush">
			      <div class="accordion-body">
			      
			      	<!-- No Preprocesses Warning -->
		            <div class="container" style="font-size: medium;">
		            	<div class="alert alert-warning" role="alert" id="noPreprocessesWarning" style = "display:none; margin-top: 12px;">
						  You do not have any Pre-processed Datasets.
						</div>
		            </div>	
		            
		            <!-- Existing Pre-processings -->
		            <div class="container datasets" id="existingPreprocessesContainers" style="display:none;">
		            
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
		            			<input class="btn btn-dark" type="submit" value="View Dataset" name="datasetButton">
		            			<input type="hidden" id="selectedDataset" name="selectedDataset" value="<%=preprocesses[i].getLabel()%>">
		            			<input type="hidden" id="datasetKind" name="datasetKind" value="<%=Tools.PREPROCESSED_DATASET%>">
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
			  </div>
			  
			  <!-- MAPREDUCES -->
			  <div class="accordion-item">
			    <h2 class="accordion-header" id="flush-headingThree">
			      <button class="accordion-button collapsed border border-dark" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseThree" aria-expanded="false" aria-controls="flush-collapseThree" id="mapreduceButton">
			        <strong>Processing Results</strong>
			      </button>
			    </h2>
			    <div id="flush-collapseThree" class="accordion-collapse collapse" aria-labelledby="flush-headingThree" data-bs-parent="#accordionFlush">
			      <div class="accordion-body">
			      	
					<!-- No Map-Reduced Warning -->
		            <div class="container" style="font-size: medium;">
		            	<div class="alert alert-warning" role="alert" id="noReducesWarning" style = "display:none; margin-top: 12px;">
						  You do not have any Processing Results.
						</div>
		            </div>	
		            
		            <!-- Existing MapReduce -->
		            <div class="container datasets" id="existingReducesContainers" style="display:none;">
		            
		            	<%for(int i=0; i<reduces.length; i++){ %>
		            
		            	<!-- Dataset Template -->
		            	<div class="container rounded dataset">
		            		
		            		<!-- Dataset metadata (label, date) -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Label: <span class="rounded metadata"><%=reduces[i].getLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Date: <span class="rounded metadata"><%=reduces[i].getDate()%></span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset Kind -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Job: <span class="rounded metadata"><%
											if(reduces[i].getKind().equals(Tools.ANALYZED_DATASET)){
												out.print("K-means");
											}
											else{
												out.print("Word count");
											}
										%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Framework: <span class="rounded metadata"><%
											if(reduces[i].getFramework().equals(Tools.HADOOP_MAHOUT)){
												if(reduces[i].getKind().equals(Tools.ANALYZED_DATASET)) out.print("Mahout");
												if(reduces[i].getKind().equals(Tools.MAPREDUCED_DATASET)) out.print("Hadoop");
											}
											else{
												if(reduces[i].getKind().equals(Tools.ANALYZED_DATASET)) out.print("Spark MLlib");
												if(reduces[i].getKind().equals(Tools.MAPREDUCED_DATASET)) out.print("Spark");
											}
										%></span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset metadata (amount, size) -->
		            		<div class="container">
		            			<div class="row border border-dark">
		            				<div class="col-lg-6">
			            				Pre-process Label: <span class="rounded metadata"><%=reduces[i].getChildLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Pre-process Size: <span class="rounded metadata"><%=reduces[i].getPreSize()%> bytes</span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Pre-process Tweets amount: <span class="rounded metadata"><%=reduces[i].getAmount()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Pre-processing Fields: 
		            			
				            			<% 
				            			String[] fields = reduces[i].getFields();
				            			for(int j=0; j<fields.length; j++){	
				            			%>
				            			<span class="rounded metadata"><%=fields[j]%></span>  
				            			<%}%>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset metadata (parentLabel, keywords) -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Collection Label: <span class="rounded metadata"><%=reduces[i].getParentLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Collection Words: 
				            			<% 
				            			String[] keywords = reduces[i].getKeywords();
				            			for(int j=0; j<keywords.length; j++){	
				            			%>
				            			<span class="rounded metadata"><%=keywords[j]%></span>  
				            			<%}%>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset Selector -->
		            		<form class="form-group container">
		            			<input class="btn btn-dark" type="submit" value="View Results" name="datasetButton">
		            			<input type="hidden" id="selectedDataset" name="selectedDataset" value="<%=reduces[i].getLabel()%>">
		            			<input type="hidden" id="datasetKind" name="datasetKind" value="<%=Tools.MAPREDUCED_DATASET%>">
		            		</form>
		            		
		            	</div>
		            	
		            	<%
		            	if(i != (reduces.length - 1)){
		            		%><br><%
		            	}
		            	%>
		            	<% } %>
		            </div>
		            
			      </div>
			    </div>
			  </div>
			  
			  <!-- ANALYTICS -->
			  <div class="accordion-item">
			    <h2 class="accordion-header" id="flush-headingFour">
			      <button class="accordion-button collapsed border border-dark" type="button" data-bs-toggle="collapse" data-bs-target="#flush-collapseFour" aria-expanded="false" aria-controls="flush-collapseFour" id="analyticsButton">
			        <strong>Analytics Results</strong>
			      </button>
			    </h2>
			    <div id="flush-collapseFour" class="accordion-collapse collapse" aria-labelledby="flush-headingFour" data-bs-parent="#accordionFlush">
			      <div class="accordion-body">
			      	
					<!-- No Analytics Warning -->
		            <div class="container" style="font-size: medium;">
		            	<div class="alert alert-warning" role="alert" id="noAnalyticsWarning" style = "display:none; margin-top: 12px;">
						  You do not have any Analytics Results.
						</div>
		            </div>	
		            
		            <!-- Existing Analytics -->
		            <div class="container datasets" id="existingAnalyticsContainers" style="display:none;">
		            
		            	<%for(int i=0; i<analytics.length; i++){ %>
		            
		            	<!-- Dataset Template -->
		            	<div class="container rounded dataset">
		            		
		            		<!-- Dataset metadata (label, date) -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Label: <span class="rounded metadata"><%=analytics[i].getLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Date: <span class="rounded metadata"><%=analytics[i].getDate()%></span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset Kind -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Job: <span class="rounded metadata"><%
											if(analytics[i].getKind().equals(Tools.ANALYZED_DATASET)){
												out.print("K-means");
											}
											else{
												out.print("Word count");
											}
										%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Framework: <span class="rounded metadata"><%
											if(analytics[i].getFramework().equals(Tools.HADOOP_MAHOUT)){
												if(analytics[i].getKind().equals(Tools.ANALYZED_DATASET)) out.print("Mahout");
												if(analytics[i].getKind().equals(Tools.MAPREDUCED_DATASET)) out.print("Hadoop");
											}
											else{
												if(analytics[i].getKind().equals(Tools.ANALYZED_DATASET)) out.print("Spark MLlib");
												if(analytics[i].getKind().equals(Tools.MAPREDUCED_DATASET)) out.print("Spark");
											}
										%></span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset metadata (amount, size) -->
		            		<div class="container">
		            			<div class="row border border-dark">
		            				<div class="col-lg-6">
			            				Pre-process Label: <span class="rounded metadata"><%=analytics[i].getChildLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Pre-process Size: <span class="rounded metadata"><%=analytics[i].getPreSize()%> bytes</span>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Pre-process Tweets amount: <span class="rounded metadata"><%=analytics[i].getAmount()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Pre-processing Fields: 
		            			
				            			<% 
				            			String[] fields = analytics[i].getFields();
				            			for(int j=0; j<fields.length; j++){	
				            			%>
				            			<span class="rounded metadata"><%=fields[j]%></span>  
				            			<%}%>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset metadata (parentLabel, keywords) -->
		            		<div class="container">
		            			<div class="row border border-dark">
			            			<div class="col-lg-6">
			            				Collection Label: <span class="rounded metadata"><%=analytics[i].getParentLabel()%></span>
			            			</div>
			            			<div class="col-lg-6">
			            				Collection Words: 
				            			<% 
				            			String[] keywords = analytics[i].getKeywords();
				            			for(int j=0; j<keywords.length; j++){	
				            			%>
				            			<span class="rounded metadata"><%=keywords[j]%></span>  
				            			<%}%>
			            			</div>
			            		</div>
		            		</div>
		            		
		            		<!-- Dataset Selector -->
		            		<form class="form-group container">
		            			<input class="btn btn-dark" type="submit" value="View Results" name="datasetButton">
		            			<input type="hidden" id="selectedDataset" name="selectedDataset" value="<%=analytics[i].getLabel()%>">
		            			<input type="hidden" id="datasetKind" name="datasetKind" value="<%=Tools.ANALYZED_DATASET%>">
		            		</form>
		            		
		            	</div>
		            	
		            	<%
		            	if(i != (analytics.length - 1)){
		            		%><br><%
		            	}
		            	%>
		            	<% } %>
		            </div>

			      </div>
			    </div>
			  </div>
			</div>
			  
			  <br>
			  
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
    	// Collected Datasets
	    let noCollections = <%=noCollections%>;
		if(noCollections) $('#noCollectionsWarning').css('display', 'block');
		else $('#existingCollectionsContainers').css('display', 'block');
		
		// Pre-processed Datasets
		let noPreprocesses = <%=noPreprocesses%>;
		if(noPreprocesses) $('#noPreprocessesWarning').css('display', 'block');
		else $('#existingPreprocessesContainers').css('display', 'block');
		
		// Reduced Datasets
		let noReduces = <%=noReduces%>;
		if(noReduces) $('#noReducesWarning').css('display', 'block');
		else $('#existingReducesContainers').css('display', 'block');
		
		// Analytics Datasets
		let noAnalytics = <%=noAnalytics%>;
		if(noAnalytics) $('#noAnalyticsWarning').css('display', 'block');
		else $('#existingAnalyticsContainers').css('display', 'block');
    </script>
    
    <!-- Click event listeners for scrolling on top of the screen -->
    <script>
    	let onTopOfScreen = function(){
    		window.scroll({top: 0, left: 0});
    	}
    	document.getElementById("collectionButton").addEventListener("click", onTopOfScreen);
    	document.getElementById("preprocessButton").addEventListener("click", onTopOfScreen);
    	document.getElementById("mapreduceButton").addEventListener("click", onTopOfScreen);
    	document.getElementById("analyticsButton").addEventListener("click", onTopOfScreen);
    </script>
</body>
</html>