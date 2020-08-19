package org.example.fis;
import java.util.Random;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


public class DynamicRouterBean {
    private final static Logger LOGGER = LoggerFactory.getLogger(DynamicRouterBean.class);
	public String slip(String body) {
		LOGGER.info("Routage Dynamique ... ok");
		Random random = new Random();
		int value = random.nextInt(1000);
		if (value >= 500) {
			return "amqp:queue:large";
		} else {
			return "amqp:queue:small";
		}
	}
}