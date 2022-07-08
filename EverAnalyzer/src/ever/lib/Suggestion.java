package ever.lib;

public class Suggestion {
	/**A function to suggest Hadoop Map Reduce or Spark Map Reduce on a given Dataset's size
	 * @param bytesize The size of the Dataset
	 * @return The suggestion between Hadoop or spark
	 * **/
	public static String mapReduce(String bytesize) {
		// Get the integer form of the bytesize
		int size = Integer.parseInt(bytesize);
		
		// Get all the Map-Reduce Datasets
		Dataset[] datasets = MongoClass.getAllDatasets(Tools.MAPREDUCED_DATASET);
		
		// Assumption than no framework found
		String suggestion = "none";
		
		// Parse Datasets in a O(n^2) way
		for(int i=0; i<datasets.length; i++) {
			if(!suggestion.equals("none")) break;	// Break if a suggestion has been found
			// Get currents Dataset's values
			int preSize = Integer.parseInt(datasets[i].getPreSize());
			String framework = datasets[i].getFramework();
			long latency = datasets[i].getLatency();
			
			if(size > preSize) {	// For smaller Datasets than the given
				// Not Hadoop then continue
				if(!framework.equals(Tools.HADOOP_MAHOUT)) continue;
				
				// parse all the other Datasets to find some spark Datasets
				for(int j=0; j<datasets.length; j++) {
					// Get values of the tested Datasets
					int testPreSize = Integer.parseInt(datasets[j].getPreSize());
					String testFramework = datasets[j].getFramework();
					long testLatency = datasets[j].getLatency();
					
					// If not spark then continue
					if(!testFramework.equals(Tools.SPARK_MLIB)) continue;
					
					// If not smaller byte size than the current one then continue
					if(preSize < testPreSize) continue;
					
					// If not bigger latency than the current one then continue;
					if(latency > testLatency) continue;
					
					// HADOOP SUGGESTION
					suggestion = Tools.HADOOP_MAHOUT;
					break;
				}
			}
			else {					// For bigger Datasets than the given
				// Not Hadoop then continue
				if(!framework.equals(Tools.HADOOP_MAHOUT)) continue;
				
				// parse all the other Datasets to find some spark Datasets
				for(int j=0; j<datasets.length; j++) {
					// Get values of the tested Datasets
					int testPreSize = Integer.parseInt(datasets[j].getPreSize());
					String testFramework = datasets[j].getFramework();
					long testLatency = datasets[j].getLatency();
					
					// If not spark then continue
					if(!testFramework.equals(Tools.SPARK_MLIB)) continue;
					
					// If not bigger byte size than the current one then continue
					if(preSize > testPreSize) continue;
					
					// If not smaller latency than the current one then continue;
					if(latency < testLatency) continue;
					
					// SPARK SUGGESTION
					suggestion = Tools.SPARK_MLIB;
					break;
				}
			}
		}
		
		// If there has not been any suggestions yet
		// Then make a recommendation based on the systems resources as a last resort 
		if(suggestion.equals("none")) {
			long discSize = Tools.discSize();
			long ramSize = Tools.ramSize();
			if(discSize > ramSize) suggestion = Tools.HADOOP_MAHOUT;
			if(discSize <= ramSize) suggestion = Tools.SPARK_MLIB;
		}
		
		return suggestion;
	}
	
	public static String analysis(String bytesize) {
		// Get the integer form of the bytesize
		int size = Integer.parseInt(bytesize);
		
		// Get RAM
		long ramSize = Tools.ramSize();
		
		// Use Mahout only if RAM is less than the dataset size
		if(ramSize < size) return Tools.HADOOP_MAHOUT;
		else return Tools.SPARK_MLIB;
	}
}
