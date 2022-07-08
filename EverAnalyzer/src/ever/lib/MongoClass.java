package ever.lib;

import com.mongodb.BasicDBObject;
// Mongo Imports
import com.mongodb.MongoClient;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;
import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import static com.mongodb.client.model.Filters.eq;

// Utils
import org.bson.Document;

import java.io.IOException;
// Hashing
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Set;  

public class MongoClass {
	
	/** MongoDB HOST **/
	private static String HOST = "localhost";
	
	/** MongoDB PORT **/
	private static int PORT = 27017;
	
	/** EverAnalyzer Database name **/
	private static String DB_NAME = "EverAnalyzerDB";
	
	/** Hashing Algorithm **/
	private static String HASH_ALGO = "SHA-256";
	
	/** A Mongo Client to access the Database.
	 * Gets initiated after the creation of a MongoClass object. **/
	private static MongoClient mongoClient;
	
	/** The EverAnalyzer MongoDB.
	 * Gets initiated after the creation of a MongoClass object. **/
	private static MongoDatabase database;
	
	/** MongoClass constructor. Makes the connection with the MongoDB database.
	 * **/
	public MongoClass() {
		// Connect to Database
		mongoClient = new MongoClient(HOST, PORT);
		database = mongoClient.getDatabase(DB_NAME);
	}
	
	/** Check the authentication of a user.
	 * @param username User's username
	 * @param password User's password
	 * @return True if authenticated. False if not.
	 * @throws NoSuchAlgorithmException 
	 * **/
	public static boolean authenticateUser(String username, String password) throws NoSuchAlgorithmException {
		// If user does not exist then he is unauthorized
		if(!userExist(username)) return false;
		
		// Get the hash of users password
		String hashedPassword = getStringHash(password, HASH_ALGO);
		
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Make Query to find if the user is authenticated
		BasicDBObject andQuery = new BasicDBObject();
	    List<BasicDBObject> obj = new ArrayList<BasicDBObject>();
	    obj.add(new BasicDBObject("username", username));
	    obj.add(new BasicDBObject("password", hashedPassword));
	    andQuery.put("$and", obj);
	    
	    // Check if user is authenticated
	    FindIterable<Document> iterable = userCollection.find(andQuery);		
		return iterable.first() != null;
	}
	
	/** Check if a username already exists.
	 * @param username User's username
	 * @return True if user exists in the database. False if not.
	 * **/
	public static boolean userExist(String username) {
		// Get the collection of the user and try to find the starting record.
		// Not trying to find the collection because this action would take O(N) time.
		// Instead the action below takes O(1)
		FindIterable<Document> iterable = database.getCollection(username)
				.find(new Document("username", username));
		
		return iterable.first() != null;
	}
	
	/** Add a new user in the database.
	 * @param username New user's username
	 * @param password New user's password
	 * @throws NoSuchAlgorithmException 
	 * **/
	public static void addUser(String username, String password) throws NoSuchAlgorithmException {
		// Get the collection containing all the users
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Generate hash for users password
		String hashedPassword = getStringHash(password, HASH_ALGO);
		
		// Generate credentials record
		Document credentials = new Document("username", username)
				.append("password", hashedPassword);
		
		// Insert credentials in the new collection
		userCollection.insertOne(credentials);
	}
	
	/** Hash a String.
	 * @param str The String to get hashed
	 * @param hashType The hashing algorithm (Includes "SHA-256")
	 * @throws NoSuchAlgorithmException
	 * @return The hash of the String in String format.
	 * **/
	private static String getStringHash(String str, String hashType) throws NoSuchAlgorithmException {
		// hash string into byte array
		MessageDigest md = MessageDigest.getInstance(hashType);
		byte[] hashbytes = md.digest(str.getBytes());

		// convert byte array into hex string and return
		StringBuffer stringBuffer = new StringBuffer();
		for (int i = 0; i < hashbytes.length; i++) {
			stringBuffer.append(Integer.toString((hashbytes[i] & 0xff) + 0x100, 16)
				.substring(1));
		}
		return stringBuffer.toString();
	}
	
	/** Check if a label exists for a user.
	 * @param username The needed username
	 * @param label the name of the label
	 * @return True if label already exists. False if not.
	 * **/
	public static boolean checkLabel(String username, String label) {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Search for the label
		Document doc = userCollection.find(eq("label", label)).first();
		
		if (doc == null) return false;
		else return true;
	}
	
	/** Find and return an existing Document 
	 * @param username The needed username
	 * @param filter The filter of the searching
	 * @param value The value to match with the filter
	 * @return The Document found
	 * **/
	public static Document getDoc(String username, String filter, String value) {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Search for the label
		Document doc = userCollection.find(eq(filter, value)).first();
		return doc;
	}
	
	/** Add the record of Collected data for a user.
	 * @param username The user of the Dataset
	 * @param label The label of the Dataset
	 * @param keywords The String Array of Keywords used
	 * @param tweetsAmount The amount of Tweets gathered
	 * @throws IOException 
	 * @throws InterruptedException 
	 * **/
	public static void addCollection(String username, String label, String[] keywords, int tweetsAmount) throws IOException, InterruptedException {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Generate Dataset record
		CommandLine.waitForSeconds(5);
		Document dataset = new Document("byte-size", Tools.getByteSize("/EverAnalyzer/"+username+"/collected/"+label))
				.append("HDFS-path", "EverAnalyzer/"+username+"/collected/"+label)
				.append("tweets-amount", tweetsAmount)
				.append("keywords", Arrays.asList(keywords))
				.append("datetime", Tools.getCurrentDate())
				.append("label", label)
				.append("dataset-kind", Tools.COLLECTED_DATASET);
		
		userCollection.insertOne(dataset);
	}
	
	/** Checks if a Datasets of a kind exists.
	 * @param username The user to search for
	 * @param datasetKind The kind of the Dataset to search for
	 * @return True if there is one existing. False if not.
	 * **/
	public static boolean datasetExists(String username, String datasetKind) {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Search for any "dataset-kind" named as the given kind
		Document doc = userCollection.find(eq("dataset-kind", datasetKind)).first();
		
		if (doc == null) return false;
		else return true;
	}
	
	/** Get the array of the given labeled Dataset of a user
	 * @param username The username of the user
	 * @param label The label of the searched Dataset
	 * @param kind The name of the Array
	 * @return The List of the value gathered from the MongoDB collection as an Array
	 * **/
	public static String[] getDatasetArray(String username, String label, String kind) {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Search for any "label" named the given label
		Document doc = userCollection.find(eq("label", label)).first();
		
		// Get the Array
		List<String> list = doc.getList(kind, String.class);
		String[] array = list.toArray(new String[0]);
		return array;
	}
	
	/** Get all the Datasets of a kind from a user.
	 * @param username The user to search for
	 * @param datasetKind The kind of the Dataset to search for
	 * @return All the Datasets as a Java Array.
	 * **/
	public static Dataset[] getDatasets(String username, String datasetKind) {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Search for the Datasets of the given kind
		FindIterable<Document> docs = userCollection.find(eq("dataset-kind", datasetKind));
		
		// Get all Datasets as a Java Array
		List<Dataset> datasets = new ArrayList<Dataset>();
		for (Document document : docs) {
			Dataset dataset = new Dataset();
			dataset.setLabel(document.get("label", String.class));
			dataset.setSize(document.get("byte-size", String.class));
			dataset.setAmount(document.get("tweets-amount", Integer.class));
			dataset.setDate(document.get("datetime", String.class).substring(0, 10));
			
			List<String> keywordsList = document.getList("keywords", String.class);
			String[] keywords = keywordsList.toArray(new String[0]);
			dataset.setKeywords(keywords);
			
			// Add pre-processing attributes if it is a pre-processed Dataset or above
			if(datasetKind.equals(Tools.PREPROCESSED_DATASET) ||
					datasetKind.equals(Tools.MAPREDUCED_DATASET) ||
					datasetKind.equals(Tools.ANALYZED_DATASET)) {
				dataset.setParentLabel(document.get("parent-label", String.class));
				
				List<String> fieldsList = document.getList("kept-fields", String.class);
				String[] fields = fieldsList.toArray(new String[0]);
				dataset.setFields(fields);
			}
			
			if(datasetKind.equals(Tools.MAPREDUCED_DATASET)) {
				dataset.setChildLabel(document.get("child-label", String.class));
				dataset.setLatency(document.get("latency", Long.class));
				dataset.setFramework(document.get("framework", String.class));
				dataset.setPreSize(document.get("pre-byte-size", String.class));
				dataset.setKind(Tools.MAPREDUCED_DATASET);
				dataset.setPreSize(document.get("pre-byte-size", String.class));
			}
			
			if(datasetKind.equals(Tools.ANALYZED_DATASET)) {
				dataset.setChildLabel(document.get("child-label", String.class));
				dataset.setLatency(document.get("latency", Long.class));
				dataset.setFramework(document.get("framework", String.class));
				dataset.setPreSize(document.get("pre-byte-size", String.class));
				dataset.setClusters(document.get("numClusters", Integer.class));
				dataset.setIterations(document.get("numIterations", Integer.class));
				dataset.setKind(Tools.ANALYZED_DATASET);
				dataset.setPreSize(document.get("pre-byte-size", String.class));
			}
			
			datasets.add(dataset);
		}
		
		return datasets.toArray(new Dataset[0]);
	}
	
	/** Add the record of Pre-processed data for a user.
	 * @param username The user of the Dataset
	 * @param label The label of the Dataset
	 * @param fields The String Array of fields still existing
	 * @param tweetsAmount The amount of Tweets in the Dataset
	 * @param keywords The keywords used to get the Tweets
	 * @param parentLabel The label that this Dataset got made of
	 * @throws IOException  
	 * @throws InterruptedException 
	 * **/
	public static void addPreprocess(String username, String label, String[] fields, int tweetsAmount, String[] keywords, String parentLabel) 
			throws InterruptedException, IOException {
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Generate Dataset record
		Document dataset = new Document("byte-size", Tools.getByteSize("/EverAnalyzer/"+username+"/preprocessed/"+label))
				.append("HDFS-path", "EverAnalyzer/"+username+"/preprocessed/"+label)
				.append("tweets-amount", tweetsAmount)
				.append("keywords", Arrays.asList(keywords))
				.append("kept-fields", Arrays.asList(fields))
				.append("datetime", Tools.getCurrentDate())
				.append("label", label)
				.append("parent-label", parentLabel)
				.append("dataset-kind", Tools.PREPROCESSED_DATASET);
		
		userCollection.insertOne(dataset);
	}
	
	/**Function to gather all the Datasets from a specific kind across all the EverAnalyzer Database
	 * @param datasetKind The kind of the Datasets to gather
	 * @return The Datasets as a Dataset Array
	 * **/
	public static Dataset[] getAllDatasets(String datasetKind) {
		MongoIterable<String> collections = database.listCollectionNames();
		
		// parse and gather all the Datasets
		Dataset[] allDatasets = new Dataset[0];
		for (String collection : collections) {
			Dataset[] someDatasets = getDatasets(collection, datasetKind);
			allDatasets = Tools.addDatasetArrs(someDatasets, allDatasets);
		}
		
		return allDatasets;
	}
	
	/**Add the record of Map-Reduced data for a user.
	 * @param username The user of the Dataset
	 * @param childLabel The label of the preprocessed data
	 * @param label The label of the Dataset
	 * @param framework The framework used
	 * @param latency The latency of the analysis
	 * @throws IOException  
	 * @throws InterruptedException 
	 * **/
	public static void addMapReduce(String username, String childLabel, String label, String framework, long latency)  
			throws IOException, InterruptedException {
		// Get the Pre-processing Document
		Document preDataset = getDoc(username, "label", childLabel);
		
		List<String> keywordsList = preDataset.getList("keywords", String.class);
		String[] keywords = keywordsList.toArray(new String[0]);
		
		List<String> fieldsList = preDataset.getList("kept-fields", String.class);
		String[] fields = fieldsList.toArray(new String[0]);
		
		String parentLabel = preDataset.getString("parent-label");
		
		String preByteSize = preDataset.getString("byte-size");
		
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Generate Dataset record
		Document dataset = new Document("byte-size", Tools.getByteSize("/EverAnalyzer/"+username+"/map-reduce/"+label))
				.append("HDFS-path", "/EverAnalyzer/"+username+"/map-reduce/"+label)
				.append("tweets-amount", preDataset.getInteger("tweets-amount"))
				.append("pre-byte-size", preByteSize)
				.append("keywords", Arrays.asList(keywords))
				.append("kept-fields", Arrays.asList(fields))
				.append("datetime", Tools.getCurrentDate())
				.append("label", label)
				.append("parent-label", parentLabel)
				.append("child-label", childLabel)
				.append("framework", framework)
				.append("latency", latency)
				.append("dataset-kind", Tools.MAPREDUCED_DATASET);
		
		userCollection.insertOne(dataset);
	}
	
	/**Add the record of K-means data for a user.
	 * @param username The user of the Dataset
	 * @param childLabel The label of the preprocessed data
	 * @param label The label of the Dataset
	 * @param framework The framework used
	 * @param latency The latency of the analysis
	 * @param numClusters The amount of clusters found
	 * @param numIterations The max amount of Iterations done
	 * @throws IOException  
	 * @throws InterruptedException 
	 * **/
	public static void addAnalysis(String username, String childLabel, String label, String framework, long latency, int numClusters, int numIterations)  
			throws IOException, InterruptedException {
		// Get the Pre-processing Document
		Document preDataset = getDoc(username, "label", childLabel);
		
		List<String> keywordsList = preDataset.getList("keywords", String.class);
		String[] keywords = keywordsList.toArray(new String[0]);
		
		List<String> fieldsList = preDataset.getList("kept-fields", String.class);
		String[] fields = fieldsList.toArray(new String[0]);
		
		String parentLabel = preDataset.getString("parent-label");
		
		String preByteSize = preDataset.getString("byte-size");
		
		// Get the users collection
		MongoCollection<Document> userCollection = database.getCollection(username);
		
		// Generate Dataset record
		Document dataset = new Document("byte-size", Tools.getByteSize("/EverAnalyzer/"+username+"/analysis/"+label))
				.append("HDFS-path", "/EverAnalyzer/"+username+"/analysis/"+label)
				.append("tweets-amount", preDataset.getInteger("tweets-amount"))
				.append("pre-byte-size", preByteSize)
				.append("keywords", Arrays.asList(keywords))
				.append("kept-fields", Arrays.asList(fields))
				.append("datetime", Tools.getCurrentDate())
				.append("label", label)
				.append("parent-label", parentLabel)
				.append("child-label", childLabel)
				.append("framework", framework)
				.append("latency", latency)
				.append("numClusters", numClusters)
				.append("numIterations", numIterations)
				.append("dataset-kind", Tools.ANALYZED_DATASET);
		
		userCollection.insertOne(dataset);
	}
	
	/** Returns a Dataset as a class
	 * @param username The user who owns the Dataset
	 * @param label The unique label of the Dataset
	 * @return The Dataset as a Dataset Class
	 * **/
	public static Dataset getDataset(String username, String label) {
		// Get the Document
		Document document = getDoc(username, "label", label);
		String datasetKind = document.get("dataset-kind", String.class);
		
		Dataset dataset = new Dataset();
		dataset.setLabel(document.get("label", String.class));
		dataset.setSize(document.get("byte-size", String.class));
		dataset.setAmount(document.get("tweets-amount", Integer.class));
		dataset.setDate(document.get("datetime", String.class).substring(0, 10));
		dataset.setKind(datasetKind);
		
		List<String> keywordsList = document.getList("keywords", String.class);
		String[] keywords = keywordsList.toArray(new String[0]);
		dataset.setKeywords(keywords);
		
		if(datasetKind.equals(Tools.PREPROCESSED_DATASET) ||
				datasetKind.equals(Tools.MAPREDUCED_DATASET) ||
				datasetKind.equals(Tools.ANALYZED_DATASET)) {
			
			dataset.setParentLabel(document.get("parent-label", String.class));
		
			List<String> fieldsList = document.getList("kept-fields", String.class);
			String[] fields = fieldsList.toArray(new String[0]);
			dataset.setFields(fields);
			
			dataset.setChildLabel(document.get("child-label", String.class));
		}
		
		if(datasetKind.equals(Tools.MAPREDUCED_DATASET)) {
			dataset.setLatency(document.get("latency", Long.class));
			dataset.setFramework(document.get("framework", String.class));
			dataset.setPreSize(document.get("pre-byte-size", String.class));
			dataset.setKind(Tools.MAPREDUCED_DATASET);
		}
		
		if(datasetKind.equals(Tools.ANALYZED_DATASET)) {
			dataset.setLatency(document.get("latency", Long.class));
			dataset.setFramework(document.get("framework", String.class));
			dataset.setPreSize(document.get("pre-byte-size", String.class));
			dataset.setClusters(document.get("numClusters", Integer.class));
			dataset.setIterations(document.get("numIterations", Integer.class));
			dataset.setKind(Tools.ANALYZED_DATASET);
		}
		
		return dataset;
	}
	
}
