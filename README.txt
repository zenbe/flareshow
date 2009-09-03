   ___  ___                                  __                            
 /'___\/\_ \                                /\ \                           
/\ \__/\//\ \      __     _ __    __    ____\ \ \___     ___   __  __  __  
\ \ ,__\ \ \ \   /'__`\  /\`'__\/'__`\ /',__\\ \  _ `\  / __`\/\ \/\ \/\ \ 
 \ \ \_/  \_\ \_/\ \L\.\_\ \ \//\  __//\__, `\\ \ \ \ \/\ \L\ \ \ \_/ \_/ \
  \ \_\   /\____\ \__/.\_\\ \_\\ \____\/\____/ \ \_\ \_\ \____/\ \___x___/'
   \/_/   \/____/\/__/\/_/ \/_/ \/____/\/___/   \/_/\/_/\/___/  \/__//__/
   
   ~ Client Library For the Zenbe Shareflow API

== OVERVIEW

Flareshow provides a ruby wrapper around the shareflow json rpc wire protocol.  For more information about the Shareflow API see:
<Shareflow API Docs Link>
   
== AUTHENTICATION
   
All actions in Flareshow require authenticationFlareshow can automatically authenticate you against your shareflow server.  Just create a YAML formatted .flareshowrc file in your home directory with the following keys

subdomain : demo.zenbe.com
login     : demo
password  : password

To authenticate manually do the following:

Flareshow::Service.configure(<subdomain>)
Flareshow.authenticate(<login>, <password>)

== USAGE

Once you've authenticated you can choose to use either interact directly with the Flareshow::Service or use the Flareshow::Resource domain models which encapsulate the domain logic of Shareflow providing a friendlier development environment.

== EXAMPLES

= Reading Posts

# the following code will read all posts on the server in a loop

per_request = 30 # 30 is the default returned by the server -- max is 100
results = []
loop do 
  offset ||= 0
  results << Post.find(:offset => offset, :limit => per_request)
  offset += per_request
end

= Upload a file to a Post
p=Post.new()
p.save
p.create_file("/path/to/your/file")

= Searching for a post

# posts, files, comments include the searchable mixin
# and can be searched using full text search capabilities
# on the server
results = Post.search("some keywords")

= deleting a post or comment
Post.find(:limit => 1).first.destroy
Comment.find(:limit => 1).first.destroy

= Renaming a flow
f=Flow.find_by_name('test')
f.name = 'a different name'
f.save

== Caching

If you choose to use the Flareshow::Resource objects to manage requests through the Service a caching layer is built in.  Currently this cache is in memory only; however, the API is designed to allow developers to plugin alternate caches as desired.  For example if you wanted to persist shareflow data in a sql lite database you just need to create a SQLLite cache class implementing the Flareshow cache interface.