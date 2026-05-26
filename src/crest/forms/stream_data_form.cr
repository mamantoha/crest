require "../form"

module Crest
  # Streams multipart form data through a pipe to avoid buffering the full body in memory.
  class StreamDataForm(T) < Crest::Form(T)
    DEFAULT_MIME_TYPE = "application/octet-stream"

    def generate
      content_type_ch = Channel(String).new(1)
      reader, writer = IO.pipe

      spawn do
        begin
          HTTP::FormData.build(writer) do |formdata|
            content_type_ch.send(formdata.content_type)

            parsed_params.each do |name, value|
              add_field(formdata, name.to_s, value)
            end
          end
        ensure
          writer.close
        end
      end

      @form_data = reader
      @content_type = content_type_ch.receive

      self
    end

    def parsed_params
      @params_encoder.flatten_params(@params)
    end

    private def add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, value : Crest::ParamsValue)
      formdata.field(name.to_s, value.to_s)
    end

    private def add_field(formdata : HTTP::FormData::Builder, name : String | Symbol, io : IO)
      filename = io.is_a?(File) ? io.as(File).path : name.to_s
      mime = MIME.from_filename(filename, DEFAULT_MIME_TYPE)
      metadata = HTTP::FormData::FileMetadata.new(filename: filename)
      headers = HTTP::Headers{"Content-Type" => mime}

      formdata.file(name.to_s, io, metadata, headers)
    end
  end
end
