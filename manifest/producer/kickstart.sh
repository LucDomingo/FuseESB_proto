export AMQP_USER=artemis
export AMQP_PASSWORD=simetraehcapa
amqpcli send localhost 5672 exchange_a simple_message -m 'hello'
