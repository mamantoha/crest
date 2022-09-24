module Crest
  class ZeroEnumeratedFlatParamsEncoder < EnumeratedFlatParamsEncoder
    class_getter array_start_index = 0
  end
end
