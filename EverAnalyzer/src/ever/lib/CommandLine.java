package ever.lib;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.concurrent.TimeUnit;

import org.apache.commons.io.FileUtils;

public class CommandLine {
	
	/** Start Needed Servers. 
	 * @throws InterruptedException 
	 * @throws IOException **/
	public static void startServers() throws InterruptedException, IOException{
		runKafka();
		runHDFSYARN();
		waitForSeconds(30);
	}
	
	/** Stops Needed Servers. **/
	public static void stopServers() throws InterruptedException{
		stopKafka();
		stopHDFSYARN();
		waitForSeconds(30);
	}
	
	/** Execute a CMD command.
	 * @param command The command to run in the CMD
	 * **/
	public static void execCommand(String command)
    {
        try
        { 
         Runtime.getRuntime().exec("cmd /c start cmd.exe /K \""+command+"\"");
        }
        catch (Exception e)
        {
        	System.out.println("Something is going wrong!");
            e.printStackTrace();
        }
    }
	
	/** Stops everything for an amount of seconds.
	 * @param amount The amount of seconds to freeze everything
	 * **/
	public static void waitForSeconds(int amount) 
			throws InterruptedException {
		TimeUnit.SECONDS.sleep(amount);
	}
	
	/** Run Kafka trough CMD.
	 * @throws InterruptedException
	 * @throws IOException 
	 * **/
	public static void runKafka() 
			throws InterruptedException, IOException {
		FileUtils.deleteDirectory(new File("%KAFKA_HOME%\\zookeeper-data"));
		FileUtils.deleteDirectory(new File("%KAFKA_HOME%\\logs"));
		FileUtils.deleteDirectory(new File("%KAFKA_HOME%\\kafka-logs"));
		
		String firstCommand = "rmdir /s /q %KAFKA_HOME%\\zookeeper-data";
		String secondCommand = "rmdir /s /q %KAFKA_HOME%\\logs";
		String thirdCommand = "rmdir /s /q %KAFKA_HOME%\\kafka-logs";
		String fourthCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand + " && " + fourthCommand);
		
		CommandLine.waitForSeconds(10);
		
		firstCommand = "cd %KAFKA_HOME%";
		secondCommand = ".\\bin\\windows\\zookeeper-server-start.bat .\\config\\zookeeper.properties";
		thirdCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
		
		CommandLine.waitForSeconds(10);
		
		firstCommand = "cd %KAFKA_HOME%";
		secondCommand = ".\\bin\\windows\\kafka-server-start.bat .\\config\\server.properties";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
	}
	
	/** Stop Kafka trough CMD.
	 * @throws InterruptedException
	 * **/
	public static void stopKafka() 
			throws InterruptedException {
		String firstCommand = "cd %KAFKA_HOME%";
		String secondCommand = ".\\bin\\windows\\kafka-server-stop.bat";
		String thirdCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
		
		CommandLine.waitForSeconds(10);
		
		firstCommand = "cd %KAFKA_HOME%";
		secondCommand = ".\\bin\\windows\\zookeeper-server-stop.bat";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
	}
	
	/** Run all the scripts to start HDFS and YARN. **/
	public static void runHDFSYARN() {
		String path = "C:\\EverAnalyzer";
		File pathAsFile = new File(path);

		if (!Files.exists(Paths.get(path))) {
			pathAsFile.mkdir();
		}
		
		String firstCommand = "cd %HADOOP_HOME%/sbin";
		String secondCommand = "start-all.cmd";
		String thirdCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
	}
	
	/** Stop all the scripts running HDFS and YARN. **/
	public static void stopHDFSYARN() {
		String firstCommand = "cd %HADOOP_HOME%/sbin";
		String secondCommand = "stop-all.cmd";
		String thirdCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
	}
	
	/** Makes a new directory inside of the HDFS.
	 * @param dirPath The HDFS path to make the new directory (ex. a/path/here/new_directory)
	 * **/
	public static void addHDFSDir(String dirPath) {
		dirPath = "/"+dirPath;
		String firstCommand = "cd %HADOOP_HOME%/sbin";
		String secondCommand = "hdfs dfsadmin -safemode leave";
		String thirdCommand = "hdfs dfs -mkdir "+dirPath;
		String forthCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " +secondCommand+" && "+ thirdCommand + " && " + forthCommand);
	}
	
	/** Run a Flume agent on a Kafka topic.
	 * @param username The user of the Collection
	 * @param topic The Kafka topic
	 * @throws IOException
	 * **/
	public static void runFlumeAgent(String username, String topic) 
			throws IOException {
		createFlumeAgent(username, topic);	
		
		String firstCommand = "color 5";
		String secondCommand = "cd %FLUME_HOME%";
		String thirdCommand = "bin\\flume-ng agent --conf .\\conf -f conf\\twitter_flume.conf -property \"flume.root.logger=info,console\" -n KafkaAgent";
		CommandLine.execCommand(firstCommand + " && " + secondCommand + " && " + thirdCommand);
	}
	
	/** Make a new Flume Agent inside of the system, able to give data in HDFS.
	 * @param username The user of the collection
	 * @param topic The Kafka topic used
	 * @throws IOException
	 * **/
	public static void createFlumeAgent(String username, String topic)
			throws IOException {
		// Get the file 
		File dest = new File("C:\\apache-flume-1.9.0-bin\\conf\\twitter_flume.conf"); 

		// Delete the file in case it is modified.
		if (dest.exists()) dest.delete();
		
		String inputString = "";
		inputString += "KafkaAgent.sources  = source1\r\n"
				+ "KafkaAgent.channels = channel1\r\n"
				+ "KafkaAgent.sinks = sink1\r\n"
				+ "\r\n"
				+ "KafkaAgent.sources.source1.type = org.apache.flume.source.kafka.KafkaSource\r\n"
				+ "KafkaAgent.sources.source1.kafka.bootstrap.servers = localhost:9092\r\n"
				+ "KafkaAgent.sources.source1.kafka.topics = "+topic+"\r\n"
				+ "KafkaAgent.sources.source1.kafka.consumer.group.id = flume\r\n"
				+ "KafkaAgent.sources.source1.channels = channel1\r\n"
				+ "KafkaAgent.sources.source1.interceptors = i1\r\n"
				+ "KafkaAgent.sources.source1.interceptors.i1.type = timestamp\r\n"
				+ "KafkaAgent.sources.source1.kafka.consumer.timeout.ms = 100\r\n"
				+ "\r\n"
				+ "KafkaAgent.channels.channel1.type = memory\r\n"
				+ "KafkaAgent.channels.channel1.capacity = 10000\r\n"
				+ "KafkaAgent.channels.channel1.transactionCapacity = 1000\r\n"
				+ "\r\n"
				+ "KafkaAgent.sinks.sink1.type = hdfs\r\n"
				+ "KafkaAgent.sinks.sink1.hdfs.path = hdfs://localhost:9000/EverAnalyzer/"+username+"/collected/"+topic+"\r\n"
				+ "KafkaAgent.sinks.sink1.hdfs.rollInterval = 0\r\n"
				+ "KafkaAgent.sinks.sink1.hdfs.rollSize = 0\r\n"
				+ "KafkaAgent.sinks.sink1.hdfs.rollCount = 0\r\n"
				+ "KafkaAgent.sinks.sink1.hdfs.fileType = DataStream\r\n"
				+ "KafkaAgent.sinks.sink1.channel = channel1";
		
		dest.createNewFile();
		FileWriter fr = new FileWriter(dest, true); // parameter 'true' is for append mode
		fr.write(inputString);
		fr.close();
	}
	
	/** Remove HDFS safemode.
	 * @throws InterruptedException 
	 * **/
	public static void removeHDFSSafemode() throws InterruptedException {
		String firstCommand = "cd %HADOOP_HOME%/sbin";
		String secondCommand = "hdfs dfsadmin -safemode leave";
		String thirdCommand = "exit";
		CommandLine.execCommand(firstCommand + " && " +secondCommand+" && "+ thirdCommand);
		CommandLine.waitForSeconds(5);
	}
	
}
