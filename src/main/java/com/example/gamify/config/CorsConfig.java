package com.example.gamify.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

// #$ CorsConfig — libera o front-end Flutter Web (rodando em outro domínio,
// ex: Firebase Hosting) a chamar essa API. #!! troque os valores abaixo pela
// URL real do seu site publicado; localhost fica liberado pra testes locais.
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins(
                        "http://localhost:*",
                        "https://gamify-app-ce12f.web.app",
                        "https://gamify-app-ce12f.firebaseapp.com"
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*");
    }
}
