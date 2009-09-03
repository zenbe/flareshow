module Flareshow
  module Searchable
  
      def search(keywords)
        self.find({:keywords => keywords})
      end
  
  end
end