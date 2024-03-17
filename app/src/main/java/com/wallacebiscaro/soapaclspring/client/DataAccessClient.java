package com.wallacebiscaro.soapaclspring.client;

import com.wallacebiscaro.soapaclspring.client.config.DataAccessConfig;
import com.wallacebiscaro.soapaclspring.client.gen.NumberToWords;
import com.wallacebiscaro.soapaclspring.client.gen.NumberToWordsResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(
        name = "dataAccess",
        url = "${dataaccess.soap.url}",
        configuration = DataAccessConfig.class)
public interface DataAccessClient {
    @PostMapping(produces = MediaType.TEXT_XML_VALUE, consumes = MediaType.TEXT_XML_VALUE)
    NumberToWordsResponse numberToWord(@RequestBody NumberToWords request);
}
