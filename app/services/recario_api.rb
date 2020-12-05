class RecarioApi
  def update(data)
    conn = Faraday.new("http://#{ENV['RAILS_SERVICE_HOST']}/api/v1/provider_ads/update_ad", headers: {
                         Authorization: "Bearer #{ENV['RECARIO_API_TOKEN']}",
                         'Content-Type': 'application/json'
                       })

    response = conn.put do |req|
      req.body = ({ ad: data }.to_json)
    end

    puts response.body.force_encoding('utf-8')

    response
  end

  def delete(data)
    conn = Faraday.new("http://#{ENV['RAILS_SERVICE_HOST']}/api/v1/provider_ads/delete_ad", headers: {
                         Authorization: "Bearer #{ENV['RECARIO_API_TOKEN']}",
                         'Content-Type': 'application/json'
                       })

    response = conn.delete do |req|
      req.body = ({ ad: data }.to_json)
    end

    puts response.body.force_encoding('utf-8')

    response
  end

  def index
    conn = Faraday.new("http://#{ENV['RAILS_SERVICE_HOST']}/api/v1/provider_ads", headers: {
                         Authorization: "Bearer #{ENV['RECARIO_API_TOKEN']}",
                         'Content-Type': 'application/json'
                       })

    response = conn.get

    puts response.body.force_encoding('utf-8')

    response
  end
end
