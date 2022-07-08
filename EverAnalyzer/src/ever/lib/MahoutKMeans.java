package ever.lib;

import java.io.File;
import java.io.PrintStream;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.mahout.clustering.conversion.InputDriver;
import org.apache.mahout.clustering.kmeans.KMeansDriver;
import org.apache.mahout.clustering.kmeans.RandomSeedGenerator;
import org.apache.mahout.common.HadoopUtil;
import org.apache.mahout.common.distance.DistanceMeasure;
import org.apache.mahout.common.distance.SquaredEuclideanDistanceMeasure;
import org.apache.mahout.utils.clustering.ClusterDumper;

public class MahoutKMeans {
	public static void analysis(int numClusters, int numIterations) throws Exception {
		String strInput = "C:/EverAnalyzer/analysis";
		// String strOutput = "hdfs://localhost:9000/EverAnalyzer/"+username+"/analysis/"+label;
		String strOutput = "C:/EverAnalyzer/out";
		
		// Creating a File object that represents the disk file.
		String mahoutOutPut = "C:\\EverAnalyzer\\Mahout.txt";
		File mahoutOutPutFile = new File(mahoutOutPut);
		if (mahoutOutPutFile.exists()) mahoutOutPutFile.delete();
		mahoutOutPutFile.createNewFile();
        PrintStream o = new PrintStream(mahoutOutPutFile);
        
        // Store current System.out before assigning a new value
        PrintStream console = System.out;
        
        // Assign o to output stream
        System.setOut(o);
		
		Path input = new Path(strInput);
		Path output = new Path(strOutput);
		
		Configuration conf = new Configuration();
		HadoopUtil.delete(conf, output);
		
		run(conf, input, output, new SquaredEuclideanDistanceMeasure(), numClusters, 0.5, numIterations);
		
		// Use stored value for output stream
        System.setOut(console);
	}
	
	public static void run(Configuration conf, Path input, Path output, DistanceMeasure measure, int k, double convergenceDelta, int maxIterations)
			throws Exception {
		Path directoryContainingConvertedInput = new Path(output, "KmeansOutputData");
		InputDriver.runJob(input, directoryContainingConvertedInput, "org.apache.mahout.math.RandomAccessSparseVector");
		
		Path clusters = new Path(output, "random-seeds");
		clusters = RandomSeedGenerator.buildRandom(conf, directoryContainingConvertedInput, clusters, k, measure);
		
		KMeansDriver.run(conf, directoryContainingConvertedInput, clusters, output, convergenceDelta, maxIterations, true, 0.0, false);
		
		Path outGlob = new Path(output, "clusters-*-final");
		Path clusteredPoints = new Path(output, "clusteredPoints");
		
		ClusterDumper clusterDumper = new ClusterDumper(outGlob, clusteredPoints);
		clusterDumper.printClusters(null);
	}
}
