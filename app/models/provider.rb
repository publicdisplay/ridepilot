class Provider < ActiveRecord::Base
  has_many :roles, :dependent => :destroy
  has_many :users, :through => :roles
  has_many :drivers, :dependent => :destroy
  has_many :vehicles, :dependent => :destroy
  has_many :device_pools, :dependent => :destroy
  has_many :monthlies, :dependent => :destroy
  has_many :ethnicities, :class_name=>'ProviderEthnicity', :dependent => :destroy
  has_many :funding_source_visibilities, :dependent => :destroy
  has_many :funding_sources, :through => :funding_source_visibilities
  has_many :addresses, :dependent => :nullify

  has_attached_file :logo, :styles => { :small => "150x150>" }
  
  REIMBURSEMENT_ATTRIBUTES = [
    :oaa3b_per_ride_reimbursement_rate,
    :ride_connection_per_ride_reimbursement_rate,
    :trimet_per_ride_reimbursement_rate,
    :stf_van_per_ride_reimbursement_rate,
    :stf_taxi_per_ride_administrative_fee,
    :stf_taxi_per_ride_ambulatory_load_fee,
    :stf_taxi_per_ride_wheelchair_load_fee,
    :stf_taxi_per_mile_ambulatory_reimbursement_rate,
    :stf_taxi_per_mile_wheelchair_reimbursement_rate
  ]
  
  validate :name, :length => { :minimum => 2 }
  validates_numericality_of :oaa3b_per_ride_reimbursement_rate,               :greater_than => 0, :allow_blank => true
  validates_numericality_of :ride_connection_per_ride_reimbursement_rate,     :greater_than => 0, :allow_blank => true
  validates_numericality_of :trimet_per_ride_reimbursement_rate,              :greater_than => 0, :allow_blank => true
  validates_numericality_of :stf_van_per_ride_reimbursement_rate,             :greater_than => 0, :allow_blank => true
  validates_numericality_of :stf_taxi_per_ride_administrative_fee,            :greater_than => 0, :allow_blank => true
  validates_numericality_of :stf_taxi_per_ride_ambulatory_load_fee,           :greater_than => 0, :allow_blank => true
  validates_numericality_of :stf_taxi_per_ride_wheelchair_load_fee,           :greater_than => 0, :allow_blank => true
  validates_numericality_of :stf_taxi_per_mile_ambulatory_reimbursement_rate, :greater_than => 0, :allow_blank => true
  validates_numericality_of :stf_taxi_per_mile_wheelchair_reimbursement_rate, :greater_than => 0, :allow_blank => true

  validates_attachment_size :logo, :less_than => 200.kilobytes
  validates_attachment_content_type :logo, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  
  after_initialize :init

  def init
    self.scheduling = true if new_record?
  end
end
