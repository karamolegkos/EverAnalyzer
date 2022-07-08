package ever.spark;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.mllib.clustering.KMeans;
import org.apache.spark.mllib.clustering.KMeansModel;
import org.apache.spark.mllib.linalg.Vector;
import org.apache.spark.mllib.linalg.Vectors;
import org.json.JSONObject;

import scala.Tuple2;

public class Spark_Driver {
	
	public static void sparkMapReduce(String[] JOB_ATTRS, String[] JOB_TERMS) throws IOException {
		SparkConf conf = new SparkConf().setAppName("wordCounts").setMaster("local[*]");
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		JavaRDD<String> lines = sc.textFile("C:/EverAnalyzer/preprocessing.txt");
		// JavaRDD<String> words = lines.flatMap(line -> Arrays.asList(line.split(" ")).iterator());
		JavaRDD<String> words = lines.flatMap(line -> {
			String jsonLine = line.toString();
	    	JSONObject jsonObject = new JSONObject(jsonLine);
	    	
	    	// All the words of the line will be here
	    	List<String> finalWords = new ArrayList<>();
	    	
	    	String[] attrs = JOB_ATTRS;
	    	for(String attr: attrs) {
	    		if(!jsonObject.has(attr)) break;
	    		String attrValue = jsonObject.get(attr).toString().toLowerCase();
	    		
	    		String[] sparkWords = attrValue.split(" ");
	    		
	    		// Check if the terms exist in the line
	        	String[] terms = JOB_TERMS;
	    		for(String sparkWord : sparkWords) {
	    			for(String term : terms) {
	    				if(sparkWord.equals(term)) {
	    					finalWords.add(sparkWord);
	    					break;
	    				}
	    			}
	    		}
	    	}
	    	
	    	return finalWords.iterator();
		});
		
		JavaPairRDD<String, Integer> wordAsTuple = words.mapToPair(word -> new Tuple2<>(word, 1));
		JavaPairRDD<String, Integer> wordWithCount = wordAsTuple.reduceByKey((Integer i1, Integer i2) -> i1 + i2);
		List<Tuple2<String, Integer>> output = wordWithCount.collect();
		
		FileWriter fw = new FileWriter("C:/EverAnalyzer/spark.txt");
		for(Tuple2<?, ?> tuple : output) {
			// System.out.println(tuple._1() + ": " + tuple._2());
			fw.write(tuple._1() + "\t" + tuple._2() + "\n");
		}
		
		sc.close();
		fw.close();
		
	}
	
	public static void sparkAnalysis(int numClusters, int numIterations) 
			throws IOException {
		String strInput = "C:/EverAnalyzer/analysis/beforeAnalysis.txt";
		// String strOutput = "hdfs://localhost:9000/EverAnalyzer/"+username+"/analysis/"+label;
		String strOutput = "C:/EverAnalyzer/out";
		
		// Creating a File object that represents the disk file.
		String sparkOutPut = "C:\\EverAnalyzer\\SparkML.txt";
		File sparkOutPutFile = new File(sparkOutPut);
		if (sparkOutPutFile.exists()) sparkOutPutFile.delete();
		sparkOutPutFile.createNewFile();
        PrintStream o = new PrintStream(sparkOutPutFile);
        
        // Store current System.out before assigning a new value
        PrintStream console = System.out;
        
        // Assign o to output stream
        System.setOut(o);
		
		SparkConf conf = new SparkConf().setAppName("Kmeans").setMaster("local[*]");
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		JavaRDD<String> data = sc.textFile(strInput);
		JavaRDD<Vector> parsedData = data.map(
				new Function<String, Vector>(){
					public Vector call(String s) {
						String[] sarray = s.split(" ");
						double[] values = new double[sarray.length];
						for(int i=0; i<sarray.length; i++)
							values[i] = Double.parseDouble(sarray[i]);
						return Vectors.dense(values);
					}
				});
		parsedData.cache();
		
		KMeansModel clusters = KMeans.train(parsedData.rdd(), numClusters, numIterations);
		
		Vector[] centers = clusters.clusterCenters();
		System.out.println("Cluster centers:");
		for(Vector center: centers) {
			System.out.println(center);
		}
		
		System.out.println("Points cluster ID: "+ clusters.predict(parsedData).collect());
		
		clusters.save(sc.sc(), strOutput);
		KMeansModel sameModel = KMeansModel.load(sc.sc(), strOutput);
		sc.close();
		
		// Use stored value for output stream
        System.setOut(console);
	}

}
