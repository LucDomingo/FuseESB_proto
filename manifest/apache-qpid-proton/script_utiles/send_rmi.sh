python producer.py -u amqp://artemis-service:5672 -q rmi -m 1 --payload requête
python consumer.py -u amqp://artemis-service:5672 -q rmi -m 1
