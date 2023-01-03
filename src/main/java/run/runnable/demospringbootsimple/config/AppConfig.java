package run.runnable.demospringbootsimple.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * @author Asher
 * on 2023/1/3
 */
@Component
@ConfigurationProperties(prefix ="app.config")
public class AppConfig {

    private String env;

    public void setEnv(String env) {
        this.env = env;
    }

    public String getEnv() {
        return env;
    }

    @Override
    public String toString() {
        return "AppConfig{" +
                "env='" + env + '\'' +
                '}';
    }
}
