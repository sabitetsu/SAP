class Admin::CsvImportController < Admin::ApplicationController
  def new
  end

  def create
    # csv file ckeck
    unless params[:csv_file_laboratory] || params[:csv_file_student]
      error_messages = ['最低でもどちらか一方のcsvファイルを選択してください']
      flash[:error_messages] = error_messages
      redirect_back fallback_location: root_path and return
    end

    # csv import
    flash_notice_messages = []
    user_id = current_user.id
    # laboratory
    if params[:csv_file_laboratory]
      begin
        Laboratory.csv_import(csv_file_laboratory_params, user_id)
      rescue => e
        Laboratory.where(user_id: user_id).destroy_all
        flash[:error_messages] = ['研究室データをもう一度確認して下さい', e.message]
        redirect_back fallback_location: root_path and return
      end
      flash_notice_messages.push('研究室のcsvファイルのインポート成功')
    end
    # student
    if params[:csv_file_student]
      begin
        Student.csv_import(csv_file_student_params, user_id)
      rescue => e
        Student.where(user_id: user_id).destroy_all
        flash[:notices] = flash_notice_messages
        flash[:error_messages] = ['学生データをもう一度確認して下さい', e.message]
        redirect_back fallback_location: root_path and return
      end
      flash_notice_messages.push('学生のcsvファイルのインポート成功')
    end
    flash[:notices] = flash_notice_messages
    redirect_to admin_init_setup_second_skip_path
  end

  private

  def csv_file_laboratory_params
    params.require(:csv_file_laboratory)
  end

  def csv_file_student_params
    params.require(:csv_file_student)
  end
end
