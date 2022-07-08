package ever.mr;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapred.MapReduceBase;
import org.apache.hadoop.mapred.Mapper;
import org.apache.hadoop.mapred.OutputCollector;
import org.apache.hadoop.mapred.Reporter;
import org.json.JSONObject;

public class MRMapper extends MapReduceBase implements Mapper<LongWritable,Text,Text,IntWritable>{
	
	public void map(LongWritable key, Text value, OutputCollector<Text, IntWritable> output, Reporter reporter) throws IOException 
    {    
    	String jsonLine = value.toString();
    	JSONObject jsonObject = new JSONObject(jsonLine);
    	
    	String[] attrs = MRRunner.JOB_ATTRS;
    	for(String attr: attrs) {
    		if(!jsonObject.has(attr)) break;
    		String attrValue = jsonObject.get(attr).toString().toLowerCase();
    		
    		String[] words = attrValue.split(" ");
    		
    		// Check if the terms exist in the line
        	String[] terms = MRRunner.JOB_TERMS;
    		// gives 1 for every searching term in the line
    		for(String word : words) {
    			for(String term : terms) {
    				if(word.equals(term)) {
    					output.collect(new Text(word), new IntWritable(1));
    					break;
    				}
    			}
    		}
    	}
    }
}
