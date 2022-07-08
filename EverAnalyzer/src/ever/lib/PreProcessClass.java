package ever.lib;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.json.JSONArray;
import org.json.JSONObject;

//Utils
import org.bson.Document;

public class PreProcessClass {
	
	/** Function to automate the pre-processing of EverAnalyzer
	 * @param username The username of the user
	 * @param label The label of the new Dataset after the pre-processing
	 * @param fields The fields that the user wants to keep after the pre-processing
	 * @param parentLabel The label of the collection that will be pre-processed
	 * @throws InterruptedException
	 * @throws IOException
	 * **/
	public static void preProcessData(String username, String label, String[] fields, String parentLabel) 
			throws InterruptedException, IOException{
		// Make the new directory inside the HDFS
		CommandLine.addHDFSDir("EverAnalyzer/"+username+"/preprocessed");
		CommandLine.waitForSeconds(20);
		CommandLine.addHDFSDir("EverAnalyzer/"+username+"/preprocessed/"+label);
		CommandLine.waitForSeconds(20);

		// Initiate values for the reading of the parent collection
		Configuration conf = new Configuration();
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
		conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));
		
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		String filePath = "hdfs://localhost:9000/EverAnalyzer/"+username+"/collected/"+parentLabel;
		Path path = new Path(filePath);
		FileSystem fs = path.getFileSystem(conf);
		
		filePath = Tools.getAllFilePath(new Path(filePath), fs).get(0);
		
		path = new Path(filePath);
		fs = path.getFileSystem(conf);
		FSDataInputStream inputStream = fs.open(path);
		// System.out.println(inputStream.available());
		
		// Initiate values for the writing of the child preprocessing
		Configuration configuration = new Configuration();
		configuration.set("fs.defaultFS", "hdfs://localhost:9000");
		FileSystem fileSystem = FileSystem.get(configuration);
		//Create a path
		String fileName = "preprocessing.txt";
		// using "/" in the start of the path will ensure to get the exact path that I want
		Path hdfsWritePath = new Path("/EverAnalyzer/"+username+"/preprocessed/"+label+"/"+ fileName);
		FSDataOutputStream fsDataOutputStream = fileSystem.create(hdfsWritePath,true);
		BufferedWriter bufferedWriter = new BufferedWriter(new OutputStreamWriter(fsDataOutputStream,StandardCharsets.UTF_8));
		
		/** Output the results to the HDFS **/
		// bufferedWriter.write("Hello from java");
		// bufferedWriter.newLine();
		// fileSystem.close();
		
		// Start reading line by line (Tweet by Tweet)
		String line = null;
		int tweetsLeft = 0;
		while((line = inputStream.readLine()) != null) {
			// If empty line the continue
			if(line.equals("")) {
				continue;
			}
			// Initiate Object to write and the Object to read from
			JSONObject objToWrite = new JSONObject();
			JSONObject objToRead = new JSONObject(line);
			
			// The amount of the fields added
			int addedFields = 0;
			
			// For each Tweet check all the given fields
			for(String field : fields) {
				// Get all the broken fields of the subfield
				String[] subfields = field.split("-");
				
				// Get the Tweet
				JSONObject value = objToRead;
				String objValue = null;
				
				// Assume it will be written in the output
				boolean writable = true;
				
				// Get the value of the subfield
				int subfieldCount = 0;
				for(String subfield : subfields) {
					subfieldCount++;
					try {
						// When there is the next subfield hold the inner value
						objValue = value.get(subfield).toString();
					}
					catch(Exception e){
						// There is no such inner field
						writable = false;
						break;
					}
					
					try {
						// Try to get the value as a JSON object for the next iteration
						value = new JSONObject(objValue);
					}
					catch(Exception e) {
						// There must not be a next iteration
						if(subfieldCount == (subfields.length)) {
							break;
						}
						else {
							// The field that the user asked for will not be existing
							writable = false;
							break;
						}
					}
				}
				
				// Add the field with the value to the object to write
				if(writable) {
					// objToWrite.put(field, objValue);
					// addedFields++;
					
					try {
						// Try to use a JSONObject value
						objToWrite.put(field, new JSONObject(objValue));
					}
					catch(Exception e1) {
						try {
							// Try to use a JSONArray value
							objToWrite.put(field, new JSONArray(objValue));
						}
						catch(Exception e2){
							// Just add a String value
							objToWrite.put(field, objValue);
						}
					}
					addedFields++;
				}
			}
			// Write the formated Tweet after the preprocessing if some fields have been added
			if(addedFields>0) {
				bufferedWriter.write(objToWrite.toString());
				bufferedWriter.newLine();
				tweetsLeft++;
			}
		}
		bufferedWriter.close();
		// fs.close();
		
		// Update MongoDB with the new record
		updateMongo(username, label, fields, tweetsLeft, parentLabel);
	}
	
	/** A function to help update the MongoDB pf EverAnalyzer with the pre-processing done
	 * @param username The username of the user
	 * @param label The label that the pre-processing was done
	 * @param fields The fields that the pre-processing left
	 * @param tweetsAmount The amount of Tweets left after the pre-processing
	 * @param parentLabel The label of the collection given for pre-processing
	 * @throws InterruptedException
	 * @throws IOException
	 * **/
	public static void updateMongo(String username, String label, String[] fields, int tweetsAmount, String parentLabel) 
			throws InterruptedException, IOException {
		Document doc = MongoClass.getDoc(username, "label", parentLabel);
		
		List<String> keywordsList = (List<String>) doc.get("keywords");
		String[] keywords = keywordsList.toArray(new String[0]);
		
		MongoClass.addPreprocess(username, label, fields, tweetsAmount, keywords, parentLabel);
	}
}
