package com.vandam.adams;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.ServletComponentScan;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
@ServletComponentScan(basePackages = {"servlet", "com.example.listener"})
public class AdamsApplication extends SpringBootServletInitializer {
    public static void main(String[] args) {
        SpringApplication.run(AdamsApplication.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(AdamsApplication.class);
    }
}
