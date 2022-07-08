<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.Dataset" %>
<%@ page import="ever.lib.Tools" %>
<%@ page import="ever.lib.HDFSTransferring" %>
<%@ page import="org.json.JSONObject" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Visualize Results</title>
	<link rel="stylesheet" href="./../../../styles/styles.css">
	
	<!-- Load plotly.js into the DOM -->
	<script src='https://cdn.plot.ly/plotly-2.12.1.min.js'></script>
	
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
	
	<!-- Gathering Information process -->
	<%
	// Assume that non of the below has been done
	boolean hadoop = false;
	boolean spark = false;
	boolean mahout = false;
	boolean sparkML = false;
	
	// Initialise the results 
	String[][] mapReduceResults = new String[0][0];		// For Map Reduce
	JSONObject analysisResults = new JSONObject(); 		// For K-means
	Dataset dataset = new Dataset();
	
	// Now find the one and then get the needed data for it
	if(request.getParameter("dataset") != null){
		// Get the basic information
		String label = request.getParameter("dataset");
		String username = (String)session.getAttribute("username");
		
		// Get the Dataset
		dataset = MongoClass.getDataset(username, label);
		
		// find the kind and framework of the Dataset
		if(dataset.getKind().equals(Tools.ANALYZED_DATASET) && dataset.getFramework().equals(Tools.SPARK_MLIB)) sparkML = true;
		if(dataset.getKind().equals(Tools.MAPREDUCED_DATASET) && dataset.getFramework().equals(Tools.SPARK_MLIB)) spark = true;
		if(dataset.getKind().equals(Tools.ANALYZED_DATASET) && dataset.getFramework().equals(Tools.HADOOP_MAHOUT)) mahout = true;
		if(dataset.getKind().equals(Tools.MAPREDUCED_DATASET) && dataset.getFramework().equals(Tools.HADOOP_MAHOUT)) hadoop = true;
		
		if(hadoop) mapReduceResults = HDFSTransferring.getMapReduceResults(username, label, Tools.HADOOP_MAHOUT);
		if(spark) mapReduceResults = HDFSTransferring.getMapReduceResults(username, label, Tools.SPARK_MLIB);
		
		if(mahout) analysisResults = HDFSTransferring.getAnalysisResults(username, label, Tools.HADOOP_MAHOUT, dataset.getKeywords().length);
		if(sparkML) analysisResults = HDFSTransferring.getAnalysisResults(username, label, Tools.SPARK_MLIB, dataset.getKeywords().length);
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
                <strong>Visualize Results: <%=request.getParameter("dataset")%></strong>
              </h1>
              <p class="lead">
              	View the Visualization of your Results using EverAnalyzer.
              </p>
            </div>
        </div>
        
        <!-- Visualizations -->
        <div class="container border border-dark">
            <%if(spark || hadoop){%><b>Word count Results</b><%}%>
            <%if(sparkML || mahout){%><b>K-means Clustering Results</b><%}%>
            <br>
            <%if(sparkML || mahout){%><small>-The clustering counted the amount of times that each given Keyword was found in each pre-processed Tweet, gathered by the EverAnalyzer collection system.</small><%}%>
        </div>
        
        <%if(sparkML || mahout){%>
        <br>
        <div class="container border border-dark">
            <u>Cluster centroids</u>
            <br>
            <small>-Below is a table showing the values of each cluster's center.</small><br>
            <table class="table">
			  <thead class="thead-dark">
			    <tr>
			      <th scope="col">Cluster ID</th>
			      <%
			      	for(int i=0; i<dataset.getKeywords().length; i++){
			      		%><th scope="col"><%=dataset.getKeywords()[i]%></th><%
			      	}
			      %>
			    </tr>
			  </thead>
			  <tbody>
			  	<%
			  	for(int i=0; i<dataset.getClusters(); i++){
			  		%>
			  		<tr>
				      <th scope="row"><%=i%></th>
				      <%
				      for(int j=0; j<dataset.getKeywords().length; j++){
				    	  %><td><%=analysisResults.getJSONArray("clusters").getJSONArray(i).get(j) %></td><%
				      }
				      %>
				    </tr>
			  		<%
			  	}
			  	%>
			  </tbody>
			</table>
        </div>
        <%}%>
        
        <br>
        <div class="container border border-dark">
            <u>Comparison Graph</u>
            <br>
            <%if(spark || hadoop){%><small>-Below you will find a graph, containing the amount of times that your Keywords were found inside of your pre-processed Dataset.</small><%}%>
            <%if(sparkML || mahout){%><small>-Below you will find a graph, containing the comparison of the amount of data inside each requested cluster.</small><%}%>
            <div id='comparisonDiv' style="width:60%"><!-- Plotly chart will be drawn inside this DIV --></div>
        </div>
    </div>
    
    <!-- Event Listener for logout -->
    <script>
    	document.getElementById("singout").addEventListener("click", function() {
    		this.href = "./dataset.jsp?logout=truee";
    	});
    </script>
    
    <!-- Getting important variables  -->
    <script>
    	let spark = <%=spark%>
    	let hadoop = <%=hadoop%>
    	let sparkML = <%=sparkML%>
    	let mahout = <%=mahout%>
    </script>
    
    <!-- Comparison Graph for Map Reduce  -->
	    <%
	    String words = "[]";
	    if(hadoop || spark){
	    	words = "[";
	    	words+= "\""+dataset.getKeywords()[0]+"\"";
	    	for(int i=0; i<dataset.getKeywords().length; i++){
	    		words+= ",\""+dataset.getKeywords()[i]+"\"";
	    	}
	    	words+="]";
	    }
	    
	    String numbers = "[]";
	    if(hadoop || spark){
	    	int[] sortedNumbers = new int[dataset.getKeywords().length];
	    	numbers = "[";
	    	
	    	for(int i=0; i<dataset.getKeywords().length; i++){
	    		boolean found = false;
	    		for(int j=0; j<mapReduceResults.length; j++){
		    		if(mapReduceResults[j][0].equals(dataset.getKeywords()[i])){
		    			sortedNumbers[i] = Integer.parseInt(mapReduceResults[j][1]);
		    			numbers += ","+sortedNumbers[i];
		    			found = true;
		    			break;
		    		}
		    	}
	    		if(!found){
	    			sortedNumbers[i] = 0;
	    			numbers += ","+sortedNumbers[i];
	    		}
	    	}
	    	numbers += "]";
	    	numbers.replace("[,", "[");
	    }
	    %>
    <script>
    	if(spark || hadoop){
    		let data = [
			  {
				x: <%=words%>,
				y: <%=numbers%>,
				type: 'bar'
			  }
			];

    		Plotly.newPlot('comparisonDiv', data);
    	}
    </script>
    
    <!-- Comparison Graph for K-means  -->
    <script>
    	let analysisResults = <%=analysisResults%>;
    	console.log(analysisResults);
    	if(sparkML || mahout){
    		let clusters = []
    		for(let i=0; i<analysisResults["amounts"].length; i++){
    			clusters.push("Cluster "+i);
    		}
    		
    		let data = [
			  {
				x: clusters,
				y: analysisResults["amounts"],
				type: 'bar'
			  }
			];

    		Plotly.newPlot('comparisonDiv', data);
    	}
    </script>
</body>
</html>