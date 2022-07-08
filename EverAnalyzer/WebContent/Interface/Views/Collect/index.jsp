<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.CommandLine" %>
<%@ page import="ever.lib.MongoClass" %>
<%@ page import="ever.lib.CollectClass" %>
<% MongoClass mongo = new MongoClass(); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Collection</title>
	<link rel="stylesheet" href="./../../styles/styles.css">
	
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
	
	<!-- Collecting Workflow -->
	<%
	boolean exists = false;
	boolean showFlume = false;
	if(request.getParameter("submitCollection")!=null){
		// Get the username and the label
		String username = (String)session.getAttribute("username");
		String label = request.getParameter("collectionLabel");
		
		// If true then error
		exists = MongoClass.checkLabel(username, label);
		
		if(!exists) {
			// Get all keywords
			String rawKeywords = request.getParameter("tweetKeywords");
			String[] keywords = rawKeywords.split(",");
			
			// Get the amount of Tweets
			int tweetsAmount = Integer.parseInt(request.getParameter("tweetsAmount"));
			
			// Get Twitter Keys
			String consumerKey = request.getParameter("consumerKey");
			String consumerSecret = request.getParameter("consumerSecret");
			String token = request.getParameter("token");
			String secret = request.getParameter("secret");
			
			// Start Collecting Data
			CollectClass.collectData(consumerKey, consumerSecret, token, secret,
					username, label, keywords, tweetsAmount);
			
			// Update MongoDB
			MongoClass.addCollection(username, label, keywords, tweetsAmount);
			
			showFlume = true;
		}
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
              <strong>Collection</strong>
            </h1>
            <p class="lead">Collect data using Twitter API.</p>
          </div>
        </div>
        
        <!-- Collection Form -->
        <div class="container border border-dark">
        	<!-- IMPORTANT WARNING -->
            <div class="container" style="font-size: medium;">
            	<div class="alert alert-success" role="alert" id="collectionIsDoneWarning" style = "display:none">
				  The collecting of your Tweets is done. Open the pink CMD and hold CTRL + C until it stops and then close it to continue.
				</div>
            </div>
        
        	<form class="container">
        	
        		<!-- Collection label -->
        		<div class="form-group small">
                    <label for="collectionLabel">Give a label for your collection</label>
                    <input type="text" class="form-control" id="collectionLabel" name="collectionLabel" placeholder="A name for your collection" required>
                </div>
        	
        		<!-- Tweets amount -->
        		<div class="form-group small">
                    <label for="tweetsAmount">Give the amount of Tweets to collect</label>
                    <input type="number" class="form-control" id="tweetsAmount" name="tweetsAmount" min="10" step="1" placeholder="100" required>
                </div>
                
                <!-- Tweets keywords -->
                <div class="form-group small">
                    <label for="tweetKeywords">Give below all the keywords to search for (use commas to separate keywords)</label>
                    <input type="text" class="form-control" id="tweetKeywords" name="tweetKeywords" placeholder="dog,cat,mouse" required>
                </div>
                
                <!-- Twitter credentials -->
                <div class="form-group small">
                    <label for="consumerKey">Input your Twitter Consumer Key</label>
                    <input type="text" class="form-control" id="consumerKey" name="consumerKey" placeholder="Twitter Consumer Key" required>
                </div>
                
                <div class="form-group small">
                    <label for="consumerSecret">Input your Twitter Consumer Secret</label>
                    <input type="text" class="form-control" id="consumerSecret" name="consumerSecret" placeholder="Twitter Consumer Secret" required>
                </div>
                
                <div class="form-group small">
                    <label for="token">Input your Twitter Token</label>
                    <input type="text" class="form-control" id="token" name="token" placeholder="Twitter Token" required>
                </div>
                
                <div class="form-group small">
                    <label for="secret">Input your Twitter Secret</label>
                    <input type="text" class="form-control" id="secret" name="secret" placeholder="Twitter Secret" required>
                </div>
                
                <!-- Collection Submit -->
                <button id="submitCollection" name="submitCollection" type="submit" class="btn btn-dark">Collect Data</button>
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
				  Your keywords must be separated with commas!<br>
				  <small>Spaces and other special characters are not allowed for separation.</small>
				</div>
            </div>
        </div>
        
    </div>
    
    <!-- Event Listener for logout -->
    <script>
    	document.getElementById("singout").addEventListener("click", function() {
    		this.href = "./index.jsp?logout=truee";
    	});
    </script>
  
  	<!-- Script to check for ready collections -->
  	<script>
	  	let collectionIsDoneWarning = <%=showFlume%>;
		if(collectionIsDoneWarning) $('#collectionIsDoneWarning').css('display', 'block');
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
			let button = $('#submitCollection');
    		
    		// Special characters
    		let format = /[!@#$%^&*()_+\-=\[\]{};':"\\|.< >\/?]+/;
    		
    		// String to check
    		let string = $('#tweetKeywords').val();
    		
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
    		
    		/** Ckeck if the label does not have special characters **/
    		
    		// Get the not valid label warning
    		let notValidLabelWarning = $('#noValidLabelWarning');
    		
    		// Get the label
    		let collectionLabel = $('#collectionLabel').val();
    		
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
    
    	$('#tweetKeywords').keyup(checkAll);
    	$('#collectionLabel').keyup(checkAll);
    </script>
</body>
</html>