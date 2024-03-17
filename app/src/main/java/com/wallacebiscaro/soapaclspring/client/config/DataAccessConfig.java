package com.wallacebiscaro.soapaclspring.client.config;

import feign.codec.Decoder;
import feign.codec.Encoder;
import feign.jaxb.JAXBContextFactory;
import feign.soap.SOAPDecoder;
import feign.soap.SOAPEncoder;
import org.springframework.context.annotation.Bean;


public class DataAccessConfig {
    private static final JAXBContextFactory jaxbFactory = new JAXBContextFactory.Builder()
            .withMarshallerSchemaLocation("${dataaccess.soap.url} ${dataaccess.soap.wsdl}")
            .build();

    @Bean
    Encoder soapEncoder() {
        return new SOAPEncoder(jaxbFactory);
    }

    @Bean
    Decoder soapDecoder() {
        return new SOAPDecoder(jaxbFactory);
    }
}