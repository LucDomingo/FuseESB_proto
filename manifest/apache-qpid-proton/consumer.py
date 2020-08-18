from __future__ import print_function, unicode_literals
import optparse
import proton
from proton import Message
from proton.handlers import MessagingHandler
from proton.reactor import Container

import logging

def get_options():
    parser = optparse.OptionParser(usage="usage: %prog [options]",
        description="Consumes messages from a solace Durable Topic Endpoint(DTE)")
    parser.add_option("-u", "--url", action="store", default="amqp://localhost:5672",
        help="Url to connect to amqp broker (default %default)")
    parser.add_option("-t", "--topic", action="store", default="a/topic",
        help="Topic (default %default)")
    parser.add_option("-m", "--messages", type="int", default=100,
        help="number of messages to receive (default %default)")
    parser.add_option("-o", "--username", default=None,
        help="username for authentication (default %default)")
    parser.add_option("-p", "--password", default=None,
        help="password for authentication (default %default)")

    (options, args) = parser.parse_args()
    return options


"""
DTEConsumer class is a proton event handler
This class establishes a connection and revceiver link
attached to solace Durable Topic Endpoint
"""
class DTEConsumer(MessagingHandler):

    def __init__(self, url, address, count, username, password):
        super(DTEConsumer, self).__init__()
        
        self.url = url
        
        self.topic_address = address
                
        self.username = username
        self.password = password
        
        self.expected = count
        self.received = 0

    def on_start(self, event):
        conn = event.container.connect(url=self.url)
        if conn:
          print('ok')
          event.container.create_receiver(conn,source=self.topic_address)
    def on_message(self, event):
        if self.received < self.expected:
            self.received += 1
            if self.received == self.expected:
                print('Received all messages' + str (self.received))
                event.receiver.close()
                event.connection.close()
    
    def on_transport_error(self, event):
        print("transport failure for borker:", self.url)
        MessagingHandler.on_transport_error(self, event)


options = get_options()
amqp_address = 'topic://' + options.topic

try:
    print("waiting to receive", options.messages,"messages")
    Container(DTEConsumer(options.url, 
                          amqp_address, 
                          options.messages, 
                          options.username, 
                          options.password)
    ).run()
except KeyboardInterrupt: pass
