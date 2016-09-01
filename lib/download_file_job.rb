  class DownloadFileJob < Struct.new(:user_id, :h_files,  :s_name, :lab_id)

    def success(job)
      # send email notification
      update_status('success')
    end

    def error(job, exception)
      # send email notification
      # lines = job.last_error.split("\n")
      # lines = lines.join("\\n")
      # file = Fu.find fu_id
      # file.update_attributes(:error => lines, :status_id => 'failure')
      update_status('failure')
    end
    
    def failure(job)

    end

    def perform
     user = User.find user_id
     update_status('uploading')
     user.download h_files, s_name, lab_id
#     raise StandardError.new("Failed to save file #{file.name} for measurement with id: #{file.measurement.id} ") unless file.upload(url)
    end


   private

    def update_status(status)
#      file = Fu.find fu_id
#      file.status = status
#      file.save!
    end
  end
