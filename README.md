# gcp-dns-update

Bash script to update a DNS A and AAAA record in a GCP Cloud DNS zone

with the hosts public IP addresses.


It should run in the [Alpine based gcloud container](https://gcr.io/google.com/cloudsdktool/google-cloud-cli).


## Usage

Mount the script and the service account key file into the same folder in the container.

Set the work directory to the directory where the script and key file is mounted to.

Name the key file ```service_account.json```


### Parameters

Let the bash script run with the following paramentes:

-z [ ZONENAME ]       # The name of the GCP Cloud DNS Zone

-d [ DOMAIN ]         # The DOMAIN of the DNS record to update

-p [ PROJECT_ID ]     # The GCP Project ID

-t [ TTL ]            # The TTL for the records

-4 [ UPDATE_V4 ]      # Update the IPv4 address [true/false]

-6 [ UPDATE_V6 ]      # Update the IPv6 address [true/false]

### Example Command

```bash
podman run \
  --rm \
  -v ${PWD}:/update:z \
  -w /update \
  gcr.io/google.com/cloudsdktool/google-cloud-cli:alpine \
  ./update.sh \
    -z ZONENAME \
    -d DOMAIN \
    -p PROJECT_ID \
    -t 60 \
    -4 true \
    -6 true
```