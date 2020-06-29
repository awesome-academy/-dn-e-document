class ExportUserWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    users = User.pluck :id, :fullname, :email, :role, :coin
    total users.size
    xlsx_package = Axlsx::Package.new
    xlsx_workbook = xlsx_package.workbook
    xlsx_workbook.add_worksheet(name: "Users") do |worksheet|
      worksheet.add_row %w(ID Name Email Role Coin)
      users.each.with_index(1) do |user, idx|
        worksheet.add_row user
        at idx
        sleep 0.5
      end
    end
    xlsx_package.serialize Rails.root.join("tmp", "users_export_#{jid}.xlsx")
  end
end
