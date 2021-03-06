class ExportsController < ApplicationController

  def show
     # Generate a Tempfile for the download
     csv = Tempfile.new "export", encoding: 'utf-8'
     #export_type = ''

     #if params && params[:kind_of_article] == 'seller_line_item_groups'
     #  LineItemGroupExporter.export(csv, current_user, params)
     #  export_type = 'purchase'
     #else
     #
     #  ArticleExporter.export(csv, current_user, params[:kind_of_article])
     #  export_type = 'article'
     #end
     ArticleExporter.export(csv, current_user, params[:kind_of_article])

     respond_to do |format|
       format.csv { send_file csv.path,
                   { type: 'text/csv; charset=utf-8' , filename: "Fairnopoly_export_#{Time.now.strftime("%Y-%d-%m %H:%M:%S")}.csv"} }
     end
  end
end
