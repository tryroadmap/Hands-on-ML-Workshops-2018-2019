# EEEEEEEEEEEEEEEEEEEE MMMMMMMM           MMMMMMMM RRRRRRRRRRRRRRR
# E::::::::::::::::::E M:::::::M         M:::::::M R::::::::::::::R
# EE:::::EEEEEEEEE:::E M::::::::M       M::::::::M R:::::RRRRRR:::::R
#   E::::E       EEEEE M:::::::::M     M:::::::::M RR::::R      R::::R
#   E::::E             M::::::M:::M   M:::M::::::M   R:::R      R::::R
#   E:::::EEEEEEEEEE   M:::::M M:::M M:::M M:::::M   R:::RRRRRR:::::R
#   E::::::::::::::E   M:::::M  M:::M:::M  M:::::M   R:::::::::::RR
#   E:::::EEEEEEEEEE   M:::::M   M:::::M   M:::::M   R:::RRRRRR::::R
#   E::::E             M:::::M    M:::M    M:::::M   R:::R      R::::R
#   E::::E       EEEEE M:::::M     MMM     M:::::M   R:::R      R::::R
# EE:::::EEEEEEEE::::E M:::::M             M:::::M   R:::R      R::::R
# E::::::::::::::::::E M:::::M             M:::::M RR::::R      R::::R
# EEEEEEEEEEEEEEEEEEEE MMMMMMM             MMMMMMM RRRRRRR      RRRRRR


# Update
sudo yum update
sudo yum install libcurl-devel openssl-devel # used for devtools

# Install RStudio Server
wget -P /tmp https://s3.amazonaws.com/rstudio-dailybuilds/rstudio-server-rhel-0.99.1266-x86_64.rpm
sudo yum install --nogpgcheck /tmp/rstudio-server-rhel-0.99.1266-x86_64.rpm

# Make User
sudo useradd -m rstudio-user
sudo passwd rstudio-user

# create directories on hdfs for new user
hadoop fs -mkdir /user/rstudio-user
hadoop fs -chmod 777 /user/rstudio-user

# switch user
su rstudio-user

# Make download directory
mkdir /tmp/flights

# Download flight data by year
for i in {1987..2008}
  do
    echo "$(date) $i Download"
    fnam=$i.csv.bz2
    wget -O /tmp/flights/$fnam http://stat-computing.org/dataexpo/2009/$fnam
    echo "$(date) $i Unzip"
    bunzip2 /tmp/flights/$fnam
  done

# Download airline carrier data
wget -O /tmp/airlines.csv http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS

# Download airports data
wget -O /tmp/airports.csv https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat
