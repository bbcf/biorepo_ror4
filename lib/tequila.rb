module Tequila
  require 'uri'
  require 'open-uri'
  require 'json'



  @@request = {
    :host     => 'bbcftools.vital-it.ch/biorepo/',
    :language => 'english',
    :service  => 'BioRepo',
    :allows   => 'categorie=SHIBBOLETH',
    :request  => 'name firstname email title allunits unit office phone user'
  }
  
  
  def create_request2(url_access, host)
    
    #    Create the request to be send to Tequila service                                                                                    
    #    @param url_access: the url where Tequila should send the result                                                                     
    #    @param host: the host of the tequila server                                                                                         
    #    @param wanted_params: the parameters to fetch from tequila server                                                                   
    
    @@request[:urlaccess] = url_access
    url = 'http://' + host + '/cgi-bin/tequila/createrequest'
    #parameters = request.keys.map{|k| "#{k} = #{request[k]}"}.join('\n') #.join([k + '=' + v for k, v in request.iteritems()])
    
    # I'm here
    uri = URI.parse(url)
    uri.query = URI.encode_www_form(@@request)
    result = uri.open.read
    # req = urllib2.Request(url, parameters)
    # result = urllib2.urlopen(req).read()
    return result.gsub(/\n/, '')
  end                     
  
  def validate_key(key, host)
    
    #    Validate the key on tequila server                                                                                                  
    #    @param key: key - the key to validate                                                                                               
    #    @param host: the host of the tequila server                                                                                         
    #    @param return : the user identified                                                                                                 
    
    url = 'http://' + host + '/cgi-bin/tequila/validatekey'
    request = {:key => key}
    begin
      uri = URI.parse(url)
      uri.query = URI.encode_www_form(request)
      return uri.open.read #urllib2.urlopen(url, urllib.urlencode(request)).read()
    rescue Exception => e
      return nil
    end
    
  end
end
