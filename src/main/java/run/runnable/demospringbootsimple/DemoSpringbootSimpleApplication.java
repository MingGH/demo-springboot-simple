package run.runnable.demospringbootsimple;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties
public class DemoSpringbootSimpleApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoSpringbootSimpleApplication.class, args);
	}

}
