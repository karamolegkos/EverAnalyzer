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
String attrs = request.getParameter("attrs");
String terms = request.getParameter("terms");

String[] JOB_ATTRS = attrs.split(",");
String[] JOB_TERMS = terms.split(",");

Spark_Driver.sparkMapReduce(JOB_ATTRS, JOB_TERMS);

response.sendRedirect("http://localhost:8080/EverAnalyzer/Interface/Views/MapReduce/DatasetForm/dataset.jsp?dataset="+request.getParameter("dataset")+
		"&size="+request.getParameter("size")+
		"&start="+request.getParameter("start")+
		"&MapReduceLabel="+request.getParameter("MapReduceLabel")+
		"&sparked=true");
%>
</body>
</html>