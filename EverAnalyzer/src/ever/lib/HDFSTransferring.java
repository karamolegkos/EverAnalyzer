package ever.lib;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.json.JSONArray;
import org.json.JSONObject;

public class HDFSTransferring {
	
	/** Function to download a file from HDFS
	 * @param username The username of the user who id loged in
	 * @param childLabel The label of the preprocessed Data to be downloaded
	 * @throws IOException
	 * **/
	public static void getFileFromHDFS(String username, String childLabel) 
			throws IOException {
		// Create a temp file to save the HDFS Dataset file.
		String strFile = "C:\\EverAnalyzer\\preprocessing.txt";
		File file = new File(strFile); 
    	if(file.exists()) file.delete();
    	file.createNewFile();
    	PrintWriter writer = new PrintWriter(strFile, "UTF-8");
    	
    	// Copy the HDFS file inside the new file
    	Configuration configuration = new Configuration();
    	configuration.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
    	configuration.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));

		String hdfsFile = "hdfs://localhost:9000/EverAnalyzer/"+username+"/preprocessed/"+childLabel+"/preprocessing.txt";

		Path path = new Path(hdfsFile);
		FileSystem fs = path.getFileSystem(configuration);
		FSDataInputStream inputStream = fs.open(path);
		String line = null;
		int a = 0;
		while((line = inputStream.readLine()) != null) {
			writer.println(line);
		}
		fs.close();
		writer.close();
	}
	
	/** Function to upload a map-reduce job to the HDFS from the local system
	 * @param username The username of the loged in user
	 * @param label The label to give to the map-reduce results
	 * @throws IOException
	 * **/
	public static void putFileToHDFS(String username, String label) throws IOException {
		BufferedReader reader;
		
		Configuration configuration = new Configuration();
		configuration.set("fs.defaultFS", "hdfs://localhost:9000");
		FileSystem fileSystem = FileSystem.get(configuration);
		
		//Create a path
		String fileName = "spark.txt";
		// using "/" in the start of the path will ensure to get the exact path that I want
		Path hdfsWritePath = new Path("/EverAnalyzer/"+username+"/map-reduce/"+label+"/"+ fileName);
		FSDataOutputStream fsDataOutputStream = fileSystem.create(hdfsWritePath,true);
		BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(fsDataOutputStream,StandardCharsets.UTF_8));
		
		try {
			reader = new BufferedReader(new FileReader(
					"C:\\EverAnalyzer\\spark.txt"));
			String line = reader.readLine();
			while (line != null) {
				/** Output the results to the HDFS **/
				bufferedWriter.write(line);
				bufferedWriter.newLine();
				
				// read next line
				line = reader.readLine();
			}
			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		bufferedWriter.close();
		fileSystem.close();
	}
	
	/** Upload a generic file to HDFS from the local system
	 * @param path The local path
	 * @param hdfsPath The link to uplaod the file
	 * @throws IOException
	 * **/
	public static void uploadToHDFS(String path, String hdfsPath) 
			throws IOException {
		BufferedReader reader;
		
		Configuration configuration = new Configuration();
		configuration.set("fs.defaultFS", "hdfs://localhost:9000");
		FileSystem fileSystem = FileSystem.get(configuration);
		
		//Create a path
		String fileName = "spark.txt";
		// using "/" in the start of the path will ensure to get the exact path that I want
		Path hdfsWritePath = new Path(hdfsPath);
		FSDataOutputStream fsDataOutputStream = fileSystem.create(hdfsWritePath,true);
		BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(fsDataOutputStream,StandardCharsets.UTF_8));
		
		try {
			reader = new BufferedReader(new FileReader(path));
			String line = reader.readLine();
			while (line != null) {
				/** Output the results to the HDFS **/
				bufferedWriter.write(line);
				bufferedWriter.newLine();
				
				// read next line
				line = reader.readLine();
			}
			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		bufferedWriter.close();
		fileSystem.close();
	}
	
	/** A function to get the Map-Reduce results from the HDFS
	 * @param username The username of the loged in user
	 * @param label The label of the Map-Reduce job
	 * @param framework The framework used
	 * @throws IOException 
	 * **/
	public static String[][] getMapReduceResults(String username, String label, String framework) 
			throws IOException {
		Configuration conf = new Configuration();
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));

		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		
		// Find the filePath in the HDFS
		String filePath = "";
		if(framework.equals(Tools.SPARK_MLIB))
			filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/map-reduce/"+label+"/spark.txt";
		
		if(framework.equals(Tools.HADOOP_MAHOUT))
			filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/map-reduce/"+label+"/part-00000";

		Path path = new Path(filePath);
		FileSystem fs = path.getFileSystem(conf);
		FSDataInputStream inputStream = fs.open(path);
		// System.out.println(inputStream.available());
		
		// The results
		List<String[]> results = new ArrayList<>();
		
		String line = null;
		while((line = inputStream.readLine()) != null) {
		  String[] values = line.split("\t");
		  results.add(values);
		}
		fs.close();
		
		String[][] finalResults = new String[results.size()][2];
		for(int i = 0; i < results.size(); i++) finalResults[i] = results.get(i);
		
		return finalResults;
	}
	
	/** A function to get the Analytics results from the HDFS
	 * @param username The username of the loged in user
	 * @param label The label of the Analytics job
	 * @param framework The framework used
	 * @param keywordsAmount The amount of keywords used
	 * @throws IOException 
	 * **/
	public static JSONObject getAnalysisResults(String username, String label, String framework, int keywordsAmount) 
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
		
		// The results
		JSONObject results = new JSONObject();
		
		if(framework.equals(Tools.SPARK_MLIB)) {
			// Helping values
			int i = 0;
			String line = null;
			
			// Clusters
			List<float[]> clusters = new ArrayList<>();
			
			// Amount of points in every cluster
			int[] amounts = new int[clusters.size()];
			
			while((line = inputStream.readLine()) != null) {
				i++;
				if(i>1) {
					if(!line.startsWith("P")) {
						// Gather the centers of the clusters
						line = line.replace("[", "");
						line = line.replace("]", "");
						String[] cluster = line.split(",");
						
						float[] floatCluster = new float[cluster.length];
						for(int j=0; j<cluster.length; j++) floatCluster[j] = Float.parseFloat(cluster[j]);
						
						clusters.add(floatCluster);
					}
					else {
						// Gather the amount of points in a cluster
						line = line.replace("Points cluster ID: ", "");
						line = line.replace("[", "");
						line = line.replace("]", "");
						line = line.replace(" ", "");
						String[] ids = line.split(",");
						
						// Initialize amounts
						amounts = new int[clusters.size()];
						for(int j=0; j<clusters.size(); j++) amounts[j] = 0;
						
						// Start counting
						for(int j=0; j<ids.length; j++) {
							amounts[Integer.parseInt(ids[j])]++;
						}
						
					}
				}
			}
			results.put("clusters", clusters);
			results.put("amounts", amounts);
			
			fs.close();
		}
		
		if(framework.equals(Tools.HADOOP_MAHOUT)) {
			// Clusters
			List<float[]> clusters = new ArrayList<>();
			
			// Amount of points in every cluster
			int[] amounts = new int[clusters.size()];
			
			List<Integer> listOfAmounts = new ArrayList<>();
			
			String line = null;
			while((line = inputStream.readLine()) != null) {
				JSONObject jsonLine;
				
				// only view lines that are JSON data
				try {
					jsonLine = new JSONObject(line);
				}
				catch(Exception e) {
					continue;
				}
				// Find amounts
				listOfAmounts.add(jsonLine.getInt("n")-1);
				
				// Get the center of the cluster
				float[] floatCluster = new float[keywordsAmount];
				
				// helping values
				int k = 0;
				int i = 0;
				JSONArray centroids = jsonLine.getJSONArray("c");
				
				for(i=0; i<floatCluster.length; i++) {
					if(k == centroids.length()) break;
					JSONObject centroid = centroids.getJSONObject(k);
					
					if(centroid.has(i+"")) {
						floatCluster[i] = centroid.getFloat(i+"");
						k++;
					}
					else {
						floatCluster[i] = 0;
					}
				}
				for(int j=i; j<floatCluster.length; j++) {
					floatCluster[j] = 0;
				}
				clusters.add(floatCluster);
			}
			
			amounts = new int[listOfAmounts.size()];
			for(int i = 0; i < listOfAmounts.size(); i++) amounts[i] = listOfAmounts.get(i);
			
			results.put("clusters", clusters);
			results.put("amounts", amounts);
			
			fs.close();
		}
		
		return results;
	}
}
