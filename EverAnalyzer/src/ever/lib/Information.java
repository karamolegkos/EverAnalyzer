package ever.lib;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.json.JSONObject;

public class Information {
	
	public static JSONObject[] getCollectionInfo(String username, String label) 
			throws IOException {
		// Initiate values for the reading of the parent collection
		Configuration conf = new Configuration();
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));
		
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		String filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/collected/"+label;
		Path path = new Path(filePath);
		FileSystem fs = path.getFileSystem(conf);
		
		filePath = Tools.getAllFilePath(new Path(filePath), fs).get(0);
		
		path = new Path(filePath);
		fs = path.getFileSystem(conf);
		FSDataInputStream inputStream = fs.open(path);
		
		// List of JSONs
		List<JSONObject> jsonList = new ArrayList<>();
		
		String line = null;
		while((line = inputStream.readLine()) != null) {
		  if(line.equals("")) continue;
		  jsonList.add(new JSONObject(line));
		}
		fs.close();
		
		JSONObject[] jsonArray = new JSONObject[jsonList.size()];
		for(int i = 0; i < jsonList.size(); i++) jsonArray[i] = jsonList.get(i);
		
		return jsonArray;
	}
	
	public static JSONObject[] getPreprocessInfo(String username, String label) 
			throws IOException {
		Configuration conf = new Configuration();
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));

		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		String filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/preprocessed/"+label+"/preprocessing.txt";

		Path path = new Path(filePath);
		FileSystem fs = path.getFileSystem(conf);
		FSDataInputStream inputStream = fs.open(path);

		// List of JSONs
		List<JSONObject> jsonList = new ArrayList<>();
		
		String line = null;
		while((line = inputStream.readLine()) != null) {
			if(line.equals("")) continue;
			jsonList.add(new JSONObject(line));
		}
		fs.close();
		
		JSONObject[] jsonArray = new JSONObject[jsonList.size()];
		for(int i = 0; i < jsonList.size(); i++) jsonArray[i] = jsonList.get(i);
		
		return jsonArray;
	}

	public static String[][] getMapReduceInfo(String username, String label, String framework) 
			throws IOException {
		return HDFSTransferring.getMapReduceResults(username, label, framework);
	}

	public static String[] getAnalysisInfo(String username, String label, String framework) 
			throws IOException {
		Configuration conf = new Configuration();
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));

		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		
		// Find the filePath in the HDFS
		String filePath = "";
		if(framework.equals(Tools.SPARK_MLIB))
			filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/analysis/"+label+"/SparkML.txt";
		
		if(framework.equals(Tools.HADOOP_MAHOUT))
			filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/analysis/"+label+"/Mahout.txt";

		Path path = new Path(filePath);
		FileSystem fs = path.getFileSystem(conf);
		FSDataInputStream inputStream = fs.open(path);
		// System.out.println(inputStream.available());
		
		List<String> stringList = new ArrayList<>();
		
		String line = null;
		while((line = inputStream.readLine()) != null) {
			stringList.add(line);
		}
		fs.close();
		
		String[] stringArray = new String[stringList.size()];
		for(int i = 0; i < stringList.size(); i++) stringArray[i] = stringList.get(i);
		
		return stringArray;
	}
}
