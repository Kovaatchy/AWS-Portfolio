aws rds create-db-instance \
--db-instance-identifier rds-taravasysnet-test \
--db-instance-class db.t3.micro \
--engine mysql \
--master-username admin \
--master-user-password secret \
--allocated-storage 20

