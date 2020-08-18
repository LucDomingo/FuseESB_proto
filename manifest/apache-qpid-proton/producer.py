from __future__ import print_function, unicode_literals
import optparse
import random
import string
import sys
import os
from proton import Message
from proton.handlers import MessagingHandler
from proton.reactor import Container

def get_options():
    parser = optparse.OptionParser(usage="usage: %prog [options]",
        description="Sends messages to a topic on the amqp broker")
    parser.add_option("-u", "--url", action="store", default="amqp://localhost:5672",
        help="Url to connect to amqp broker (default %default)")
    parser.add_option("-t", "--topic", action="store", default="a/topic",
        help="Topic to send message (default %default)")
    parser.add_option("-m", "--messages", type="int", default=100,
        help="number of messages to receive (default %default)")
    parser.add_option("-o", "--username", default=None,
        help="username for authentication (default %default)")
    parser.add_option("-p", "--password", default=None,
        help="password for authentication (default %default)")

    (options, args) = parser.parse_args()
    return options

def create_random_string(len):
  return ''.join(random.choice(string.ascii_lowercase) for i in range (len))

"""
Proton event Handler class
Establishes an amqp connection and creates an amqp sender link to transmit messages
"""
class MessageProducer(MessagingHandler):

    def __init__(self, url, address, count, username, password, message):
        super(MessageProducer, self).__init__()
        
        self.message = message
        self.url = url 
        self.topic_address = address 
        
        self.username = username
        self.password = password

        self.total = count
        self.sent = 0
        self.confirmed = 0

    def on_start(self, event):
        if self.username:
            conn = event.container.connect(url=self.url, 
                                           user=self.username, 
                                           password=self.password, 
                                           allow_insecure_mechs=True)
        else:
            conn = event.container.connect(url=self.url)
        if conn:
            event.container.create_sender(conn, target=self.topic_address)
   
    def on_sendable(self, event):
        while event.sender.credit and self.sent < self.total:
            event.sender.send(Message(body= self.message + str(self.sent), durable=True))
            self.sent += 1
    
    def on_accepted(self, event):
        self.confirmed += 1
        if self.confirmed == self.total:
            print('confirmed all messages')
            event.connection.close()

    def on_rejected(self, event):
        self.confirmed += 1
        print("Broker", self.url, "Reject message:", event.delivery.tag, "Remote disposition:", event.delivery.remote.condition)
        if self.confirmed == self.total:
            event.connection.close()

    def on_transport_error(self, event):
        print("Transport failure for amqp broker:", self.url, "Error:", event.transport.condition)
        MessagingHandler.on_transport_error(self, event)

options = get_options()

amqp_address = 'topic://' + options.topic

try:
    message = "hello" #open("message.txt","r")
    Container(MessageProducer(options.url, amqp_address, options.messages, options.username, options.password, message)).run()
except KeyboardInterrupt: pass
    
