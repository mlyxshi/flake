package monitoring

import (
	"io"
	"net/http"
	"regexp"
)

var userAgent = "curl/8.0.1"

func GetIPv4Address() (string, error) {
	webAPIs := []string{"https://ip.sb", "https://api.ipify.org?format=json"}

	for _, api := range webAPIs {
		// get ipv4
		req, err := http.NewRequest("GET", api, nil)
		if err != nil {
			continue
		}
		req.Header.Set("User-Agent", userAgent)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			continue
		}
		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			continue
		}
		// 使用正则表达式从响应体中提取IPv4地址
		re := regexp.MustCompile(`\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}`)
		ipv4 := re.FindString(string(body))
		if ipv4 != "" {
			return ipv4, nil
		}
	}
	return "", nil
}

func GetIPv6Address() (string, error) {
	webAPIs := []string{"https://api6.ipify.org?format=json", "https://ipv6.icanhazip.com"}

	for _, api := range webAPIs {
		// get ipv6
		req, err := http.NewRequest("GET", api, nil)
		if err != nil {
			continue
		}
		req.Header.Set("User-Agent", userAgent)
		resp, err := http.DefaultClient.Do(req)
		if err != nil {
			continue
		}
		defer resp.Body.Close()
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			continue
		}
		// 使用正则表达式从响应体中提取IPv6地址
		re := regexp.MustCompile(`([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])`)
		ipv6 := re.FindString(string(body))
		if ipv6 != "" {
			return ipv6, nil
		}
	}
	return "", nil
}

func GetIPAddress() (ipv4, ipv6 string, err error) {
	ipv4, err = GetIPv4Address()
	if err != nil {
		ipv4 = ""
	}
	ipv6, err = GetIPv6Address()
	if err != nil {
		ipv6 = ""
	}

	return ipv4, ipv6, nil
}
