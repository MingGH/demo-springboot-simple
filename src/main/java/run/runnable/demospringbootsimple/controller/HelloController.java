package run.runnable.demospringbootsimple.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import run.runnable.demospringbootsimple.config.AppConfig;

/**
 * @author Asher
 * on 2023/1/3
 */
@Controller
public class HelloController {

    @GetMapping("/hello")
    @ResponseBody
    public String hello(){
        return "hello " + appConfig.getEnv();
    }


    private AppConfig appConfig;
    @Autowired
    public void setAppConfig(AppConfig appConfig) {
        this.appConfig = appConfig;
    }
}
