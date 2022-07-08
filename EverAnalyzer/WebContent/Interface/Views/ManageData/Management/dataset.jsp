<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.Dataset" %>
<%@ page import="ever.lib.Tools" %>
<%@ page import="ever.lib.HDFSTransferring" %>
<%@ page import="ever.lib.Information" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="ever.lib.DownloadClass" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Manage Datasets and Results</title>
	<link rel="stylesheet" href="./../../../styles/styles.css">
	<link rel="stylesheet" href="./../../../styles/management.css">
	
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
	
	<!-- Check for kind and get results -->
	<%
	// Dataset kind checkers
	boolean collection = false;
	boolean preprocess = false;
	boolean mapReduce = false;
	boolean analysis = false;
	
	// Dataset info
	JSONObject[] collectionJSONS = new JSONObject[0];
	JSONObject[] preprocessJSONS = new JSONObject[0];
	String[][] mapReduceArray = new String[0][];
	String[] analysisLines = new String[0];
	
	// Dataset as a Class
	Dataset dataset = new Dataset();
	
	if(session.getAttribute("username") != null){
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("label");
		String datasetKind = request.getParameter("datasetKind");
		
		// Get the Dataset
		dataset = MongoClass.getDataset(username, label);
		
		// Update checkers
		if(datasetKind.equals(Tools.COLLECTED_DATASET)) collection = true;
		if(datasetKind.equals(Tools.PREPROCESSED_DATASET)) preprocess = true;
		if(datasetKind.equals(Tools.MAPREDUCED_DATASET)) mapReduce = true;
		if(datasetKind.equals(Tools.ANALYZED_DATASET)) analysis = true;
		
		// Gather information
		if(collection){
			collectionJSONS = Information.getCollectionInfo(username, label);
		}
		if(preprocess){
			preprocessJSONS = Information.getPreprocessInfo(username, label);
		}
		if(mapReduce){
			if(dataset.getFramework().equals(Tools.HADOOP_MAHOUT)) 
				mapReduceArray = Information.getMapReduceInfo(username, label, Tools.HADOOP_MAHOUT);
			if(dataset.getFramework().equals(Tools.SPARK_MLIB)) 
				mapReduceArray = Information.getMapReduceInfo(username, label, Tools.SPARK_MLIB);
		}
		if(analysis){
			if(dataset.getFramework().equals(Tools.HADOOP_MAHOUT)) 
				analysisLines = Information.getAnalysisInfo(username, label, Tools.HADOOP_MAHOUT);
			if(dataset.getFramework().equals(Tools.SPARK_MLIB)) 
				analysisLines = Information.getAnalysisInfo(username, label, Tools.SPARK_MLIB);
		}
		
	}
	%>
	
	<!-- Download Option -->
	<% 
	// check if the user selected to Download the Dataset
	boolean downloadDone = false;
	if(request.getParameter("downloadButton")!=null){
		// Get needed values
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("label");
		
		// Start the Downloading of the Dataset
		DownloadClass.downloadDataset(username, label);
		downloadDone = true;
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
                <strong>
                	Viewing 
                	<% if(collection || preprocess){
                		out.print("Dataset");
	                	}
	                	else if(mapReduce || analysis){
	                		out.print("Results");
	                	}
	                %>: <%=request.getParameter("label")%>
                </strong>
              </h1>
              <p class="lead">
              	View the information of your 
				<% if(collection || preprocess){
                		out.print("Dataset");
                	}
                	else if(mapReduce || analysis){
                		out.print("Results");
                	}
                %>.
              </p>
            </div>
        </div>
        
        <!-- Ttitle -->
        <div class="container border border-dark">
        <%if(collection) %> <u>Collection Information</u><br>View your Tweets below<%; %>
        <%if(preprocess) %> <u>Pre-process Information</u><br>View your pre-processing below<%; %>
        <%if(mapReduce) %> <u>Word count Information</u><br>View your Word count results below<%; %>
        <%if(analysis) %> <u>Analysis Information</u><br>View your Analysis results below<%; %>
        </div>
        <br>
        <div class="container border border-dark">
        	<u>Download Information</u>
        	<form class="form-group container">
	   			<input class="btn btn-dark" type="submit" value="Download Information" name="downloadButton">
	   			<input type="hidden" id="label" name="label" value="<%=request.getParameter("label")%>">
	   			<input type="hidden" id="datasetKind" name="datasetKind" value="<%=request.getParameter("datasetKind")%>">
	   			<input type="hidden" id="json" name="json" value="<%=request.getParameter("json")%>">
	   		</form>
	   		<!-- IMPORTANT WARNING -->
            <div class="container" style="font-size: medium; display:none;" id="downloadIsDoneWarning">
            	<br>
            	<div class="alert alert-success" role="alert">
				  Your Information has been download in the path: C:\EverAnalyzer\download\text.txt
				</div>
            </div>
	   		<br>
        </div>
        <%
        if(collection || preprocess){
        	int myJSON = Integer.parseInt(request.getParameter("json"));
        	if(myJSON != 0){ %>
        		<a href="./dataset.jsp?label=<%= request.getParameter("label") %>&datasetKind=<%= request.getParameter("datasetKind") %>&json=<%= myJSON-1 %>" 
        			class="previous round">
        			previous</a>
        	<%}
        	if(collection){
        		if(myJSON != collectionJSONS.length -1){ %>
		    		<a href="./dataset.jsp?label=<%= request.getParameter("label") %>&datasetKind=<%= request.getParameter("datasetKind") %>&json=<%= myJSON+1 %>" 
		    			class="next round">
		    			next</a>
    			<%}
        	}
			if(preprocess){
				if(myJSON != preprocessJSONS.length -1){ %>
	    		<a href="./dataset.jsp?label=<%= request.getParameter("label") %>&datasetKind=<%= request.getParameter("datasetKind") %>&json=<%= myJSON+1 %>" 
	    			class="next round">
	    			next</a>
				<%}
        	}
        	
    	}
        %>
        <br>
        
        <!-- Information view -->
        <div class="container border border-dark">
        	<%
        	if(collection){
        		%>
        		<div class="container" style="font-size:12px; width:100%;" id="jsonView">
        			<!-- JSON will be here -->
        		</div>
        		<%
    		}
    		if(preprocess){
    			%>
        		<div class="container" style="font-size:12px; width:100%;" id="jsonView">
        			<!-- JSON will be here -->
        		</div>
        		<%
    		}
    		if(mapReduce){
    			%>
    			Map-Reduce Results:
    			<pre>
<%
    				for(int i=0; i<mapReduceArray.length; i++){
    					out.println(mapReduceArray[i][0]+"\t"+mapReduceArray[i][1]);
    				}
%>
				</pre>
    			<%
    		}
    		if(analysis){
    			%>
    			K-means Results:
    			<pre>
<%
    				for(int i=0; i<analysisLines.length; i++){
    					out.println(analysisLines[i]);
    				}
%>
				</pre>
    			<%
    		}
			
			%>
        </div>
    </div>
    
    <!-- Event Listener for logout -->
    <script>
    	document.getElementById("singout").addEventListener("click", function() {
    		this.href = "./dataset.jsp?logout=truee";
    	});
    </script>
    
    <!-- Script to check for downloads -->
    <script>
    	let downloadDone = <%=downloadDone%>;
    	if(downloadDone) $('#downloadIsDoneWarning').css('display', 'block');
    </script>
    
    
    <!-- Script to show JSONs -->
    <script>
	    function syntaxHighlight(json) {
	        json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
	        return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
	            var cls = 'number';
	            if (/^"/.test(match)) {
	                if (/:$/.test(match)) {
	                    cls = 'key';
	                } else {
	                    cls = 'string';
	                }
	            } else if (/true|false/.test(match)) {
	                cls = 'boolean';
	            } else if (/null/.test(match)) {
	                cls = 'null';
	            }
	            return '<span class="' + cls + '">' + match + '</span>';
	        });
	    }
	    
	    function output(inp) {
	    	let div = document.getElementById("jsonView");
	    	div.appendChild(document.createElement('pre')).innerHTML = inp;
	    }
    </script>
    <script>
    	<%
    	if(collection){
    		%>
    		let str = JSON.stringify(<%=collectionJSONS[Integer.parseInt(request.getParameter("json"))]%>, undefined, 4);
    		output(syntaxHighlight(str));
    		<%
    	}
		if(preprocess){
			%>
			let str = JSON.stringify(<%=preprocessJSONS[Integer.parseInt(request.getParameter("json"))]%>, undefined, 4);
    		output(syntaxHighlight(str));
    		<%
    	}
    	%>
    </script>
</body>
</html>