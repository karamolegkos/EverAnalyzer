package ever.lib;

import java.util.Properties;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;

import com.google.common.collect.Lists;
import com.twitter.hbc.ClientBuilder;
import com.twitter.hbc.core.Client;
import com.twitter.hbc.core.Constants;
import com.twitter.hbc.core.endpoint.StatusesFilterEndpoint;
import com.twitter.hbc.core.processor.StringDelimitedProcessor;
import com.twitter.hbc.httpclient.auth.Authentication;
import com.twitter.hbc.httpclient.auth.OAuth1;

public class KafkaTwitterProducer {
	
	/** Gets the Tweets using a Flume agent and Kafka (Flafka).
	 * It will run successfully only if the Flume agent is running as a process in the system.
	 * @param consumerKey The Twitter consumer key of the analyst 
	 * @param consumerSecret The Twitter consumer secret of the analyst
	 * @param token The Twitter token of the analyst
	 * @param secret The Twitter secret of the analyst
	 * @param terms A String Array containing all the keywords to search for in the Tweets
	 * @param flumeTopicName The name of the Kafka topic to be used for the ingestion
	 * @param amountOfTweets An integer showcasing the amount of Tweets to be collected by Flafka
	 * **/
	public static void getKafkaTweets(String consumerKey,	// The consumer key to get the Twitter data
			String consumerSecret,					// The consumer secret to get the Twitter data
			String token,							// The token to get the Twitter data
			String secret,							// The secret to get the Twitter data
			String[] terms,							// All the keywords to search in the tweets
			String flumeTopicName,					// The name of the Kafka topic the user wants to use
			int amountOfTweets						// The amount of tweets the user wants to get
			) {
		Properties props = new Properties();
		props.put("bootstrap.servers", "localhost:9092");
		props.put("acks", "all");
		props.put("retries", 0);
		props.put("batch.size", 16384);
		props.put("linger.ms", 1);
		props.put("buffer.memory", 33554432);
		props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
		props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
		
		Producer<String, String> producer = null;
		try {
			producer = new KafkaProducer<>(props);
			BlockingQueue<String> queue = new LinkedBlockingQueue<String>(10000);
			StatusesFilterEndpoint endpoint = new StatusesFilterEndpoint();
			endpoint.trackTerms(Lists.newArrayList(terms)); // keywords
			Authentication auth = new OAuth1(consumerKey, consumerSecret, token, secret);
			
			Client client = new ClientBuilder()
					.hosts(Constants.STREAM_HOST)
					.endpoint(endpoint)
					.authentication(auth)
					.processor(new StringDelimitedProcessor(queue))
					.build();
			client.connect();
			
			for(int i = 0; i < amountOfTweets; i++) {	// max number of tweets that we want
				String msg = queue.take();
				producer.send(new ProducerRecord<String, String>(flumeTopicName, msg));
			}
			producer.close();
			client.stop();
		}
		catch(Exception e){
			System.out.println(e);
		}
	}
}
