package com.wallacebiscaro.soapaclspring.controller;

import com.wallacebiscaro.soapaclspring.client.DataAccessClient;
import com.wallacebiscaro.soapaclspring.client.gen.NumberToWords;
import com.wallacebiscaro.soapaclspring.client.gen.NumberToWordsResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigInteger;

@RestController
@RequestMapping("/converter")
public class NumberConversionController {
    @Autowired
    private DataAccessClient dataAccessClient;

    @GetMapping(value = "/{number}")
    @PreAuthorize("hasAnyAuthority('ADMIN_ROLE')")
    public String converter(@PathVariable BigInteger number) {
        NumberToWords request = new NumberToWords();
        request.setUbiNum(number);

        return this.dataAccessClient.numberToWord(request).getNumberToWordsResult().trim();
    }
}