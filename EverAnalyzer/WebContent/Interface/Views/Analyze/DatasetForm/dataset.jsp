<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.PreProcessClass" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.Suggestion" %>
<%@ page import="ever.lib.Tools" %>
<%@ page import="ever.lib.MahoutKMeans" %>

<%@ page import="ever.lib.HDFSTransferring" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Analyze Dataset</title>
	<link rel="stylesheet" href="./../../../styles/styles.css">
	
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
		response.sendRedirect("./../../Verification/login.jsp");
	}
	
	// check if the user is loging out
	if(request.getParameter("logout") != null){
		// If user logs out then stop the servers
		CommandLine.stopServers();
		session.removeAttribute("username");
		response.sendRedirect("./../../Verification/login.jsp");
	}
	%>
	
	<!-- Map-Reduce Workflow -->
	<%
	boolean exists = false;
	boolean showDone = false;
	if(request.getParameter("submitAnalysis")!=null){
		// Get the username and the label
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("AnalysisLabel");
		
		// If true then error
		exists = MongoClass.checkLabel(username, label);
		
		if(!exists) {
			// Get child label
			String childLabel = request.getParameter("dataset");
			
			// Get the preprocessing file from HDFS
			HDFSTransferring.getFileFromHDFS(username, childLabel);
			
			// Get the needed Arrays
			String[] JOB_ATTRS = MongoClass.getDatasetArray(username, childLabel, "kept-fields");
			String[] JOB_TERMS = MongoClass.getDatasetArray(username, childLabel, "keywords");
			
			// make the beforeAnalysis
			// preprocessing.txt --> analysis/beforeAnalysis.txt
			Tools.preMakeAnalysis(JOB_ATTRS, JOB_TERMS);
			
			if(request.getParameter("frameworkSelection").equals("hadoop")){
				// Make the Mahout Analysis
				int numClusters = Integer.parseInt(request.getParameter("numClusters"));
				int numIterations = Integer.parseInt(request.getParameter("numIterations"));
				
				// Start the Mahout Analysis
				long start = Tools.getTime();
				MahoutKMeans.analysis(numClusters, numIterations);
				long end = Tools.getTime();
				
				// Finalize Analysis
				Tools.deleteDirectory("C:/EverAnalyzer/out");
				HDFSTransferring.uploadToHDFS("C:\\EverAnalyzer\\Mahout.txt",
						"/EverAnalyzer/"+username+"/analysis/"+label+"/Mahout.txt");
				
				// Update MongoDB
				MongoClass.addAnalysis(username, childLabel, label, "hadoop", end-start, numClusters, numIterations);
			}
			
			if(request.getParameter("frameworkSelection").equals("spark")){
				// Start the Spark Analysis
				response.sendRedirect("http://localhost:8080/EverAnalyzer-Spark/Endpoints/analysis.jsp?dataset="+request.getParameter("dataset")+
						"&size="+request.getParameter("size")+
						"&AnalysisLabel="+request.getParameter("AnalysisLabel")+
						"&start="+Tools.getTime()+
						"&username="+(String)session.getAttribute("username")+
						"&label="+request.getParameter("AnalysisLabel")+
						"&numClusters="+request.getParameter("numClusters")+
						"&numIterations="+request.getParameter("numIterations"));
			}
			showDone = true;
		}
	}
	%>
	
	<%
	if(request.getParameter("sparked") != null){
		// Get the complete spark job times
		long start = Long.parseLong(request.getParameter("start"));
		long end = Tools.getTime();
		
		// Get the complete spark job labels
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("AnalysisLabel");
		String childLabel = request.getParameter("dataset");
		int numClusters = Integer.parseInt(request.getParameter("numClusters"));
		int numIterations = Integer.parseInt(request.getParameter("numIterations"));
		
		// Finalize Analysis
		Tools.deleteDirectory("C:/EverAnalyzer/out");
		HDFSTransferring.uploadToHDFS("C:\\EverAnalyzer\\SparkML.txt",
				"/EverAnalyzer/"+username+"/analysis/"+label+"/SparkML.txt");
		
		// Update MongoDB
		MongoClass.addAnalysis(username, childLabel, label, "spark", end-start, numClusters, numIterations);
		showDone = true;
	}
	%>
	
	<!-- Map-Reduce Suggestion Workflow -->
	<%
	boolean hadoop = false;
	boolean spark = false;
	if(request.getParameter("suggestionButton")!=null){
		// Get the bytesize of the Dataset to make the suggestion
		String bytesize = request.getParameter("size");
		
		String suggestion = Suggestion.analysis(bytesize);
		
		if(suggestion.equals(Tools.HADOOP_MAHOUT)) hadoop = true;
		if(suggestion.equals(Tools.SPARK_MLIB)) spark = true;
	}
	%>

	<div class="sidenav">
        <img src="./../../../images/LOGO_INVERTED_WHITE.png" alt="LOGO" class="center" style="width:90%;"> 
        <br>
        <div class="username border-bottom"><img src="./../../../images/user.png" alt="user image" width="30" height="30" align="left">&nbsp;&nbsp;<%=session.getAttribute("username") %></div>
        <a href="./../../Collect/index.jsp" class="border-bottom">Collection</a>
        <a href="./../../PreProcess/index.jsp" class="border-bottom">Pre-processing</a>
        <a href="./../../MapReduce/index.jsp" class="border-bottom">Processing</a>
        <a href="./../../Analyze/index.jsp" class="border-bottom">Analytics</a>
        <a href="./../../Visualize/index.jsp" class="border-bottom">Visualization</a>
        <a href="./../../ManageData/index.jsp" class="border-bottom">Management</a>
        <a href="./../../Verification/login.jsp" class="border-bottom" id="singout">Sign out</a>
    </div>
      
    <div class="main">
        <!-- Always on top -->
        <div class="jumbotron jumbotron-fluid" style="background-color: lightgray;">
            <div class="container">
              <h1 class="display-4">
                <strong>Analyze Dataset: <%=request.getParameter("dataset")%></strong>
              </h1>
              <p class="lead">
              	Analyze your Dataset using EverAnalyzer's Analytics algorithms.
              </p>
            </div>
        </div>
        
        <!-- IMPORTANT WARNING -->
         <div class="container" style="font-size: medium;">
         	<div class="alert alert-success" role="alert" id="AnalysisIsDoneWarning" style = "display:none">
			  The Analytic process of your Dataset is done. You can leave this page now.
			</div>
         </div>
        
        <!-- Pre-process Form -->
        <div class="container border border-dark">
        
        	<form class="container">
        		<!-- Analysis label -->
        		<div class="form-group small">
                    <label for="AnalysisLabel">Give a label for the results of your Analysis</label>
                    <input type="text" class="form-control" id="AnalysisLabel" name="AnalysisLabel" placeholder="A name for the results of your Analysis" required>
                </div>
                
                <!-- Analytics Algorithm choice -->
                <div class="form-group small">
				    <label for="AlgorithmSelection">Select Algorithm</label>
				    <select class="form-control" id="AlgorithmSelection" name="AlgorithmSelection">
				      <option value="k-means">K-means</option>
				      <option value="Fuzzy c-means">Fuzzy C-means</option>
				    </select>
				</div>
				
				<!-- Analysis configurations -->
                <div class="form-group small">
                    <label for="numIterations">Give the max amount of Iterations to do in the Analysis</label>
                    <input type="number" class="form-control" id="numIterations" name="numIterations" min="5" step="1" placeholder="10" required>
                </div>
                <div class="form-group small">
                    <label for="numClusters">Give the amount of clusters to use in the Analysis</label>
                    <input type="number" class="form-control" id="numClusters" name="numClusters" min="2" step="1" placeholder="2" required>
                </div>
                
                <!-- Framework Selection -->
                <div class="form-group small">
				    <label for="frameworkSelection">Select below between Mahout or Spark MLlib</label>
				    <select class="form-control" id="frameworkSelection" name="frameworkSelection">
				      <option value="hadoop">Mahout - Mostly uses disc space</option>
				      <option value="spark">Spark MLlib - Mostly uses RAM</option>
				    </select>
				</div>
                
                <!-- Analysis Submit -->
                <button id="submitAnalysis" name="submitAnalysis" type="submit" class="btn btn-dark">Analyze</button>
                <input type="hidden" id="dataset" name="dataset" value="<%=request.getParameter("dataset")%>">
                <input type="hidden" id="size" name="size" value="<%=request.getParameter("size")%>">
            </form>
            
            <br>
            
            <!-- Suggestion Form -->
            <form class="container">
                <!-- Suggestion Button -->
        		<div class="form-group small">
                    <label for="suggestionButton">Give me a suggestion based on what I should use</label><br>
                    <button id="suggestionButton" name="suggestionButton" type="submit" class="btn btn-dark">Suggest</button>
                    <input type="hidden" id="dataset" name="dataset" value="<%=request.getParameter("dataset")%>">
                    <input type="hidden" id="size" name="size" value="<%=request.getParameter("size")%>">
                </div>
            </form>
            
            <br>
            
            <!-- WARNINGS -->
            <div class="container" style="font-size: medium;">
            	<div class="alert alert-warning" role="alert" id="existingLabelWarning" style = "display:none">
				  This label already exists!
				</div>
            	<div class="alert alert-danger" role="alert" id="noValidLabelWarning" style = "display:none">
				  The label must not have special characters!
				</div>
				<div class="alert alert-success" role="alert" id="sparkSuggestionWarning" style = "display:none">
				  You should use <u>Spark MLlib</u> to do your Analytic job for the Dataset with the label: <%=request.getParameter("dataset")%>
				</div>
				<div class="alert alert-success" role="alert" id="hadoopSuggestionWarning" style = "display:none">
				  You should use <u>Mahout</u> to do your Analytic job for the Dataset with the label: <%=request.getParameter("dataset")%>
				</div>
            </div>
        </div>
        
    </div>
    
    <!-- Event Listener for logout -->
    <script>
    	document.getElementById("singout").addEventListener("click", function() {
    		this.href = "./dataset.jsp?logout=truee";
    	});
    </script>
    
    <!-- Script to check for ready pre-processing -->
  	<script>
	  	let MapReduceIsDoneWarning =  <%=showDone%>;
		if(MapReduceIsDoneWarning) $('#AnalysisIsDoneWarning').css('display', 'block');
  	</script>
  	
  	<!-- Script to check for existing labels -->
    <script>
    	let existingLabel = <%=exists%>;
    	if(existingLabel) $('#existingLabelWarning').css('display', 'block');
    </script>
    
    <!-- Script to show the suggestion of the system -->
    <script>
    	let spark = <%=spark%>;
    	let hadoop = <%=hadoop%>;
    	
    	if(spark) $('#sparkSuggestionWarning').css('display', 'block');
    	if(hadoop) $('#hadoopSuggestionWarning').css('display', 'block');
    </script>
    
    <!-- Check for label validity -->
    <script>
    	let checkAll = function(){
    		// Assumption that the String is valid
    		let valid = true;
    		
    		// Get the not valid label warning
			let notValidLabelWarning = $('#noValidLabelWarning');
			
			// Get the button
			let button = $('#submitAnalysis');
			
			// Get the label
			let analysisLabel = $('#AnalysisLabel').val();
			
			format = /[!@#$%^&*()_+\=\[\]{};':"\\|.< ,>\/?]+/;
			
			if(format.test(analysisLabel)){	// String is not valid
				button.attr('disabled','disabled');
				notValidLabelWarning.css('display', 'block');
				valid = false;
			} else{
				notValidLabelWarning.css('display', 'none');
			}
			
			/** Final decision about the button**/
			
			if(valid){	// String is valid
				button.removeAttr('disabled');
			}
    	}
    	
		$('#AnalysisLabel').keyup(checkAll);
    </script>
</body>
</html>