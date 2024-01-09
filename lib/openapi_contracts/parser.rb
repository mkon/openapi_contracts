module OpenapiContracts
  class Parser
    autoload :Transformers, 'openapi_contracts/parser/transformers'

    TRANSFORMERS = [Transformers::Pointer].freeze

    def self.call(dir, filename)
      new(dir.join(filename)).parse
    end

    attr_reader :filenesting, :rootfile

    def initialize(rootfile)
      @cwd = rootfile.parent
      @rootfile = rootfile
      @filenesting = {}
    end

    def parse
      @filenesting = build_file_list
      @filenesting.each_with_object({}) do |(path, pointer), schema|
        target = pointer.to_a.reduce(schema) { |d, k| d[k] ||= {} }
        target.delete('$ref') # ref file pointers should be in the file list so save to delete
        target.merge! file_to_data(path, pointer)
      end
    end

    private

    # file list consists of
    # - root file
    # - all files in components/
    # - all path files referenced by the root file
    def build_file_list
      list = {@rootfile.relative_path_from(@cwd) => Doc::Pointer[]}
      Dir[File.expand_path('components/**/*.yaml', @cwd)].each do |file|
        pathname = Pathname(file).relative_path_from(@cwd).cleanpath
        pointer = Doc::Pointer.from_path pathname.sub_ext('')
        list.merge! pathname => pointer
      end
      YAML.safe_load_file(@rootfile).fetch('paths') { {} }.each_pair do |k, v|
        next unless v['$ref'] && !v['$ref'].start_with?('#')

        list.merge! Pathname(v['$ref']).cleanpath => Doc::Pointer['paths', k]
      end
      list
    end

    def file_to_data(pathname, pointer)
      YAML.safe_load_file(@cwd.join(pathname)).tap do |data|
        transform_objects!(data, pathname.parent, pointer)
      end
    end

    def transform_objects!(object, cwd, pointer)
      case object
      when Hash
        object.each_value { |v| transform_objects!(v, cwd, pointer) }
        TRANSFORMERS.map { |t| t.new(self, cwd, pointer) }.each { |t| t.call(object) }
      when Array
        object.each { |o| transform_objects!(o, cwd, pointer) }
      end
    end
  end
end
