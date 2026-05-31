connect KimNgan_Distributed_Database;

-- INITIALIZE DATABASE LINKS
--- Thanh Quan Database link (DN)
DROP DATABASE LINK ThanhQuan_Oracle_DistributedDatabase;

CREATE DATABASE LINK ThanhQuan_Oracle_DistributedDatabase 
CONNECT TO SYSTEM IDENTIFIED BY "Quannguyen@14042005!"
USING '(
    DESCRIPTION=(
        ADDRESS=
            (PROTOCOL=TCP)
            (HOST=100.122.81.2)
            (PORT=1521)
            (CONNECT_DATA=(SERVICE_NAME=FREE))
    )
)';
--- Check Kim Ngan connection 
select * from Products@ThanhQuan_Oracle_DistributedDatabase;

--- Minh Thuy Database link (HN)
DROP DATABASE LINK MinhThuy_Oracle_DistributedDatabase;

CREATE DATABASE LINK MinhThuy_Oracle_DistributedDatabase
CONNECT TO C##M01 IDENTIFIED BY "123"
USING '
(DESCRIPTION=
    (ADDRESS=
        (PROTOCOL=TCP)
        (HOST=100.82.181.79)
        (PORT=1521)
    )
    (CONNECT_DATA=
        (SID=xe)
    )
)';
--- Check Minh Thuy connection
SELECT * FROM Products@MinhThuy_Oracle_DistributedDatabase;
