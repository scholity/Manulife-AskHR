/**
 * 	ocms_mfc_IPUtility
 *
 * 	Some IP-related methods, like getUserIPAddress(), and methods to convert string IPs to their integer equivalent (and vice versa),
 * 	but mostly it defines isInternalIP() which uses a Custom Settings table, Internal_IP_Ranges__c, that defines a list of internal
 * 	IP ranges.
 *
 * 	2015-Oct-15	Bill Lucas
 * 				Original
 * 				
 */
public with sharing class ocms_mfc_IPUtility {
	
	//public ocms_mfc_IPUtility() {}


	/**
	 * 
	 */
	public class ipIntRange {
	    public Long startIP;
	    public Long endIP;
	    
	    public ipIntRange(Long starting, Long ending) {
	        startIP = starting;
	        endIP = ending;
	    }
	}	// ipIntRange


	public static List<ipIntRange> internalIPs = null;		// new List<ipIntRange>();


	/**
	 * return client IP as a String, as stored in page header properties as listed
	 *
	 * borrowed from http://www.forcedisturbances.com/2012/05/limiting-access-to-visual-force-pages.html
	 * 
	 * @return user’s IP address as string
	 */
	
	public static String getUserIPAddress() {
		String sIP = '';  

		try {
			// True-Client-IP has the value when the request is coming via the caching integration
			sIP = ApexPages.currentPage().getHeaders().get('True-Client-IP');

			// X-Salesforce-SIP has the value when no caching integration or via secure URL
			if (String.IsBlank(sIP)) {
				sIP = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
			} // get IP address when no caching (sandbox, dev, secure urls)

			if (String.IsBlank(sIP)) {
				sIP = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
			} // get IP address from standard header if proxy in use
		} catch (Exception ex) {
			System.Debug(ex);
		}

		if (Test.isRunningTest() && sIP == null) {
			sIP = '167.92.59.0';		// just.testing.thanks.!
		}

		return sIP;
	}	// GetUserIPAddress


	/**
	 * [ipOctetsToLong description]
	 * @param  oct1 [description]
	 * @param  oct2 [description]
	 * @param  oct3 [description]
	 * @param  oct4 [description]
	 * @return      [description]
	 */
	public static Long ipOctetsToLong(String oct1, String oct2, String oct3, String oct4) {
	    return (Long.valueOf(oct1) << 24) + (Long.valueOf(oct2) << 16) + (Long.valueOf(oct3) << 8) + Long.valueOf(oct4);
	}	// ipOctetsToLong


	/**
	 * [longToIPOctets description]
	 * @param  ip [description]
	 * @return    [description]
	 */
	public static String longToIPOctets(Long ip) {
	    String oct1 = '';
	    String oct2 = '';
	    String oct3 = '';
	    String oct4 = '';
	    
	    oct1 = String.valueOf(ip >>> 24);   // shift off all but the 8 most significant bits
	    oct2 = String.valueOf((ip >>> 16) & 255);   
	    oct3 = String.valueOf((ip >>> 8) & 255);
	    oct4 = String.valueOf(ip & 255);    // just take the 8 least significant bits

	    return oct1 + '.' + oct2 + '.' + oct3 + '.' + oct4;
	}	// longToIPOctets


	/**
	 * [ipRangeFromCIDR description]
	 * @param  cidr String - IPv4 CIDR formatted IP range, like 205.67.0.100/21
	 * @return      ipIntRange
	 */
	public static ipIntRange ipRangeFromCIDR(String cidr) {    
	    final Pattern patCIDR = Pattern.compile('(\\d{1,3}).(\\d{1,3}).(\\d{1,3}).(\\d{1,3})/(\\d{1,2})?');
	    final Matcher matCIDR = patCIDR.matcher(cidr);
	    Long startingInt = 0;
	    Long rangeIncrement = 0;
	  
	    if (matCIDR.find()) {
	        if (matCIDR.groupCount() == 5) {
	            Integer netPrefixShifter = Integer.valueOf(matCIDR.group(5));
	            final Long ffffffff = 4294967295L;    /*0xFFFFFFFF*/
	            if (netPrefixShifter > 0) {
	                rangeIncrement = ffffffff >>> netPrefixShifter;
	            }
	            startingInt = ipOctetsToLong(matCIDR.group(1), matCIDR.group(2), matCIDR.group(3), matCIDR.group(4));
	        }
	    } else {
	        System.debug('Ooops - did not find CIDR pattern!');
	    }
	    
	    return new ipIntRange(startingInt, startingInt + rangeIncrement);
	}   // ipRangeFromCIDR


	private static void loadInternalIPs() {
		if (internalIPs == null) {
			System.debug('•• initializing internalIPs list…');
			internalIPs = new List<ipIntRange>();

			List <Internal_IP_Ranges__c> ranges = [SELECT Name, CIDR__c, RangeStart__c, RangeEnd__c FROM Internal_IP_Ranges__c];

			if (ranges.size() > 0) {
				System.Debug('•••• ' + ranges.size() + ' range entries found in Internal_IP_Ranges__c');
				for (Internal_IP_Ranges__c r : ranges) {
				    String cidr = (String) r.get('CIDR__c');
				    System.Debug('• adding ' + cidr + ' to list');

					if (r.RangeStart__c != null && r.RangeEnd__c != null && r.RangeStart__c > 0 && r.RangeEnd__c > 0) {
						internalIPs.add(new ipIntRange((Long) r.RangeStart__c, (Long) r.RangeEnd__c));
					}
				}
				System.Debug('----');
			} else {
				System.Debug('•••• no range data found within Internal_IP_Ranges__c');
			}
		} 
	}


	static public Long stringIPToLong(String dottedQuad) {
	    String[] octets = dottedQuad.split('\\.');
	    Long ip = (Long.valueOf(octets[0]) << 24) + (Long.valueOf(octets[1]) << 16) + (Long.valueOf(octets[2]) << 8) + Long.valueOf(octets[3]);
	                                                                                                                             
		return ip;                                                                                                                             
	}


	static public Boolean isInternalIP() {
		return isInternalIP(getUserIPAddress());
	}


	/**
	 * Is the given string IP (IPv4 dotted quad) in one of the IP ranges found in Custom Settings object Internal_IP_Ranges__c?
	 * @param  ip String IPv4 dotted quad, like 192.255.0.38
	 * @return    Boolean
	 */
	static public Boolean isInternalIP(String ip) {
		Boolean bIsInternal = false;
		Long lIP = stringIPToLong(ip);

		loadInternalIPs();

		for (ipIntRange r : internalIPs) {
			//System.Debug(' ? ' + r.startIP + ' <= ' + lIP + ' <= ' + r.endIP);
			if (r.startIP <= lIP && lIP <= r.endIP) {
				bIsInternal = true;
				//System.Debug('•• Internal! •• ' + ip);
				break;
			}
		}

		return bIsInternal;
	}	// isInternalIP


    /**
     *  intended to be invoked through anonymous apex, at least initially
     */
    static public String updateIPRangeValues() {
    	String statusMsg = '\n••• Yikes, something wrong happened here! Does the Custom Setting object "Internal_IP_Ranges" exist?\n';

    	try {
	        List <Internal_IP_Ranges__c> ranges = [SELECT Name, CIDR__c, RangeStart__c, RangeEnd__c FROM Internal_IP_Ranges__c];
	        System.Debug(ranges);

	        Integer nRanges = ranges.size();
	        Integer nCIDR = 0;
	        if (nRanges > 0) {
		        statusMsg = '\n••• Converting CIDR values to integer equivalents…\n';
		        for (Internal_IP_Ranges__c r : ranges) {
		            String cidr = (String) r.get('CIDR__c');

		            if (String.isNotEmpty(cidr)) {
		            	++nCIDR;
			            ipIntRange intRange = ipRangeFromCIDR(cidr); 
			            System.Debug('• ' + cidr + ' - ' + longToIPOctets(intRange.startIP) + ' … ' + longToIPOctets(intRange.endIP) + ' (' + intRange.startIP + ' — ' + intRange.endIP + ']');
			             
			            r.RangeStart__c = intRange.startIP;
			            r.RangeEnd__c = intRange.endIP;
			        } else {
			        	// should never happen based on object edit rules
			        	statusMsg += '\n  - empty CIDR field found!\n';
			        }
		        }
		        update ranges;
		        
		        statusMsg += '\n••• converted ' + nCIDR + ' of ' + nRanges + ' Internal_IP_Range pairs\n';
		    } else {
		        statusMsg = '\n••• No records found within "Internal_IP_Range". Populate it with CIDR values and try again.\n';
		    }

	 	} catch (Exception ex) {
	 		System.Debug(statusMsg);
	 	}

 		return statusMsg;
    }   // updateIPRangeValues
}