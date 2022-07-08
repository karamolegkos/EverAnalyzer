package ever.mr;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.File;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.mapred.JobConf;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.mapred.TextInputFormat;
import org.apache.hadoop.mapred.TextOutputFormat;
import org.apache.hadoop.mapred.FileInputFormat;
import org.apache.hadoop.mapred.FileOutputFormat;
import org.apache.hadoop.mapred.JobClient;

public class MRRunner {
	public static String[] JOB_TERMS;
	public static String[] JOB_ATTRS;
	
	public static void doMapReduceJob(String username, String childLabel, String label) throws IOException {
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
		
		// Start the job.
		JobConf conf = new JobConf(MRRunner.class); 
		conf.setJobName(username+"-"+label);
		
		conf.setOutputKeyClass(Text.class);    
		conf.setOutputValueClass(IntWritable.class);
		
		conf.setMapperClass(MRMapper.class);    
		conf.setCombinerClass(MRReducer.class);   
		conf.setReducerClass(MRReducer.class); 
		
		conf.setInputFormat(TextInputFormat.class);    
		conf.setOutputFormat(TextOutputFormat.class);   
		
		String arguments[] = new String[2];
		arguments[0] = strFile; 																//Input file
		arguments[1] = "hdfs://localhost:9000/EverAnalyzer/"+username+"/map-reduce/"+label; 	//Output directory      
		FileInputFormat.setInputPaths(conf, new Path(arguments[0]));    
		FileOutputFormat.setOutputPath(conf, new Path(arguments[1]));     
		
		try{
			
			JobClient.runJob(conf);
			
		}
		catch (Exception e){
			e.printStackTrace();
			System.out.println(e.getMessage());
			
		}
	}
}
