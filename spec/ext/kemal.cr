module Kemal
  class StaticFileHandler < HTTP::StaticFileHandler
    private def modification_time(file_path)
      File.info(file_path).modification_time
    end
  end
end
