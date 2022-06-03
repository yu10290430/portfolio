module FileUploadHelpers
  def file_upload(src, content_type, binary: false)
    path = Rails.root.join(src)
    original_filename = path.basename.to_s

    tempfile = Tempfile.new(original_filename)
    binary ? tempfile.binwrite(path.binread) : tempfile.write(path.read)
    tempfile.rewind

    uploaded_file = Rack::Test::UploadedFile.new(tempfile, content_type, binary, original_filename: original_filename)
    ObjectSpace.define_finalizer(uploaded_file, uploaded_file.class.finalize(tempfile))

    uploaded_file
  end
end
