package ever.lib;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

public class DownloadClass {
	
	/** Function to download a Dataset in the system of the user.
	 * @param username The username of the user
	 * @param label The label to be downloaded
	 * @throws IOException 
	 * **/
	public static void downloadDataset(String username, String label) throws IOException {
		/** Get paths **/
		
		Dataset dataset = MongoClass.getDataset(username, label);
		
		// The String input and output
		String outputStr = "C:\\EverAnalyzer\\download\\text.txt";
		String inputStr = "hdfs://localhost:9000/EverAnalyzer/"+username+"/";
		
		// Use in the input the Kind of the Dataset
		if(dataset.getKind().equals(Tools.COLLECTED_DATASET))	inputStr += "collected/";
		if(dataset.getKind().equals(Tools.PREPROCESSED_DATASET))inputStr += "preprocessed/";
		if(dataset.getKind().equals(Tools.MAPREDUCED_DATASET)) 	inputStr += "map-reduce/";
		if(dataset.getKind().equals(Tools.ANALYZED_DATASET)) 	inputStr += "analysis/";
		
		// Use in the input the label of the Dataset
		inputStr += label;
		
		// Use the final path of the input
		if(dataset.getKind().equals(Tools.COLLECTED_DATASET)) {
			Configuration conf = new Configuration();
			conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
			conf.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));
			
			String filePath = inputStr;
			Path path = new Path(filePath);
			FileSystem fs = path.getFileSystem(conf);
			inputStr = Tools.getAllFilePath(new Path(filePath), fs).get(0);
		}
		if(dataset.getKind().equals(Tools.PREPROCESSED_DATASET)) {
			inputStr += "/preprocessing.txt";
		}
		if(dataset.getKind().equals(Tools.MAPREDUCED_DATASET)) {
			if(dataset.getFramework().equals(Tools.HADOOP_MAHOUT))	inputStr += "/part-00000";
			if(dataset.getFramework().equals(Tools.SPARK_MLIB))		inputStr += "/spark.txt";;
		}
		if(dataset.getKind().equals(Tools.ANALYZED_DATASET)) {
			if(dataset.getFramework().equals(Tools.HADOOP_MAHOUT))	inputStr += "/Mahout.txt";
			if(dataset.getFramework().equals(Tools.SPARK_MLIB))		inputStr += "/SparkML.txt";;
		}
		
		/** Make the folder and the needed file **/
		
		// Make the download folder if it does not exist
		String path = "C:/EverAnalyzer/download";
		File pathAsFile = new File(path);

		if (!Files.exists(Paths.get(path))) {
			pathAsFile.mkdir();
		}
		
		// Make the new file
		String strFile = outputStr;
		File file = new File(strFile); 
    	if(file.exists()) file.delete();
    	file.createNewFile();
    	
    	/** Download the file **/
    	PrintWriter writer = new PrintWriter(strFile, "UTF-8");
    	
    	// Copy the HDFS file inside the new file
    	Configuration configuration = new Configuration();
    	configuration.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\core-site.xml"));
    	configuration.addResource(new Path("C:\\hadoop-3.1.0\\etc\\hadoop\\hdfs-site.xml"));

		String hdfsFile = inputStr;

		Path pathh = new Path(hdfsFile);
		FileSystem fs = pathh.getFileSystem(configuration);
		FSDataInputStream inputStream = fs.open(pathh);
		String line = null;
		int a = 0;
		while((line = inputStream.readLine()) != null) {
			writer.println(line);
		}
		fs.close();
		writer.close();
	}
}
