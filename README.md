# gcp-dns-update

GCP Cloud Function to update Cloud DNS Records

It is an implementation variant for DynDNS with GCP Cloud DNS.

## Installation

### Create a GCP Cloud function

Reference to the function name *queryHandler*.

### Let the bash script run with the following paramentes:

-z [ ZONENAME ]       # The name of the GCP Cloud DNS Zone

-f [ FQDN ]           # The FQDN of the DNS record to update

-u [ FUNCTION_URL ]   # The URL of the GCP Cloud function

-t [ TOKEN ]          # The secret token to allow the execution of the GCP Cloud function
