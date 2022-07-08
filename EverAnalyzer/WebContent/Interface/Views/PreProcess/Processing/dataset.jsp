<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.PreProcessClass" %>
<%@ page import="ever.lib.MongoClass" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Pre-process Dataset</title>
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
	
	<!-- Pre-processing Workflow -->
	<%
	boolean exists = false;
	boolean showDone = false;
	if(request.getParameter("submitPreprocessing")!=null){
		// Get the username and the label
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("preprocessLabel");
		
		// If true then error
		exists = MongoClass.checkLabel(username, label);
		
		if(!exists) {
			// Get all keywords
			String rawKeywords = request.getParameter("tweetfields");
			String[] fields = rawKeywords.split(",");
			
			// Get parent label
			String parentLabel = request.getParameter("dataset");
			
			// Start Pre-processing Data
			PreProcessClass.preProcessData(username, label, fields, parentLabel);
			
			showDone = true;
		}
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
                <strong>Pre-process Dataset: <%=request.getParameter("dataset")%></strong>
              </h1>
              <p class="lead">
              	Pre-process your Dataset using EverAnalyzer.
              </p>
            </div>
        </div>
        
        <!-- IMPORTANT WARNING -->
         <div class="container" style="font-size: medium;">
         	<div class="alert alert-success" role="alert" id="preprocessingIsDoneWarning" style = "display:none">
			  The Pre-processing of your Dataset is done. You can leave this page now.
			</div>
         </div>
        
        <!-- Pre-process Form -->
        <div class="container border border-dark">
        
        	<form class="container">
        	
        		<!-- Pre-process label -->
        		<div class="form-group small">
                    <label for="preprocessLabel">Give a label for your pre-processed Dataset</label>
                    <input type="text" class="form-control" id="preprocessLabel" name="preprocessLabel" placeholder="A name for your pre-processed Dataset" required>
                </div>
                
                <div class="form-group small">
                    <label for="tweetfields">Give below all the fields to keep in the data (use commas to separate fields)</label><br>
                    <small class="form-text text-muted">
                    	You can use "-" to hold a field inside of another field like the example in the placeholder. You are also allowed to use "_".
                    </small>
                    <input type="text" class="form-control" id="tweetfields" name="tweetfields" placeholder="user-id,text,retweet_count" required>
                </div>
                
                <!-- Pre-process Submit -->
                <button id="submitPreprocessing" name="submitPreprocessing" type="submit" class="btn btn-dark">Pre-process Data</button>
                <input type="hidden" id="dataset" name="dataset" value="<%=request.getParameter("dataset")%>">
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
            	<div class="alert alert-danger" role="alert" id="noWordWarning" style = "display:none">
				  There must be words between the commas!
				</div>
				<div class="alert alert-danger" role="alert" id="commaWarning" style = "display:none">
				  Your fields must be separated with commas!<br>
				  <small>Spaces and other special characters, are not allowed for separation.</small>
				</div>
				<div class="alert alert-danger" role="alert" id="wrongDashWarning" style = "display:none">
				  The "-" cannot be in the start or in the end of a field.
				  <small>And there must be only one dash for each inner field.</small>
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
	  	let preprocessingIsDoneWarning =  <%=showDone%>;
		if(preprocessingIsDoneWarning) $('#preprocessingIsDoneWarning').css('display', 'block');
  	</script>
  	
  	<!-- Script to check for existing labels -->
    <script>
    	let existingLabel = <%=exists%>;
    	if(existingLabel) $('#existingLabelWarning').css('display', 'block');
    </script>
    
    <!-- Script to get all the keywords -->
    <script>
    	let checkAll = function(){
    		/** Check if there are only commas in String **/
    		// Assumption that the String is valid
    		let valid = true;
    		
    		// Get the warning
    		let commaWarning = $('#commaWarning');
    		
    		// Get the button
			let button = $('#submitPreprocessing');
    		
    		// Special characters
    		let format = /[!@#$%^&*()+\=\[\]{};':"\\|.< >\/?]+/;
    		
    		// String to check
    		let string = $('#tweetfields').val();
    		
    		if(format.test(string)){	// String is not valid
    			button.attr('disabled','disabled');
    			commaWarning.css('display', 'block');
    			valid = false;
    		} else{
    			commaWarning.css('display', 'none');
    		}
    		
    		/** Check that there are words between all commas **/
    		
    		// Get the noWord warning
    		let noWordWarning = $('#noWordWarning');
    		
    		if(string.includes(",,") ||
    				string.startsWith(",") ||
    				string.endsWith(",")){
    			button.attr('disabled','disabled');
    			noWordWarning.css('display', 'block');
    			valid = false;
    		}
    		else{
    			noWordWarning.css('display', 'none');
    		}
    		
			/** Check that all the dash characters are right **/
    		
    		// Get the noWord warning
    		let wrongDashWarning = $('#wrongDashWarning');
    		
    		if(string.includes("-,") ||
    				string.includes(",-") ||
    				string.includes("--") ||
    				string.startsWith("-") ||
    				string.endsWith("-")){
    			button.attr('disabled','disabled');
    			wrongDashWarning.css('display', 'block');
    			valid = false;
    		}
    		else{
    			wrongDashWarning.css('display', 'none');
    		}
    		
    		/** Ckeck if the label does not have special characters **/
    		
    		// Get the not valid label warning
    		let notValidLabelWarning = $('#noValidLabelWarning');
    		
    		// Get the label
    		let collectionLabel = $('#preprocessLabel').val();
    		
    		format = /[!@#$%^&*()_+\=\[\]{};':"\\|.< ,>\/?]+/;
    		
    		if(format.test(collectionLabel)){	// String is not valid
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
    
    	$('#tweetfields').keyup(checkAll);
    	$('#preprocessLabel').keyup(checkAll);
    </script>
</body>
</html>