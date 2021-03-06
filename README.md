       ___ ___                                 __                            
     /'___\\_ \                               /\ \                           
    /\ \__///\ \      __     _ __   __    ____\ \ \___     ___   __  __  __  
    \ \ ,__\\ \ \   /'__`\  /\`'__\'__`\ /',__\\ \  _ `\  / __`\/\ \/\ \/\ \ 
     \ \ \_/ \_\ \_/\ \L\.\_\ \ \/\  __//\__, `\\ \ \ \ \/\ \L\ \ \ \_/ \_/ \
      \ \_\  /\____\ \__/.\_\\ \_\ \____\/\____/ \ \_\ \_\ \____/\ \___x___/'
       \/_/  \/____/\/__/\/_/ \/_/\/____/\/___/   \/_/\/_/\/___/  \/__//__/
    
        ~ a ruby wrapper for the Zenbe Shareflow API


### Overview

Flareshow provides a ruby wrapper around the shareflow json rpc wire protocol.  

For more information about the Shareflow API see: http://api.zenbe.com

### Getting Started
You'll need a shareflow account setup before you can begin interacting with the api.  Go to <http://getshareflow.com> and sign up for a free account.

### Authentication

All actions in Flareshow require authenticationFlareshow can automatically authenticate you against your shareflow server.  Just create a YAML formatted .flareshowrc file in your home directory with the following keys

subdomain : demo.zenbe.com
login     : demo
password  : password

To authenticate manually do the following:

    Flareshow::Service.configure(<subdomain>)
    Flareshow::Service.authenticate(<login>, <password>)

### Usage

Once you've authenticated you can choose to use either interact directly with the Flareshow::Service or use the Flareshow::Resource domain models which encapsulate the domain logic of Shareflow providing a friendlier development environment.

### Examples

#### accessing models and associations

Flareshow offers an ActiveRecord like syntax for retrieving and manipulating models.

    # Get the first post from the server ordered by creation date by default
    p = Post.first
    
    # Get the comments for that post
    p.comments
    
    # get the file attachments for the post
    files = p.files
    
    # download a file
    files.first.download


#### reading posts

    # the following code will read all posts on the server in a loop
    per_request = 30
    results = []
    offset = 0

    loop do 
      posts = Post.find(:offset => offset, :limit => per_request)
      results += posts
      puts results.size
      offset += per_request
      break if posts.empty?
    end

#### upload a file to a Post

    p=Post.new()
    p.save
    p.create_file("/path/to/your/file")

#### searching for a post

    # posts, files, comments include the searchable mixin
    # and can be searched using full text search capabilities
    # on the server
    results = Post.search("some keywords")

#### deleting a post or comment

    Post.first.destroy
    Comment.first.destroy

#### renaming a flow

    f=Flow.find_by_name('test')
    f.name = 'a different name'
    f.save

#### inviting someone to a flow (only available if you are the creator of the flow)

    f=Flow.find_by_name('test')
    f.send_invitations('test@test.com')
    
    # this also works
    f.send_invitations(['test1@test.com', 'test2@test.com'])
    
#### canceling an invitation to a flow (only available if you are the creator of the flow)
    
    f=Flow.find_by_name('test')
    # revoke an invitation by the email address that was invited
    f.revoke_invitations('test@test.com')


#### removing a user from a flow (only available if you are the creator of the flow)

    f = Flow.find_by_name('test')
    users = f.list_users # get a listing of the users on the flow
    # remove the last user in the list from the flow...you cant remove yourself in this way
    f.remove_members(users.last.id) 

#### listing all the users on a flow

    f=Flow.first
    f.list_users