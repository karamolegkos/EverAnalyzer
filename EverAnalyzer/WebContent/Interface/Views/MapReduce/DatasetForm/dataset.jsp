<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.PreProcessClass" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.Suggestion" %>
<%@ page import="ever.lib.Tools" %>

<%@ page import="ever.mr.MRRunner" %>
<%@ page import="ever.lib.HDFSTransferring" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Process Dataset</title>
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
	if(request.getParameter("submitMapReduce")!=null){
		// Get the username and the label
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("MapReduceLabel");
		
		// If true then error
		exists = MongoClass.checkLabel(username, label);
		
		if(!exists) {
			// Get child label
			String childLabel = request.getParameter("dataset");
			
			if(request.getParameter("frameworkSelection").equals("hadoop")){
				// Start the Map Reduce Job
				MRRunner.JOB_ATTRS = MongoClass.getDatasetArray(username, childLabel, "kept-fields");
				MRRunner.JOB_TERMS = MongoClass.getDatasetArray(username, childLabel, "keywords");
				long start = Tools.getTime();
				MRRunner.doMapReduceJob(username, childLabel, label);
				long end = Tools.getTime();
				
				// Update MongoDB
				MongoClass.addMapReduce(username, childLabel, label, "hadoop", end-start);
			}
			
			if(request.getParameter("frameworkSelection").equals("spark")){
				// Get the preprocessing file from HDFS
				HDFSTransferring.getFileFromHDFS(username, childLabel);
				
				// Get the needed Arrays
				String[] JOB_ATTRS = MongoClass.getDatasetArray(username, childLabel, "kept-fields");
				String[] JOB_TERMS = MongoClass.getDatasetArray(username, childLabel, "keywords");
				
				// Request spark job
				String job_attrs = "";
				String job_terms = "";
				
				for(int i=0; i<JOB_ATTRS.length; i++){
					job_attrs += JOB_ATTRS[i];
					if(i != JOB_ATTRS.length - 1) job_attrs += ",";
				}
				
				for(int i=0; i<JOB_TERMS.length; i++){
					job_terms += JOB_TERMS[i];
					if(i != JOB_TERMS.length - 1) job_terms += ",";
				}
				
				response.sendRedirect("http://localhost:8080/EverAnalyzer-Spark/Endpoints/mapreduce.jsp?dataset="+request.getParameter("dataset")+
						"&size="+request.getParameter("size")+
						"&MapReduceLabel="+request.getParameter("MapReduceLabel")+
						"&start="+Tools.getTime()+
						"&attrs="+job_attrs+
						"&terms="+job_terms);
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
		String label = request.getParameter("MapReduceLabel");
		String childLabel = request.getParameter("dataset");
		
		// Updates the HDFS with the file
		HDFSTransferring.putFileToHDFS(username, label);
		
		// Update MongoDB
		MongoClass.addMapReduce(username, childLabel, label, "spark", end-start);
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
		
		String suggestion = Suggestion.mapReduce(bytesize);
		
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
                <strong>Process Dataset: <%=request.getParameter("dataset")%></strong>
              </h1>
              <p class="lead">
              	Process your Dataset using EverAnalyzer. The process will be a word count on the keywords of your Dataset.
              </p>
            </div>
        </div>
        
        <!-- IMPORTANT WARNING -->
         <div class="container" style="font-size: medium;">
         	<div class="alert alert-success" role="alert" id="MapReduceIsDoneWarning" style = "display:none">
			  The Process job of your Dataset is done. You can leave this page now.
			</div>
         </div>
        
        <!-- Pre-process Form -->
        <div class="container border border-dark">
        
        	<form class="container">
        		<!-- Map-Reduce label -->
        		<div class="form-group small">
                    <label for="MapReduceLabel">Give a label for your Process results</label>
                    <input type="text" class="form-control" id="MapReduceLabel" name="MapReduceLabel" placeholder="A name for your Processing results" required>
                </div>
                
                <!-- Framework Selection -->
                <div class="form-group small">
				    <label for="frameworkSelection">Select below between Hadoop or Spark frameworks</label>
				    <select class="form-control" id="frameworkSelection" name="frameworkSelection">
				      <option value="hadoop">Hadoop Map-Reduce - Mostly uses disc space</option>
				      <option value="spark">Spark - Mostly uses RAM</option>
				    </select>
				</div>
                
                <!-- Map-Reduce Submit -->
                <button id="submitMapReduce" name="submitMapReduce" type="submit" class="btn btn-dark">Process</button>
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
				  You should use <u>Spark</u> to do your Processing job for the Dataset with the label: <%=request.getParameter("dataset")%>
				</div>
				<div class="alert alert-success" role="alert" id="hadoopSuggestionWarning" style = "display:none">
				  You should use <u>Hadoop</u> to do your Processing job for the Dataset with the label: <%=request.getParameter("dataset")%>
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
		if(MapReduceIsDoneWarning) $('#MapReduceIsDoneWarning').css('display', 'block');
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
			let button = $('#submitMapReduce');
			
			// Get the label
			let mapReduceLabel = $('#MapReduceLabel').val();
			
			format = /[!@#$%^&*()_+\=\[\]{};':"\\|.< ,>\/?]+/;
			
			if(format.test(mapReduceLabel)){	// String is not valid
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
    	
		$('#MapReduceLabel').keyup(checkAll);
    </script>
</body>
</html>