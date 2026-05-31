connect ThanhQuan_Distributed_Database;

-- INITIALIZE DATABASE LINKS
--- Kim Ngan Database link (HCM)
DROP DATABASE LINK KimNgan_Oracle_DistributedDatabase;

CREATE DATABASE LINK KimNgan_Oracle_DistributedDatabase 
CONNECT TO SYSTEM IDENTIFIED BY "Kimngan@2352129"
USING '(
    DESCRIPTION=(
        ADDRESS=
            (PROTOCOL=TCP)
            (HOST=100.127.201.25)
            (PORT=1521)
            (CONNECT_DATA=(SERVICE_NAME=FREE))
    )
)';
--- Check Kim Ngan connection 
select * from Products@KimNgan_Oracle_DistributedDatabase;

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
