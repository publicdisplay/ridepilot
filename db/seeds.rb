# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if !Provider.exists?(1)
  provider = Provider.new(:id=>1, :name=>'Ride Connection', :dispatch => true)
  provider.logo = File.open(File.join(RAILS_ROOT, "public", "ride_connection_logo.png"))
  provider.save!
end
f = File.new(File.join(RAILS_ROOT, 'db', 'trimet.wkt')) 
wkt = f.read
f.close
poly = Polygon.from_ewkt(wkt)
poly.srid = 4326
region = Region.create(:name=>"TriMet", :the_geom => poly)


for name in ["Scooter", "Wheelchair", "Wheelchair - Oversized", "Wheelchair - Can Transfer", "Unknown", "Ambulatory"]
  Mobility.create(:name=>name)
end
