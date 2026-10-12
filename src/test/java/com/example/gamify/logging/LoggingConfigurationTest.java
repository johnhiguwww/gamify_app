package com.example.gamify.logging;

import org.junit.jupiter.api.Test;

import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertTrue;

class LoggingConfigurationTest {

    @Test
    void applicationLogsAreWrittenOutsideGitToLogsDirectory() throws Exception {
        String logback = Files.readString(Path.of("src/main/resources/logback-spring.xml"));
        String gitignore = Files.readString(Path.of(".gitignore"));

        assertTrue(logback.contains("./Logs"));
        assertTrue(logback.contains("gamify.log"));
        assertTrue(gitignore.contains("Logs/"));
    }
}
