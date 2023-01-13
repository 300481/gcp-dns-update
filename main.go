package main

import (
	"fmt"
	"net/http"
)

func updateRecords(zoneName, fqdn, ipv4, ipv6 string) {
	return
	// TODO: GCP Cloud DNS implementation
}

func queryHandler(w http.ResponseWriter, r *http.Request) {
	queryParams := r.URL.Query()

	token := queryParams.Get("token")
	// TODO: permission check by token
	zoneName := queryParams.Get("zoneName")
	fqdn := queryParams.Get("fqdn")
	ipv4 := queryParams.Get("ipv4")
	ipv6 := queryParams.Get("ipv6")

	fmt.Fprintf(w, "zoneName: %s\nfqdn: %s\nipv4: %s\nipv6: %s\ntoken: %s\n", zoneName, fqdn, ipv4, ipv6, token)
	fmt.Printf("zoneName: %s\nfqdn: %s\nipv4: %s\nipv6: %s\ntoken: %s\n", zoneName, fqdn, ipv4, ipv6, token)

	updateRecords(zoneName, fqdn, ipv4, ipv6)
}

func main() {
	http.HandleFunc("/query", queryHandler)
	http.ListenAndServe(":8080", nil)
}
