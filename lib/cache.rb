# provides an interface for various
# caches that flareshow might use
class Flareshow::Cache
  
  class << self
    # assimilate the resources provided in the response
    def assimilate_resources(response)
      results = {}
      # process each resource key and generate a new object
      # or merge the object data with an existing object
      response[:resources].each do |resource_pair|
        resource_key, resources = resource_pair[0], resource_pair[1]
        klass = Kernel.const_get(Flareshow::ResourceToClassMap[resource_key])
        next unless klass
        resources.each do |resource_data|
          item = klass.get(resource_data["id"], :server)
          item.update(resource_data, :server)
          results[resource_key] ||= []
          results[resource_key].push(item)
        end
      end
      results
    end
  end
  
end