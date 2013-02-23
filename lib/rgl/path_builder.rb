module RGL

  class PathBuilder # :nodoc:

    def initialize(source, parents_map)
      @source      = source
      @parents_map = parents_map
      @paths       = {}
    end

    def path(target)
      if @paths.has_key?(target)
        @paths[target]
      else
        @paths[target] = restore_path(target)
      end
    end

    def paths(targets)
      paths_map = {}

      targets.each do |target|
        paths_map[target] = path(target)
      end

      paths_map
    end

    private

    def restore_path(target)
      return [@source] if target == @source

      parent = @parents_map[target]
      path(parent) + [target] if parent
    end

  end

end # RGL