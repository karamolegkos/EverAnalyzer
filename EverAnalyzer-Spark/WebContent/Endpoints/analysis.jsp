<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="ever.spark.Spark_Driver" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
<%
String dataset = request.getParameter("dataset");
String size = request.getParameter("size");

String username = request.getParameter("username");
String label = request.getParameter("label");
int numClusters = Integer.parseInt(request.getParameter("numClusters"));
int numIterations = Integer.parseInt(request.getParameter("numIterations"));

Spark_Driver.sparkAnalysis(numClusters, numIterations);

response.sendRedirect("http://localhost:8080/EverAnalyzer/Interface/Views/Analyze/DatasetForm/dataset.jsp?dataset="+request.getParameter("dataset")+
		"&size="+request.getParameter("size")+
		"&start="+request.getParameter("start")+
		"&AnalysisLabel="+request.getParameter("AnalysisLabel")+
		"&numClusters="+request.getParameter("numClusters")+
		"&numIterations="+request.getParameter("numIterations")+
		"&sparked=true");
%>
</body>
</html>