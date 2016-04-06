class CommitmentReport

  attr_accessor :viewcontext, :params, :search

  def initialize(params = {}, viewcontext = nil)
    @params = params
    @viewcontext = viewcontext
    @search = params[:search].try(:[], 'value').presence
  end

  def total_employers
    Employer.where(approved: true).count
  end

  def total_commitments
    employer_pool.count
  end

  def commitment_sum
    Employer.where(approved: true).sum(:commit_to_hire)
  end

  def hired_so_far
    Employer.where(approved: true).sum(:commit_hired)
  end

  def committed
    columns = ['company_name', 'commit_to_hire', 'commit_date', 'commit_hired', 'updated_at']
    orders = {'desc' => :desc, 'asc' => :asc}
    orderparam = params[:order].try(:values).try(:first)
    ordercolumnparam = orderparam.try(:[], 'column') || 1
    ordercolumn = columns[ordercolumnparam.to_i]
    orderdir = orders[orderparam.try(:[], 'dir') || 'desc']
    offset = (params[:start] || 0).to_i
    limit = (params[:length] || 10).to_i

    filtered_pool.order(ordercolumn => orderdir).offset(offset).limit(limit)
  end

  def filtered_pool
    if @search
      report_pool = employer_pool.ransack(company_name_cont: @search, approved: true).result(distinct: true)
    else
      employer_pool
    end
  end

  def employer_pool
    Employer.where.not(commit_to_hire: nil).where(approved: true)
  end

  def as_csv
    employer_pool.order(:created_at)
  end

  def csv_fields
    [:company_name, :commit_date, :commit_to_hire, :commit_hired, :website, :location, :note, :commitment_categories, :updated_at]
  end

  def to_csv(csv)
    csv << csv_fields
    employer_pool.order(:created_at).find_each do |employer|
      updated_date = employer.updated_at.to_s[0..9]
      fields = csv_fields
      fields.pop
      csv_output = fields.map{|c| employer.send(c)}
      csv_output.push(updated_date)
      csv << csv_output
    end

  end

  def as_json(opts = {})
    if viewcontext
      output = committed.map do |c|
        c.as_json.slice('commit_to_hire', 'commit_date', 'commit_hired', 'updated_at').merge(
          {
            summary: viewcontext.render_to_string(partial: 'commitment_summary.html', locals: {employer: c})
          }
        )
      end
      {data: output, recordsTotal: total_employers, recordsFiltered: filtered_pool.count}
    end
  end

end
