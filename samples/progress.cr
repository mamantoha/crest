require "../src/crest"

url = "https://github.com/crystal-lang/crystal/archive/1.8.1.zip"
buffer_size = 4096
downloaded_size = 0

Crest.get(url) do |response|
  output_file = response.filename || "crystal.zip"
  content_length = response.content_length

  File.open(output_file, "w") do |file|
    buffer = Bytes.new(buffer_size)

    loop do
      bytes_read = response.body_io.read(buffer)

      break if bytes_read == 0

      file.write(buffer[0, bytes_read])

      downloaded_size += bytes_read
      downloaded_in_percents = ((downloaded_size / content_length) * 100).round(0)

      print "Received data: #{downloaded_size.humanize_bytes} (#{downloaded_in_percents}%)"
      print "\r"
    end
  end

  puts
  puts "Download complete! Saved as #{output_file}"
end
