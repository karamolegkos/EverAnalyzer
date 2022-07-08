package ever.lib;

// Time tools
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Scanner;

import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.json.JSONObject;

import ever.mr.MRRunner;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.management.ManagementFactory;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;

public class Tools {
	/** The name of a collection Data-set in MongoDB **/
	public static String COLLECTED_DATASET = "collection-dataset";
	
	/** The name of a pre-processed Data-set in MongoDB **/
	public static String PREPROCESSED_DATASET = "preprocessed-dataset";
	
	/** The name of a map-reduced Data-set in MongoDB **/
	public static String MAPREDUCED_DATASET = "mapreduced-dataset";
	
	/** The name of an analyzed Data-set in MongoDB **/
	public static String ANALYZED_DATASET = "analyzed-dataset";
	
	/** A Suggestion of Hadoop_Mahout **/
	public static String HADOOP_MAHOUT = "hadoop";
	
	/** A Suggestion of Spark_MLib **/
	public static String SPARK_MLIB = "spark";
	
	/** A function to get the current Date  
	 * @return The current Date in String format 
	 * **/
	public static String getCurrentDate() {
		DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");  
		LocalDateTime now = LocalDateTime.now();  
		return dtf.format(now);
	}
	
	/** Get the length of a file in HDFS in bytes.
	 * @param path The path of the file
	 * @return The byte size of the path
	 * @throws IOException 
	 * @throws InterruptedException 
	 * **/
	public static String getByteSize(String path) throws IOException, InterruptedException {
		String firstCommad = "hadoop fs -du -s "+path+" > C:\\EverAnalyzer\\size.txt";
		String secondCommand = "exit";
		
		CommandLine.execCommand(firstCommad + " && " + secondCommand);
		CommandLine.waitForSeconds(10);
		
		File file = new File("C:\\EverAnalyzer\\size.txt");
		Scanner myReader = new Scanner(file);
		String bytes = myReader.nextLine().split(" ")[0];
		
		return bytes;
	}
	
	/** A function to get the subfiles inside an HDFS directory
	 * @param filePath The directory to search the files
	 * @param fs The filesystem of the directory
	 * @return list of absolute file path present in given path
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	public static List<String> getAllFilePath(Path filePath, FileSystem fs) throws FileNotFoundException, IOException {
	    List<String> fileList = new ArrayList<String>();
	    FileStatus[] fileStatus = fs.listStatus(filePath);
	    for (FileStatus fileStat : fileStatus) {
	        if (fileStat.isDirectory()) {
	            fileList.addAll(getAllFilePath(fileStat.getPath(), fs));
	        } else {
	            fileList.add(fileStat.getPath().toString());
	        }
	    }
	    return fileList;
	}
	
	/** Adds two Dataset Arrays
	 * @param arrOne The first Array
	 * @param arrTwo The second Array
	 * @return The summed Array
	 * **/
	public static Dataset[] addDatasetArrs(Dataset[] arrOne, Dataset[] arrTwo) {
		Dataset[] arrThree = new Dataset[arrTwo.length + arrOne.length];
		int index = arrTwo.length;

		for (int i = 0; i < arrTwo.length; i++) {
		    arrThree[i] = arrTwo[i];
		}
		for (int i = 0; i < arrOne.length; i++) {
		    arrThree[i + index] = arrOne[i];    
		}
		
		return arrThree;
	}
	
	/**Get the current free disc size of the system
	 * @return The disc size of the system as a long value 
	 * **/
	public static long discSize() {
		File diskPartition = new File("C:");
		long freePartitionSpace = diskPartition.getFreeSpace();
		return freePartitionSpace;
	}
	
	/**Get the RAM size of the system
	 * @return The RAM size of the system as a long value 
	 * **/
	public static long ramSize() {
		return Runtime.getRuntime().freeMemory();
	}
	
	/**Get runtime time in milliseconds
	 * @return The time in a long value
	 * **/
	public static long getTime() {
		Date date = new Date();
		return date.getTime();
	}
	
	public static void preMakeAnalysis(String[] JOB_ATTRS, String[] JOB_TERMS) throws IOException, InterruptedException {
		// Remove HDFS safemode
		CommandLine.removeHDFSSafemode();
		
		// Make the analysis folder if it does not exist
		String path = "C:/EverAnalyzer/analysis";
		File pathAsFile = new File(path);

		if (!Files.exists(Paths.get(path))) {
			pathAsFile.mkdir();
		}
		
		// Make the new file
		String strFile = "C:\\EverAnalyzer\\analysis\\beforeAnalysis.txt";
		File file = new File(strFile); 
    	if(file.exists()) file.delete();
    	file.createNewFile();
    	PrintWriter writer = new PrintWriter(strFile, "UTF-8");
		
		// Start reading the preprocessed file
		BufferedReader reader;
		try {
			reader = new BufferedReader(new FileReader(
					"C:/EverAnalyzer/preprocessing.txt"));
			String line = reader.readLine();
			while (line != null) {
				JSONObject jsonObject = new JSONObject(line);
				
				// Set the "times found" for each term to zero
				int[] amountFound = new int[JOB_TERMS.length];
				for(int i=0; i<amountFound.length; i++) amountFound[i] = 0;
				
				// Now JOB_TERMS and amountFound are parallel
					
				// Check every value of each attribute
				for(String attr : JOB_ATTRS) {
					if(!jsonObject.has(attr)) break;
					String attrValue = jsonObject.get(attr).toString().toLowerCase();
					String[] words = attrValue.split(" ");
					
					// Count the times of every term found in the words
		        	for(String word : words) {
		        		for(int i=0; i<JOB_TERMS.length; i++) {
		        			if(word.equals(JOB_TERMS[i])) {
		        				amountFound[i]++;
		    					break;
		    				}
		        		}
		        	}
				}
				
				String fileLine = amountFound[0]+"";
				for(int i=1; i<amountFound.length; i++) {
					fileLine += " "+amountFound[i];
				}
				
				writer.println(fileLine);
				
				// read next line
				line = reader.readLine();
			}
			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		writer.close();
	}
	
	public static boolean deleteDirectory(String path) {
		File directoryToBeDeleted = new File(path);
	    File[] allContents = directoryToBeDeleted.listFiles();
	    if (allContents != null) {
	        for (File file : allContents) {
	            deleteDirectory(file.getAbsolutePath());
	        }
	    }
	    return directoryToBeDeleted.delete();
	}
}
