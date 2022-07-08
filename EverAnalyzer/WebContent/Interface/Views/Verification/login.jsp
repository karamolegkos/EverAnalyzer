<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.lib.MongoClass" %>
<% MongoClass mongo = new MongoClass(); %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="ISO-8859-1">
	<title>EverAnalyzer - Sign in</title>
	
	<!-- Latest minified CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <!-- Bootstrap Packaged JS (Bundle) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

	<!-- jQuery -->
	<script src="http://code.jquery.com/jquery-1.11.0.min.js"></script>
</head>
<body>
	<!-- Login Checkups -->
	<%
	// If there is a user already loged in, then send him to home!
	if(session.getAttribute("username") != null){
		response.sendRedirect("./../Home/home.jsp");
	}
	
	boolean notExistingUser = false;
	if(request.getParameter("loginButton")!=null){
		String username = request.getParameter("InputUsername");
		String password = request.getParameter("InputPassword");
		
		if(MongoClass.authenticateUser(username, password)){
			session.setAttribute("username", username);
			response.sendRedirect("./../Home/home.jsp?startServers=true");
		}
		else{
			notExistingUser = true;
		}
	}
	%>

	<!-- LOGO -->
	<div class="container">
		<div class="row">
			<div class="col-4"></div>
			<div class="col-4">
				<img src="./../../images/LOGO.png" class="rounded mx-auto d-block" alt="EverAnalyzer_LOGO" width="100%">
			</div>
			<div class="col-4"></div>
		</div>
	</div>
	
	<!-- FORM -->
	<br>
	<div class="container">
	  <div class="row">
	    <div class="col-3"></div>
	    <div class="col-6 rounded border border-dark" style="background-color: rgb(179, 179, 179)">
	    	<p>Use your credentials to Log in.</p>
			<form>
			  <div class="form-group">
			    <label for="InputUsername"><strong>User name</strong></label>
			    <input type="text" class="form-control bg-light text-dark" id="InputUsername" name="InputUsername">
			  </div>
			  <div class="form-group">
			    <label for="InputPassword"><strong>Password</strong></label>
			    <input type="password" class="form-control bg-light text-dark" id="InputPassword" name="InputPassword">
			  </div>
			  
			  <br>
			  <div class="d-flex justify-content-center">
				<button id="loginButton" name="loginButton" type="submit" class="btn btn-dark" disabled><strong>Sign in</strong></button>
			  </div>
			  
			  <a class="text-dark" href="./register.jsp">or Sign up...</a>
			</form>
			<br>
	    </div>
	    <div class="col-3"></div>
	  </div>
	</div>
	
	<!-- WARNINGS -->
	<br>
	<div class="container">
		<div class="row">
			<div class="col-3"></div>
			<div class="col-6">
				<div class="alert alert-warning" role="alert" style = "display:none" id="existsWarning">
				  The username is not matching with the password!
				</div>
			
				<div class="alert alert-danger" role="alert" style = "display:none" id="userWarning">
				  The User name must be between 1-10 characters!
				</div>
				
				<div class="alert alert-danger" role="alert" id="emptyWarning">
				  All fields must be filled!
				</div>
			</div>
			<div class="col-3"></div>
		</div>
	</div>
	
	<!-- script to check if the inputs are valid -->
	<script>
		// Function to check if there are errors in the form.
		let checkAll = function(){
			// Assumption that it is Valid
			let valid = true;
			
			// Get username value
			let username = $('#InputUsername').val();
			
			// Get password value
			let pass = $('#InputPassword').val();
			
			// Get the button
			let button = $('#loginButton');
			
			// Get the User name warning
			let userWarning = $('#userWarning');
			
			// Check if username between valid values
			if(username.length >= 1 && username.length <= 10){
				userWarning.css('display', 'none');
			}
			else{
				valid = false;
				button.attr('disabled','disabled');
				userWarning.css('display', 'block');
			}
			
			// Get the empty fields warning
			let emptyWarning = $('#emptyWarning');
			if(username.length > 0 && pass.length > 0){
				emptyWarning.css('display', 'none');
			}
			else{
				valid = false;
				button.attr('disabled','disabled');
				emptyWarning.css('display', 'block');
			}
			
			// There are no errors in the form then enable the button
			if(valid) button.removeAttr('disabled');
		};
	
		$('#InputUsername').keyup(checkAll);
		$('#InputPassword').keyup(checkAll);
	</script>
	
	<!-- script to handle error or success messages -->
	<script>
		// Uses the starting java code to know if there was a submission
		let notExistingUser = <%=notExistingUser%>
		if(notExistingUser) $('#existsWarning').css('display', 'block');
	</script>
	
</body>
</html>