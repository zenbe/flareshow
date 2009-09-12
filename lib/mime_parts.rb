# Adapted From : http://deftcode.com/code/flickr_upload/multipartpost.rb

class Param
  attr_accessor :key, :value, :content_type
  def initialize(key, value, content_type)
    @key = key; @value = value; @content_type = content_type
  end
  
  def to_multipart
    return "\r\nContent-Disposition: form-data; name=\"#{CGI::escape(key)}\"\r\n" +
"Content-Type: #{content_type}; charset=UTF-8" +
"\r\n\r\n#{value}\r\n"
  end
end
  
class FileParam
  attr_accessor :key, :filename, :content
  def initialize( key, filename, content )
    @key = key; @filename = filename; @content = content
  end
  
  def to_multipart
    return "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"; filename=\"#{filename}\"\r\n" +
"Content-Transfer-Encoding: binary\r\n" +
"Content-type: #{MIME::Types.type_for(filename)}\r\n\r\n" + content + "\r\n"
  end
end

class MultipartPost
  BOUNDARY = "flareshow_multipart_boundary_A0n23hja"
  HEADER = {"Content-type" => "multipart/form-data, boundary=" + BOUNDARY + " "}

  def self.prepare_query(params)
    query = params.map {|p| "--" + BOUNDARY + "\r\n" + p.to_multipart }.join("") + "--" + BOUNDARY + "--"
    [query, HEADER]
  end
end