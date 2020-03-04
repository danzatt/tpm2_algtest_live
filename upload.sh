#!/bin/sh

FILE_1="subor.txt"
A_NAZEV_1="test_nazev"
A_POPIS_1="test popis"
TEXT_MAILU="Hello mail"

curl 'https://is.muni.cz/dok/depository_in?vybos_vzorek_last=&vybos_vzorek=469348&vybos_hledej=Vyhledat+osobu' \
	-H'Connection: keep-alive' \
	-H'Accept: */*' \
	-H'Origin: https://is.muni.cz' \
	-H'X-Requested-With: XMLHttpRequest' \
	-H'User-Agent: tpm2-algtest-ui' \
	-H'Content-Type: multipart/form-data;' \
	-H'Sec-Fetch-Site: same-origin' \
	-H'Sec-Fetch-Mode: cors' \
	-H'Referer: https://is.muni.cz/dok/depository_in?vybos_vzorek_last=&vybos_vzorek=469348&vybos_hledej=Vyhledat+osobu' \
	-H'Accept-Encoding: gzip, deflate, br' \
	-H'Accept-Language: en-US,en;q=0.9' \
	-F'quco=469348' \
	-F'vlsozav=najax' \
	-F'ajax-upload=ajax' \
	-F"FILE_1=@$FILE_1" \
	-F"A_NAZEV_1=$A_NAZEV_1" \
	-F"A_POPIS_1=$A_POPIS_1" \
	-F"TEXT_MAILU=$TEXT_MAILU" \
	--compressed
#	--data-binary $'------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="quco"\r\n\r\n469348\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="vlsozav"\r\n\r\najax\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="ajax-upload"\r\n\r\najax\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="A_NAZEV_1"\r\n\r\n\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="A_POPIS_1"\r\n\r\n\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="TEXT_MAILU"\r\n\r\ntest\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn\r\nContent-Disposition: form-data; 
#name="FILE_1"; file
#name="checkrain.gpr"\r\nContent-Type: application/octet-stream\r\n\r\n\r\n------WebKitFormBoundaryWeBKX6GAIBRKJmgn--\r\n' \
