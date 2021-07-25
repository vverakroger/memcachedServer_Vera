# Description

Memcached server (TCP/IP socket) multi client implementation

The followed Memcached commands are supported:

Retrieval commands:
- get
- gets
  
Storage commands:
- set
- add
- replace
- append
- prepend
- cas

# Installation

This is what you need to do to install the program is:

1. Install Ruby on Rails https://rubyonrails.org/
2. Download and unzip the .zipfile or clone the repository url on your computer

# Run

1. Open two command prompt and go to your proyect folder in both
2. Run ruby server.rb in one of them to start the server
3. Once the server is listenig run ruby client.rb in the other to start the client

# Authentication

The client needs to enter a user name (string) and a password (abc123). If the password is incorrect the connection ends.
If the authentication is correct the client is ready to run the previous mentioned Memcached commands.

# Testing

The following image contains the unit test tested for each command: 

[Tested user cases](/userCases.jpg)

# Feedback

Questions about the Ruby language can be asked on the Ruby-Talk mailing list (www.ruby-lang.org/en/community/mailing-lists) or on websites like (stackoverflow.com).
