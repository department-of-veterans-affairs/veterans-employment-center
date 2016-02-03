class EmployerReport
  COLUMNS = ['company_name', 'ein', 'created_at', 'email', 'approved_on']
  ORDERS = {'desc' => :desc, 'asc' => :asc}

  attr_accessor :viewcontext, :params, :search

  def initialize(params = {}, viewcontext = nil)
    @params, @viewcontext = params, viewcontext
    search_from_form = params[:q].try(:values).try(:first).presence
    @search = params[:search].try(:[], 'value').presence || search_from_form
  end

  def total_employers
    Employer.count
  end

  def data
    if ordercolumn == 'email'
      orderby = User.arel_table[:email].send(orderdir)
    else
      orderby = {ordercolumn => orderdir}
    end
    # Normalize the 2 styles of pagination params
    page, per = parse_pagination
    filtered_pool.order(orderby).paginate(page: page, per_page: per).references(:user)
  end

  def parse_pagination
    per = (params[:length] || params[:per_page] || 50).to_i
    offset = (params[:start] || 0).to_i
    page = (params[:page] || offset/per + 1).to_i
    [page, per]
  end

  def filtered_pool
    searchform.result(distinct: true)
  end

  def to_csv(csv, options={})
    cols = Employer.column_names
    user_columns = ["last_sign_in_at"]
    csv << cols + user_columns
    filtered_pool.find_each do |employer|
      csv << cols.map{|c| employer.send(c)} + user_columns.map{|user_column| employer.user.send(user_column)}
    end
  end

  def ordercolumn
    @ordercolumn ||= begin
      ordercolumnparam = orderparam.try(:[], 'column') || 4
      COLUMNS[ordercolumnparam.to_i]
    end
  end

  def orderdir
    @orderdir ||= ORDERS[orderparam.try(:[], 'dir')] || :desc
  end

  def orderparam
    @orderparam ||= params[:order].try(:values).try(:first)
  end

  def searchform
    search_on = 'company_name_or_poc_email_or_poc_name_or_user_email_or_ein_or_location_cont'
    employer_pool.ransack(search_on => @search)
  end

  def employer_pool
    Employer.eager_load(:user)
  end

  def as_json(opts = {})
    if viewcontext
      output = data.map do |employer|
        employer.as_json.slice('company_name', 'ein').merge(
          {
            created_at: employer.created_at.strftime("%b %d %Y"),
            email: employer.user.try(:email),

            approval_status: viewcontext.render_to_string(partial: 'approval_status.html', locals: {employer: employer}),
            actions: viewcontext.render_to_string(partial: 'admin_actions.html', locals: {employer: employer})
          }
        )
      end
      {data: output, recordsTotal: total_employers, recordsFiltered: filtered_pool.count}
    end
  end

end
