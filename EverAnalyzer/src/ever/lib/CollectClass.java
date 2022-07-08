package ever.lib;

import java.io.IOException;

public class CollectClass {
	
	/**A function to collect Data from the Twitter Database using Kafka and Flume
	 * @param consumerKey The Twitter consumer key of the Analyst
	 * @param consumerSecret The Twitter consumer secret of the Analyst
	 * @param token The Twitter token of the Analyst
	 * @param secret The Twitter secret of the Analyst
	 * @param username The user's username
	 * @param label The label for the collection
	 * @param keywords The keywords that will be used to collect data from Twitter
	 * @param tweetsAmount The amount of Tweets to be collected
	 * @throws InterruptedException
	 * @throws IOException
	 * **/
	public static void collectData(String consumerKey, String consumerSecret,
			String token, String secret,
			String username, String label, String[] keywords, int tweetsAmount
			) throws InterruptedException, IOException {
		CommandLine.addHDFSDir("EverAnalyzer/"+username+"/collected/"+label);
		CommandLine.waitForSeconds(30);
		CommandLine.runFlumeAgent(username, label);
		CommandLine.waitForSeconds(30);
		
		KafkaTwitterProducer.getKafkaTweets(consumerKey,	
				consumerSecret,					
				token,							
				secret,							
				keywords,							
				label,					
				tweetsAmount);
		
		CommandLine.waitForSeconds(10);
	}
}
