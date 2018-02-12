@base_url = "http://#{request.host_with_port}/"

xml.instruct! :xml, version: '1.0'
xml.tag!(
  'urlset',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9',
  'xmlns:image' => 'http://www.google.com/schemas/sitemap-image/1.1',
  'xmlns:video' => 'http://www.google.com/schemas/sitemap-video/1.1'
) do
  @pages.each { |page| xml.url { xml.loc(@base_url + page) } }
end
