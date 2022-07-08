package ever.lib;

public class Dataset {
	
	/** The kind of the given Dataset **/
	private String kind;
	
	/** The label of the given Dataset **/
	private String label;
	
	/** The Amount of Tweets this Dataset is containing **/
	private int amount;
	
	/** The size of the Dataset in bytes **/
	private String size;
	
	/** The keywords used to collect the Dataset **/
	private String[] keywords;
	
	/** The Date that the given Dataset was collected **/
	private String date;
	
	/** Pre-processing --> Fields that have been kept after the pre-processing phase **/
	private String[] fields;
	
	/** Pre-processing --> The Collection used to get the pre-processed Dataset **/
	private String parentLabel;
	
	/** Analysis --> The pre-processing used to get the analyzed or map-reduced Dataset **/
	private String childLabel;
	
	/** The latency of the analyzed Dataset **/
	private long latency;
	
	/** The Framework used for the analyzed Dataset **/
	private String framework;
	
	/** The pre-processed size of the Dataset in bytes **/
	private String preSize;
	
	/** The Amount of Clusters contained in Analytics Results  **/
	private int clusters;
	
	/** The Amount of max Iterations done in Analytics Results  **/
	private int iterations;
	
	/** Default Constructor **/
	public Dataset() {}
	
	/** Kind Setter.
	 * @param kind The kind of the Dataset
	 * **/
	public void setKind(String kind) {
		this.kind = kind;
	}
	
	/** Label Setter.
	 * @param label The label of the Dataset
	 * **/
	public void setLabel(String label) {
		this.label = label;
	}
	
	/** Tweets Amount Setter.
	 * @param amount The amount of the Dataset
	 * **/
	public void setAmount(int amount) {
		this.amount = amount;
	}
	
	/** Clusters Setter.
	 * @param clusters The amount of clusters in the results
	 * **/
	public void setClusters(int clusters) {
		this.clusters = clusters;
	}
	
	/** Iterations Setter.
	 * @param iterations The iterations in the results
	 * **/
	public void setIterations(int iterations) {
		this.iterations = iterations;
	}
	
	/** Size Setter.
	 * @param size The size of the Dataset in bytes as a String
	 * **/
	public void setSize(String size) {
		this.size = size;
	}
	
	/** Size Setter.
	 * @param preSize The size of the pre-processed Dataset in bytes as a String
	 * **/
	public void setPreSize(String preSize) {
		this.preSize = preSize;
	}
	
	/** Latency Setter.
	 * @param latency The latency of the Dataset's analysis speed
	 * **/
	public void setLatency(long latency) {
		this.latency = latency;
	}
	
	/** Framework Setter.
	 * @param framework The Framework of the Dataset's analysis
	 * **/
	public void setFramework(String framework) {
		this.framework = framework;
	}
	
	/** Keywords Setter.
	 * @param keywords The keywords of the Dataset as a String Array
	 * **/
	public void setKeywords(String[] keywords) {
		this.keywords = keywords;
	}
	
	/** Date Setter.
	 * @param date The date of the Dataset's collection
	 * **/
	public void setDate(String date) {
		this.date = date;
	}
	
	/** Kept Fields Setter.
	 * @param fields The kept fields of the pre-processed Dataset as a String Array
	 * **/
	public void setFields(String[] fields) {
		this.fields = fields;
	}
	
	/** Parent Label Setter.
	 * @param parentLabel The label of the parent Dataset
	 * **/
	public void setParentLabel(String parentLabel) {
		this.parentLabel = parentLabel;
	}
	
	/** Child Label Setter.
	 * @param childLabel The label of the parent Dataset
	 * **/
	public void setChildLabel(String childLabel) {
		this.childLabel = childLabel;
	}
	
	/** Kind Getter.
	 * **/
	public String getKind() {
		return this.kind;
	}
	
	/** Label Getter.
	 * **/
	public String getLabel() {
		return this.label;
	}
	
	/** Tweets Amount Getter.
	 * **/
	public int getAmount() {
		return this.amount;
	}
	
	/** Clusters Getter.
	 * **/
	public int getClusters() {
		return this.clusters;
	}
	
	/** Iterations Getter.
	 * **/
	public int getIterations() {
		return this.iterations;
	}
	
	/** Size Getter.
	 * **/
	public String getSize() {
		return this.size;
	}
	
	/** Pre-Size Getter.
	 * **/
	public String getPreSize() {
		return this.preSize;
	}
	
	/** Keywords Getter.
	 * **/
	public String[] getKeywords() {
		return this.keywords;
	}
	
	/** Date Getter.
	 * **/
	public String getDate() {
		return this.date;
	}
	
	/** Parent Label Getter.
	 * **/
	public String getParentLabel() {
		return this.parentLabel;
	}
	
	/** Child Label Getter.
	 * **/
	public String getChildLabel() {
		return this.childLabel;
	}
	
	/** Framework Getter.
	 * **/
	public String getFramework() {
		return this.framework;
	}
	
	/** Latency Getter.
	 * **/
	public long getLatency() {
		return this.latency;
	}
	
	/** Kept Fields Getter.
	 * **/
	public String[] getFields() {
		return this.fields;
	}
	

}
